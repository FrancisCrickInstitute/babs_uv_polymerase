# * Event Behaviours
# All will take the current gene, a (time, index) pair and an amount of time from previous to this event
# *** Initiate - if space, add polymerase, else record an initiation-failed
function initiate(gene::Gene, event::indexed_event, elapsed::Float64)
    move_pols!(gene, elapsed)
    if length(gene.pol_position)==0 || gene.pol_position[end] -1 >= gene.vars["pol_size"] # Failed initiation due to occupancy
        add_pol!(gene)
    else
        gene.history[:failed] += 1
    end
    # When will next initiation occur - a poisson time with a rate that decays
    #event.time[1] = random_time(gene.vars["initiation_period"] * 2^(gene.time/gene.vars["doubling_time"]))[1]
    # When will next initiation occur - derived from number of free polymerases in just for this instance
    ##event.time[1] = random_time(gene.vars["initiation_period"] * gene.vars["pol_N"] / gene.pol_N)[1]
    # When will next initiation occur - derived from number of free polymerases in environment context
    event.time[1] = random_time(gene.vars["initiation_period"] * gene.vars["pol_N"] / gene.pol_N )[1]
    return(nothing)
end
        
# *** Pause - set speed to zero, and trigger an iminent release
function pause(gene::Gene, event::indexed_event, elapsed::Float64)
    move_pols!(gene, elapsed)
    gene.pol_speed[event.index] = 0
    gene.pol_state[event.index] = "paused"
    gene.events.release.time[1] =  gene.vars["release_time"]
    gene.events.pause.time[1] = Inf
    return(nothing)
end

# *** Release - reset speed (of whole pause-train if necessary)
function release(gene::Gene, event::indexed_event, elapsed::Float64)
    move_pols!(gene, elapsed)
#    update_speeds!(gene, findfirst(gene.pol_state .== "paused"))
    update_speeds!(gene, findfirst(x -> x=="paused", gene.pol_state))
    gene.events.release.time[1] = Inf
    return(nothing)
end
  
# *** Block - set speed of approaching pol to zero  
function block(gene::Gene, event::indexed_event, elapsed::Float64)
#    ind = findfirst(gene.pol_position .< gene.damage[event.index])
    ind = findfirst(x -> x < gene.damage[event.index], gene.pol_position)
    move_pols!(gene, elapsed)
    gene.pol_state[ind] = "blocked"
    gene.pol_speed[ind] = 0
    return(nothing)
end
    
# *** Bump - set speed (of whole pol-train) to speed of obstructing pol (prob always zero)
function bump(gene::Gene, event::indexed_event, elapsed::Float64)
    move_pols!(gene, elapsed)
    chain = find_chain(gene, event.index, "active")
    gene.pol_speed[chain] .= gene.pol_speed[event.index-1]
    if gene.pol_state[event.index-1]!="active"
        gene.pol_state[chain] .= "queued"
    end
    return(nothing)
end

# *** Repair - Remove block, and free up any necessary pols
function repair(gene::Gene, event::indexed_event, elapsed::Float64)
    # Is this inequality correct
    ind_pol = findfirst((gene.pol_state.=="blocked") .& (gene.pol_position .<= gene.damage[event.index]+gene.vars["zero"]) )
    move_pols!(gene, elapsed)
    if (ind_pol !=nothing) && (gene.damage[event.index] - gene.pol_position[ind_pol] <= gene.vars["pol_size"])
        gene.pol_speed[ind_pol]= gene.default_speed
        update_speeds!(gene, ind_pol)   
    end
    gene.damage=deleteat!(vec(gene.damage),event.index)'
    if length(gene.damage)==0
        change_time!(gene.events.repair, [Inf], missing)
    else
        deleteat!(gene.events.repair.time,event.index)
        gene.events.repair.index = argmin(gene.events.repair.time)
    end
    return(nothing)
end

# *** Processivity  - remove polymerase
function processivity(gene::Gene, event::indexed_event, elapsed::Float64)
    ind = argmin(event.time)
    move_pols!(gene, elapsed)
    if gene.pol_state[ind] == "paused"
        gene.events.release.time[1] = Inf
        gene.events.pause.time[1] = Inf
    end
    update_speeds!(gene, ind)
#    remove_pol!(gene, ind, prob=gene.vars["dropoff_reuse_p"])
#    p_reuse = (1/(gene.vars["dissoc"])) / (1/(gene.vars["dissoc"]) + 1/(gene.vars["degrad"]))
    remove_pol!(gene, ind, prob=1)
    return(nothing)
end



# *** Removal - same as processivity
function degrad(gene::Gene, event::indexed_event, elapsed::Float64)
    ind = argmin(event.time)
    move_pols!(gene, elapsed)
    if gene.pol_state[ind] == "paused"
        gene.events.release.time[1] = Inf
        gene.events.pause.time[1] = Inf
    end
    update_speeds!(gene, ind)
    remove_pol!(gene, ind, prob=0)
    return(nothing)
end

function dissoc(gene::Gene, event::indexed_event, elapsed::Float64)
    ind = argmin(event.time)
    move_pols!(gene, elapsed)
    if gene.pol_state[ind] == "paused"
        gene.events.release.time[1] = Inf
        gene.events.pause.time[1] = Inf
    end
    update_speeds!(gene, ind)
    remove_pol!(gene, ind, prob=1)
    return(nothing)
end


# *** Complete - remove pol, and record completion event
function complete(gene::Gene, event::indexed_event, elapsed::Float64)
    move_pols!(gene, elapsed)
    remove_pol!(gene, 1, prob=gene.vars["complete_reuse_p"])
#    push!(gene.transcription_complete, gene.time)
    return(nothing)
end

# *** Tally - periodically record number of polymerases at each chromosomal bin
function tally(gene::Gene, event::indexed_event, elapsed::Float64)
    move_pols!(gene, elapsed)
    gene.events.tally.time[1] += gene.vars["tally_interval"]
    if gene.vars["Type"]==0
        bin = [div(floor(Int, posn-1), gene.vars["tally_binsize"]) for (i,posn) in enumerate(gene.pol_position) if gene.pol_state[i]=="active"]
    else
        bin = div.(floor.(Int, gene.pol_position.-1), gene.vars["tally_binsize"])
    end
    if (length(bin)!=0)
        gene.tally_matrix[:,1+gene.history[:tally]] .= counts(bin, UnitRange(0,size(gene.tally_matrix,1)-1))
    end
    return(nothing)
end

const event_handlers = Dict(x => getfield(uv_damage, x) for x in fieldnames(EventSet))
