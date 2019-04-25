# Needs to provide:
# vars        - baseline parameters for gene
# var_units   - units for web-form, rows with NAs don't get printed
# scenarios   - Dictionary of sets of modifications to vars
# cell        - Dictionary of genes' modifications to vars


const seconds=1.0
const minutes=60seconds
const hours=60minutes
const bp=1
const kb=1000bp

const vars = Dict{String, Any}(
    "Type"       => 0,
    "gene_length"       => 100kb,
    "initiation_period" => 2.5seconds,
    "uv_distance"       => Inf,
    "run_length"        => 14400seconds,
    "pol_speed"         => 2000bp/minutes,
    "pol_size"          => 33.33bp,
    "repair_half_life"  => 4hours,
    "processivity"      => 7200seconds,
    "removal"       => Inf,
    "pause_site"        => 60bp,
    "release_time"      => 3seconds,
    "speed_factor_t0"   => 1.0, # Factor by which speed changes upon damagage
    "pol_N"             => 250, # Number of polymerases available initially for initiation
    "complete_reuse_p"  => 1, # Probability of transcript-complete pol re-entering pool
    "dropoff_reuse_p"   => 1, # Probability of incomplete-transcript pol re-entering pool
    "genome_prop"         => 1,
    "tally_interval"     => 3minutes,
    "tally_binsize"      => 1kb,
    "zero"              => 1e-10
)

const var_units = Dict{String, String}(
    "Type"       => "Active|All",
    "gene_length"       => "NA",
    "initiation_period" => "s",
    "uv_distance"       => "NA",
    "run_length"        => "s",
    "pol_speed"         => "bp/s",
    "pol_size"          => "NA",
    "repair_half_life"  => "NA",
    "processivity"      => "s",
    "removal"           => "NA",
    "pause_site"        => "NA",
    "release_time"      => "s",
    "speed_factor_t0"   => "", 
    "pol_N"             => "NA", 
    "complete_reuse_p"  => "NA", 
    "dropoff_reuse_p"   => "NA", 
    "genome_prop"         => "",
    "tally_interval"     => "NA",
    "tally_binsize"      => "NA",
    "zero"              => "NA",
    "name"              => "",
    "colour"            => ""
)

const scenarios = [
    Dict("name"=>"Default",  "gene_length"=>100kb, "colour" => "#006400")
]


const cell = [
    Dict("name"=>"Standard",  "genome_prop" => 1, "colour" => "#0000ff")
]


