# * Calculators for time to next event of each type
# *** Block - distance from each unrepaired damage site and it's immediately prior pol

function block_t(gene::Gene)
    if (length(gene.damage)>0)  && (gene.damage[1] > gene.pol_position[end])
        firstBefore = find_pol_before(gene.damage,  gene.pol_position)
        timeToNearest = [pl==0 ? Inf : (gene.damage[i] - gene.pol_position[pl])/gene.pol_speed[pl] for (i,pl) in enumerate(firstBefore)]
        (t,ind) = findmin(timeToNearest)
        if length(ind)!=1 ## Sometimes returns a 2d Cartesian Index.  Should probably rotate 'damage' so its a vector rather than a 1xn array
            ind=ind[2]
        end
        change_time!(gene.events.block, [t], ind)
    else
        change_time!(gene.events.block, [Inf], missing)
    end
    return nothing
end




# *** Pause - pol closest prior to pause site
# Need to double check the logic, and that a released pol won't get re-paused
function pause_t(gene::Gene)
    ##Pause
    ind = findprev(x -> x >= gene.vars["pause_site"], gene.pol_position, length(gene.pol_position))
    ind = ind==Nothing() ? 1 : ind+1
    if (ind <= length(gene.pol_position)) ||  (gene.pol_position[1] < gene.vars["pause_site"])
        change_time!(gene.events.pause, [(gene.vars["pause_site"]-gene.pol_position[ind])/(gene.pol_speed[ind])], ind)
    else
        change_time!(gene.events.pause, [Inf], missing)
    end
    return nothing
end

# *** Bump - if/when will each pol get caught by its immediate predecessor
function bump_t(gene::Gene)
    if (length(gene.pol_position) > 1) & any(x -> x=="active", gene.pol_state)
        (t,i)=crashtime(gene)
        change_time!(gene.events.bump, [t], i)
    else
        change_time!(gene.events.bump, [Inf], missing)
    end
    return nothing
end

# *** Complete - time taken for furthest pol to reach gene-length
function complete_t(gene::Gene)
    gene.events.complete.time[1] = (gene.vars["gene_length"]-gene.pol_position[1])/(gene.pol_speed[1])
    return nothing
end

## *** all_gone - if everything removed/processed then set pol-dependent events to infinity
function all_gone_t(gene::Gene)
    gene.events.complete.time[1]=Inf
    gene.events.block.time[1]=Inf
    gene.events.bump.time[1]=Inf
    gene.events.pause.time[1]=Inf
    return nothing
end


const time_handlers = Dict(
    :n0 => [block_t, complete_t, bump_t, pause_t], # =initiate when empty
    :all_gone => [all_gone_t], # = all pols removed through dissoc/degrad
    :initiate => [bump_t, pause_t],
    :block => [bump_t, complete_t, block_t],
    :bump => [bump_t, pause_t, block_t, complete_t],
    :release => [block_t, bump_t, pause_t, complete_t],
    :pause => [block_t, bump_t],
    :processivity => [block_t, bump_t, pause_t, complete_t],
    :dissoc => [block_t, bump_t, pause_t, complete_t],
    :degrad => [block_t, bump_t, pause_t, complete_t],
    :complete => [block_t, bump_t, pause_t, complete_t],
    :repair => [block_t, bump_t, pause_t, complete_t],
    :tally => []
)
