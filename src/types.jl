mutable struct indexed_event
time::Vector{Float64}
index::Union{Missing,Int64}
end

function indexed_event(a::Float64)
    indexed_event([a], missing)
end
function indexed_event(a::Float64, Int64)
    indexed_event([a], i)
end

function indexed_event(a::Array{Float64})
    indexed_event(a, missing)
end
function indexed_event()
    indexed_event(Inf::Float64)
end

function change_time!(a::indexed_event, t::Vector{Float64}, ind::Union{Missing,Int64})
    a.time=t
    a.index=ind
    return nothing
end

function Base.getindex(e::indexed_event, i)
    indexed_event(e.time[i], e.index)
end
function Base.setindex!(e::indexed_event, i, v)
    e.time[i]=v
end
function Base.length(e::indexed_event)
    length(e.time)
end


# *** EventSet - all things that can happen to a polymerase and when
struct EventSet
initiate      ::indexed_event
block         ::indexed_event
bump          ::indexed_event
release       ::indexed_event
pause         ::indexed_event
tally          ::indexed_event
processivity  ::indexed_event
dissoc        ::indexed_event
degrad        ::indexed_event
complete      ::indexed_event
repair        ::indexed_event
    EventSet(;initiate=indexed_event(), block=indexed_event(), bump=indexed_event(), release=indexed_event(), pause=indexed_event(), tally=indexed_event(), processivity=indexed_event(Float64[]), dissoc=indexed_event(Float64[]), degrad=indexed_event(Float64[]), complete=indexed_event(), repair=indexed_event()) =
        new(initiate, block, bump, release, pause, tally, processivity, dissoc, degrad, complete, repair)
end


# ***  Gene - contains polymerase state, all scheduled events, and a history log
mutable struct Gene
events                 ::EventSet
damage                 ::Array{Float64}
pol_position           ::Vector{Float64}
pol_speed              ::Vector{Float64}
pol_state              ::Vector{String}
pol_id                 ::Vector{Int64}
next_id                ::Int64
pol_N                  ::Float64
default_speed          ::Float64
tally_matrix            ::Array{Int64,2}
time                   ::Float64
vars                   ::Dict
history                ::Dict
loci                   ::Vector{Int64}
freedPols              ::Int64
end

function Gene(vars::Dict)
#    damage = find(rand(vars["gene_length"]) .< 1/vars["uv_distance"])
    damage= unique(rand(DiscreteUniform(1,vars["gene_length"]), rand(Binomial(vars["gene_length"], 1/vars["uv_distance"]))))
    #    damage = reshape(Float64.(damage), (1, length(damage)))
    damage=reverse(sort(damage))
#    rate = log(2)/vars["repair_half_life"]
    repair_times = random_time(vars["repair_half_life"]/log(2),
                               length(damage))
    repairevent = indexed_event(repair_times,(length(damage)==0) ? missing : argmin(repair_times))
    events = EventSet(
    initiate = indexed_event(random_time(vars["initiation_period"],1)),
    repair = repairevent,
    tally = indexed_event(Float64(0))
    )
    loci = vcat(damage, 0, vars["pause_site"], vars["gene_length"])
    loci = reverse(sort(loci))
    hist = Dict(i => 0 for i = fieldnames(EventSet))
    hist[:failed]=0
    Gene(events,
         damage,
         Float64[],
         Float64[],
         String[],
         Int64[],
         1,
         vars["pol_N"],
         vars["pol_speed"],
         zeros(Float64,div(vars["gene_length"], vars["tally_binsize"]),
                round(Int, vars["run_length"]/vars["tally_interval"])+2),
         0.0,
         vars,
         hist,
         loci,
         0
         )
end



function Base.show(gene::Gene; n=min(6, length(gene.pol_position)))
    if length(gene.pol_position)>0
        print("Position: ", gene.pol_position[1:n], "\n")
        print("Speed: ", gene.pol_speed[1:n], "\n")
        print("State: ", gene.pol_state[1:n], "\n")
    end
    nexter = Dict(x => minimum(getfield(gene.events, x).time) for x in fieldnames(gene.events) if length(getfield(gene.events,x)) != 0)
    print(sort(collect(nexter), by=x->x[2]), "\n")
    print(collect(keys(nexter))[argmin(collect(values(nexter)))], "\n")
    print(gene.history, "\n")
    print(join(getindex.(gene.pol_state,1)), "\n")
end


