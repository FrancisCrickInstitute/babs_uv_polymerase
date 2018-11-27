module uv_damage

using Distributions
using StatsBase
using FileIO
using DataFrames
using CSV
using Random
using JSON
using Pages#master
using HTTP

include("cell_settings.jl")
include("types.jl")
include("event_handlers.jl")
include("time_calculators.jl")
include("polymerase_utils.jl")
include("updater_loop.jl")
include("server.jl")


# * Run Simulations
# ** Launch pols until at least one completes.  Limited event-set
function steady_state!(gene::Gene)
  ## Keep removal in, as 'pause' has an effect on time-to-next
    ## No block, repair, or tally
    steady_events = [:initiate :complete :processivity :pause :release :bump :removal]
    while gene.history[:complete]==0
        update!(gene, events=steady_events) 
    end
    k=gene.time
    gene.pol_N = gene.vars["pol_N"] 
    ## Some events get decremented, even though we're not including them in the event loop
    gene.events.tally.time[1] = Float64(gene.vars["tally_interval"])
    gene.events.repair.time .+=  gene.time
    gene.events.block.time .+=  gene.time
    gene.time = 0.0
    ss = deepcopy(gene)
    ss.tally_matrix[:,1] .= counts(div.(floor.(Int, ss.pol_position.-1), ss.vars["tally_binsize"]), UnitRange(0,size(ss.tally_matrix,1)-1))
    gene.pol_N = gene.vars["pol_N"] 
    gene.freedPols = 0
    return(ss)
end




# ** Continually update gene for required amount of time.

function simulate(v::Dict{String, Any}, cell; sim_time=v["run_length"], record=false)
    gene_to_record=1
    io=IOBuffer()
    genes = [Gene(merge(v,g)) for g in cell]
    ss = [steady_state!(g) for g in genes]
    for g in keys(genes)
        genes[g].default_speed *= genes[g].vars["speed_factor_t0"]
        genes[g].pol_speed .*= genes[g].vars["speed_factor_t0"]
    end
    tally_time = -1
    ntime=0
    time_left=sim_time
    time_to_next = [nextEvent(g)[1] for g in genes]
    since_last = [0.0 for g in genes]
    pol_N = v["pol_N"];
    if record
        time_ord = sortperm(genes[gene_to_record].events.repair.time)
        write(io, "{\"damage\":" )
        JSON.print(io,genes[gene_to_record].damage[time_ord])
        write(io, ",\"params\":" )
        JSON.print(io,genes[gene_to_record].vars)
        write(io, ",\"repair\":" )
        JSON.print(io,genes[gene_to_record].events.repair.time[time_ord])
        write(io, ",\"pols\":[")
    end
    while time_left > 0
        ind = argmin(time_to_next)
        genes[ind].pol_N = pol_N
        (elapsed,ev)=update!(genes[ind])
        if record && (ind==gene_to_record) && ev==:initiate
            JSON.print(io, Dict("time" => genes[ind].time,
                                "position" => floor.(Int64, genes[ind].pol_position),
                                "id" => genes[ind].pol_id,
                                "event"=>String(ev)))
            write(io,",\n")
            tally_time = v["tally_interval"]
        end
        time_left -= elapsed - since_last[ind]
        tally_time -= elapsed - since_last[ind]
        pol_N +=  genes[ind].freedPols * genes[ind].vars["genome_prop"]
        if pol_N <1
            pol_N=1
        end
        genes[ind].freedPols = 0
        delta_t = time_to_next[ind]
        for j in keys(since_last)
            if j==ind
                since_last[j]=0
                time_to_next[j]=nextEvent(genes[j])[1]
            else
                since_last[j] += delta_t
                time_to_next[j] -= delta_t
            end
        end
    end
    if record
        write(io,"{\"time\":0, \"position\":[], \"id\":[], \"event\":\"end\"}")
        write(io,"]}")
    end
    return(genes,ss,String(take!(io)))
end


function json_inf(d::Dict{String, Any})::Dict{String, Any}
    rep = Dict(g => d[g]["Value"]==nothing ? Inf : d[g]["Value"] for g in keys(d))
    return(rep)
end
function json_inf(da::Array{Any,1})::Array{Dict{String, Any},1}
     rep = [json_inf(d) for d in da]
     return(rep)
end


# ** Run Simulations
function main()
    main(scenarios, cell, vars)
end    

function main(req::String)
    params=JSON.parse(req)
    main(json_inf(params["scenarios"]), json_inf(params["genes"]), json_inf(params["default"]), client_id=params["id"])
end

function main(scenarios::Array{Dict{String, Any},1}, cell::Array{Dict{String, Any},1}, vars::Dict{String, Any}; client_id="")
    n_iter = (length(ARGS)==0) ? 100 : parse(Int64,ARGS[1]) 
    task_id=parse(Int64,get(ENV, "SLURM_ARRAY_TASK_ID", "0"))
    path_data=IOBuffer()
    write(path_data,"{\"data\": [")
    cartoon = Dict{String, String}()
    history = Dict()
    for scenario in scenarios
        myvars = merge(vars, scenario)
        ss_total=Array{Array{Int64,2}}(undef, length(cell))
        gene_total=Array{Array{Int64,2}}(undef, length(cell))
        ch=Array{Dict{Symbol,Int64}}(undef, length(cell))
        for i=1:n_iter
            print(scenario["name"], "_", task_id, "_", i, "\n")
	    scen = scenario["name"]
            if client_id!=""
	        Pages.message("/uv_damage", client_id, "script", "progress(\"$scen\",\"$i\")")
            end
            Random.seed!(i - 1 + task_id*n_iter);
            (genes,ss,cartoon_data)=simulate(myvars, cell, record=i==1);
            if (i==1)
                cartoon[scenario["name"]] = cartoon_data
            end
            for gene_instance in keys(genes)
                if (i==1)
                    gene_total[gene_instance] =  genes[gene_instance].tally_matrix
                    ss_total[gene_instance] =  ss[gene_instance].tally_matrix
                    ch[gene_instance]=genes[gene_instance].history
                else
                    gene_total[gene_instance] .= gene_total[gene_instance] .+ genes[gene_instance].tally_matrix
                    ss_total[gene_instance] .= ss_total[gene_instance] .+ ss[gene_instance].tally_matrix
                    for (k,v) in genes[gene_instance].history
                        ch[gene_instance][k] += v
                    end
                end
            end
        end
        history[scenario["name"]] = Dict(cell[k]["name"] => Dict(k1 => v1/n_iter for (k1, v1) in ch[k]) for k in keys(ch))
        my_gene_vars = Dict(g => merge(myvars, cell[g]) for g in keys(cell))
        JSON.print(path_data, gene_total)
        if scenario!=scenarios[lastindex(scenarios)]
            write(path_data,",\n")
        end
    end
    # If a param is set in any scenario, report it for each scenario (grab default if necessary)
    set_in_scenarios =  map(x -> Dict(i => merge(vars, x)[i] for i in unique(vcat([collect(keys(s)) for s in scenarios]...))), scenarios)
    write(path_data,"],\n \"scenarios\": ")
    JSON.print(path_data, map(x -> Dict(v => Dict("Value"=>x[v], "Unit"=>var_units[v]) for v in keys(x)), set_in_scenarios))
    set_in_cell =  map(x -> Dict(i => merge(vars, x)[i] for i in unique(vcat([collect(keys(s)) for s in cell]...))), cell)
    write(path_data,",\n \"genes\": ")
    JSON.print(path_data, map(x -> Dict(v => Dict("Value"=>x[v], "Unit"=>var_units[v]) for v in keys(x)), set_in_cell))
    write(path_data, ",\n \"default\": ")
    JSON.print(path_data, Dict(v => Dict("Value"=>vars[v], "Unit"=>var_units[v]) for v in keys(vars)))
    write(path_data, ",\n \"cartoons\": ")
    JSON.print(path_data, Dict(v => JSON.parse(cartoon[v]) for v in keys(cartoon)))
    write(path_data, ",\n \"history\": ")
    JSON.print(path_data, history)
    write(path_data,"}\n")
    return String(take!(path_data))
end



end # module
