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
    "gene_length"       => 63kb,
    "initiation_period" => 2.5seconds,
    "uv_distance"       => 10kb,
    "run_length"        => 240minutes,
    "pol_speed"         => 2000bp/minutes,
    "pol_size"          => 33.0bp,
    "repair_half_life"  => 4hours,
    "processivity"      => 1hours,
    "removal"       => 10.0minutes,
    "pause_site"        => 60bp,
    "release_time"      => 3seconds,
    "speed_factor_t0"   => 1.0, # Factor by which speed changes upon damagage
    "pol_N"             => 20000, # Number of polymerases available initially for initiation
    "complete_reuse_p"  => 1, # Probability of transcript-complete pol re-entering pool
    "dropoff_reuse_p"   => 1, # Probability of incomplete-transcript pol re-entering pool
    "genome_prop"         => 1,
    "tally_interval"     => 3minutes,
    "tally_binsize"      => 1kb,
    "zero"              => 1e-10
)

const var_units = Dict{String, String}(
    "Type"       => "Active|All",
    "gene_length"       => "bp",
    "initiation_period" => "s",
    "uv_distance"       => "bp",
    "run_length"        => "s",
    "pol_speed"         => "bp/s",
    "pol_size"          => "bp",
    "repair_half_life"  => "s",
    "processivity"      => "s",
    "removal"           => "s",
    "pause_site"        => "bp",
    "release_time"      => "s",
    "speed_factor_t0"   => "", 
    "pol_N"             => "", 
    "complete_reuse_p"  => "", 
    "dropoff_reuse_p"   => "", 
    "genome_prop"         => "",
    "tally_interval"     => "NA",
    "tally_binsize"      => "NA",
    "zero"              => "NA",
    "name"              => "",
    "colour"            => ""
)

const scenarios = [
    Dict("name"=>"recycle", "pol_N" => 1000, "colour" => "#006400"),
    Dict("name"=>"degrad", "pol_N" => 1000, "dropoff_reuse_p" => 0.1, "colour" => "#8b0000"),
    Dict("name"=>"stall", "pol_N" => 1000,  "colour" => "#fa8072", "removal" => Inf),
    Dict("name"=>"nodamage", "pol_N" => 1000,  "colour" => "#0000ff", "uv_distance" => Inf,"removal" => Inf),
]


const cell = [
    Dict("name"=>"Long", "gene_length" => 100kb, "genome_prop" => 0.10, "colour" => "#0000ff"),
    Dict("name"=>"Medium", "gene_length" => 63kb, "genome_prop" => 0.20, "colour" => "#006400"),
    Dict("name"=>"Short", "gene_length" => 5kb, "genome_prop" => 0.70, "colour" => "#8b0000")
]


