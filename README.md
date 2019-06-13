# babs_uv_polymerase
## Description
A simulator of polymerase dynamics during transcription in the
presence of UV damage. Written in Julia and visualised in
Javascript/D3.

To model polymerase dynamics numerically, we implemented a
process-oriented simulator, continuous in time and location along
gene, but discrete in events. So a set of biological events (see
supplementary? table [1] for a complete list, but for example
repair, transcription completion, polymerase collision with a stalled
polymerase) each have a time associated with them. Between events,
transcription proceeds in a continuous manner, but when an event
occurs an abrupt update is made, and a fresh set of future events is
calculated to reflect this.

For each event in temporal turn, the state of the system is updated
using the natural mathematical rules (such as a polymerase position
being offset by the product of its speed and the time until the
event). Then the event is handled (e.g. polymerase's speed is set to
zero if the event is a collision).  Then the list of events is updated
in light of the previous two steps: e.g. in the collision case, the
next collision-time is recalculated to be the the time taken for the
polymerase immediately prior to the one stalled to reach the it; but
time-to-repair is simply reduced by the amount of time elapsed prior
to the collision event.

The events are then re-sorted to find the event that is going to
happen next in time, and the process is repeated until the required
amount of time has elapsed. 

The overall state of the system is a small number of representative
genes, and a number of polymerases, each either positioned along one
of the genes or available for initiation on any of the genes. There is
an initial period to achieve steady state, where polymerases are
allowed to initiate on the genes (weighted, to allow different
proportions of the gene classes) and progress along the gene body
without any damage sites. When equilibrium is achieved in terms of
initiation and completion, damage sites are introduced at random
locations and for random durations (tunable by the user) which will
halt any polymerase that encounters them.

Moving polymerases have a probability of being removed from the
gene-body at any moment in time; halted polymerases (at a damage site,
or in a queue forming to its 3' side) can have an increased risk.
Also, upon removal polymerases have a probability of being returned to
the pool of polymerases available for initiation, or conversely being
degraded. A separate parameter is available to similarly determine the
fate of polymerases that have completed transcription.

As the damage sites are stochastic, we run the simulation
independently one hundred times to achieve an estimate of polymerase
density across the gene bodies of a pool of cells.

The dynamics, and the impact each event has, are tunable by the set of
parameters given in table 2.

### Table 1

| Event | Description | Calculation | Impact | Notes |
| ----- | ----------- | ----------- | ------ | ----- |
|initiate | Polymerase attempts to initiate | Exponential-random, depending on baseline rate, and number of existing polymerases | New polymerase added to 5' end of gene | When the event happens, another one is scheduled with the required characteristics. |
|block | Polymerase arrives at damage site | Minimum across polymerase:damage-site pairs of distance/speed | Speed of affected polymerase will be set to zero | A safe lower bound, as events that would alter it will necessarily happen first, inducing a recalculation.  |
|bump | Polymerase catches up with 5' neighbour | Minimum across polymerases of delta_distance/delta_speed | " | |
|pause | Polymerase reaches pause site| based on 5'-most polymerase prior to pause site | " |  |
|release | Paused polymerase will be released from pause site| User-specified time after it first paused | Affected polymerase will have speed restored to default. | |
|processivity | Polymerase removed from gene prematurely| Upon initiation, each polymerase is given an stochastic duration it is allowed to spend on the gene. | Polymerase will either be made available for initiation, or discarded entirely via Bernoulli probability.| |
|complete | Polymerase successfully reaches the full gene length | Minimum across polymerases of distance-to-end/speed | " | | 
|repair | UV damage site will be removed | At t_0, each (random) damage site is allocated an exponentially-distributed random lifetime. | Speed of 3' (queue of) polymerases restored to default | 

### Table 2

| Parameter | Description | Default Value |
|---------- | ----------- | ------------- |
| gene_length | Number of bases a polymerases must traverse to transcribe a gene | 63kb |
| initiation_period | Expected duration between initiation attempts | 2.5seconds |
| uv_distance | Expected distance between damage sites | 10kb |
| run_length | How long to simulate the dynamics | 240minutes |
| pol_speed | Default speed of a polymerase| 2000bp/minutes |
| pol_size | How many bases a polymerase occupies | 33.0bp |
| repair_half_life | Time after half the damage sites are expected to have been repaired | 4hours |
| processivity | Expected duration a moving polymerase can remain on a gene | 1hours |
| removal | Expected duration a stalled polymerase can remain on a gene | 10.0minutes |
| pause_site | Distance from TSS where each polymerase will pause  | 60bp |
| release_time | How long each polymerase will wait at the pause site| 3seconds |
| speed_factor_t0 | Polymerases will speed up by this factor when transitioning from steady state to damaged state | 1.0 | 
| pol_N | The number of polymerases in the pool available for initiation in steady state| 20000 |
| complete_reuse_p | Probability a polymerase will be available for initiation once it has completed transcription| 1 | 
| dropoff_reuse_p | Probability a polymerase will be available for initiation if it is removed prematurely| 1 | 
| genome_prop | What proportion of genes in the genome are characterised by this set of parameters | 1 |
| Type |Whether to include stationery polymerases in the calculation of density | Active |
| tally_interval |How frequently to record and draw the density information | 3minutes |
| tally_binsize |How granular to make the density information | 1kb |


## Installation
Once the package is cloned, a Dockerfile is available to start a web
front-end that allows the user to interact with the settings of the
simulation and to view the results.

## Availability
We currently have the following instances available for interactively
using the simulator:
* [Francis Crick Institute](http://51.145.52.51:8000/uv_damage)

## Usage
