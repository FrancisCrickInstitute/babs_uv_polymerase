function update!(gene::Gene; events=fieldnames(EventSet))
    nexter=nextEvent(gene, events=events)
    gene.time += nexter[1]
    gene.history[nexter[2]] += 1
    timer_name = (length(gene.pol_position)==0) ? Symbol("n0") : nexter[2]
    update_prior_times(gene, nexter[1])
    event_handlers[nexter[2]](gene, getfield(gene.events, nexter[2]), nexter[1])
    timer_name = (length(gene.pol_position)==0) ? Symbol("all_gone") : timer_name
    update_times(gene, timer_name)
    return(nexter)
end

function nextEvent(gene::Gene; events=fieldnames(EventSet))
    # Each type of event has possibly many 'next' times.  The next event is the one which has the smallest min next time
    # returns a (time, symbol) pair
    nexter=(Inf, :n)
    for x in events
        ts=getfield(gene.events, x).time
        if (x == :dissoc || x == :degrad)
            ts = ts[gene.pol_state .!= "active"]
        end
        if length(ts)!=0
            t=minimum(ts)
            if t<nexter[1]
                nexter=(t,x)
            end
        end
    end
    return nexter
end


# ** Elapse time up until the current event
function update_prior_times(gene::Gene, willelapse::Float64)
    for i in eachindex(gene.pol_state)
        gene.events.processivity.time[i] -= willelapse
        if gene.pol_state[i] != "active"
            gene.events.dissoc.time[i] -= willelapse
            gene.events.degrad.time[i] -= willelapse
        end
    end
    gene.events.initiate.time[1] -= willelapse
    gene.events.pause.time[1] -= willelapse
    gene.events.complete.time[1] -= willelapse
    gene.events.release.time[1] -= willelapse
    gene.events.block.time[1] -= willelapse
    gene.events.bump.time[1] -= willelapse
    gene.events.tally.time[1] -= willelapse
    for i in eachindex(gene.events.repair.time)
        gene.events.repair.time[i] -= willelapse
    end
    return(nothing)
end

# ** Call all the time-to-event calculators required by the recent event
function update_times(gene::Gene, updater::Symbol)
    for fn in time_handlers[updater]
        fn(gene)
    end
    return(nothing)
end

        
# ** re-activate queued polymerases as one 
function update_speeds!(gene::Gene, ind::Int64)
    if ind>length(gene.pol_position)
        return nothing
    else
        ind_dequeue = find_chain(gene, ind, "queued")
          for i in ind_dequeue
              gene.pol_state[i] = "active"
              gene.pol_speed[i]=max(gene.default_speed, gene.pol_speed[i])
         end
    end
    return nothing
end
