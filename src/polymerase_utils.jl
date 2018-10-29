# * Utility functions for pol dynamics

# ** Move all active polymerases at their correct speed
function move_pols!(gene::Gene, delta_t::Float64)
    for ind in eachindex(gene.pol_position)
        if gene.pol_state[ind] == "active"
            gene.pol_position[ind] += delta_t * gene.pol_speed[ind]
        end
    end
    return(nothing)
end
    
# ** Which moving pol is going to crash into it's predecessor first, and when 
function crashtime(gene::Gene)
    # 'i+1' is closer to TSS
    m::Float64=Inf
    ind=0
    for i=1:length(gene.pol_speed)-1
        if (gene.pol_speed[i+1] > gene.pol_speed[i])
            t = (gene.pol_position[i] - gene.pol_position[i+1] - gene.vars["pol_size"])/(gene.pol_speed[i+1] - gene.pol_speed[i])
            if t<m
                m=t
                ind=i+1
            end
        end
    end
    if ind==0
        return((Inf, missing))
    else
        return((m,ind))
    end
end


# ** Find a touching train of polymerases    

function find_chain(gene::Gene, ind::Int64, chaintype::String)
    ## Used in update_speeds to speed up (following release, repair, processivity, removal) a whole chain
    ## Used in bump to slow down a whole chain
    if ind==length(gene.pol_position)
        return(ind:ind)
    end
    i=ind
    while (i<length(gene.pol_position)) &&
#        (gene.pol_position[i]-gene.pol_position[i+1] < gene.vars["pol_size"] + gene.vars["zero"]) &&
        (gene.pol_position[i]-gene.pol_position[i+1] <= gene.vars["pol_size"]) &&
        (gene.pol_state[i+1]==chaintype)
        i += 1
    end
    return(ind:i)
end


function add_pol!(gene::Gene; pos=1.0, speed=gene.default_speed) 
    push!(gene.pol_position, pos)
    push!(gene.pol_speed, speed)
    push!(gene.pol_state, "active")
    gene.next_id += 1
    push!(gene.pol_id, gene.next_id)
    push!(gene.events.processivity.time, random_time(gene.vars["processivity"])[1])
    push!(gene.events.removal.time, random_time(gene.vars["removal"])[1])
    gene.freedPols=-1
    return(nothing)
end

function remove_pol!(gene::Gene,ind::Int64; prob=.8)
    deleteat!(gene.pol_position, ind)
    deleteat!(gene.pol_speed, ind)
    deleteat!(gene.pol_state, ind)
    deleteat!(gene.pol_id, ind)
    deleteat!(gene.events.processivity.time, ind)
    deleteat!(gene.events.removal.time, ind)
    gene.freedPols = rand(Bernoulli(prob)) # prob is probability of a 1
    return(nothing)
end

function random_time(mean_time, n=1)
    if !(mean_time>0)
        print(mean_time)
    end
    rand(Exponential(mean_time), n)
end

# could replace block-pol finder
function find_pol_before(dam, pl)
    res = fill!(similar(dam, Int64),0)
    dind=1
    pind=1
    plen=length(pl)
    dlen=length(dam)
    while (pind <= plen)
        while (dind <= dlen) && (pl[pind] < dam[dind])
            res[dind]=pind
            dind += 1
        end
        pind += 1
    end
    return res
end
