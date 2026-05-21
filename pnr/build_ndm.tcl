#=========================================================
# build_ndm.tcl -- generic two-NDM build for ICC2.
#
# Builds:
#   tech_ndm  -- tech file + parasitic tech (no cells)
#   cell_ndm  -- standard cells (.db timing + .lef physical)
#
# Run with: icc2_lm_shell -f pnr/build_ndm.tcl
#
# Required env vars:
#   TF_FILE    Milkyway .tf
#   TLU_FILE   StarRC .tluplus
#   DB_FILE    Liberty .db (cell timing)
#   LEF_FILE   .lef (cell physical)
#
# Optional env var:
#   NDM_OUT    output dir for the NDMs (default pnr/work/ndm)
#=========================================================

proc env_required {var} {
    if {![info exists ::env($var)]} {
        puts "ERROR: env var '$var' must be set"
        exit 1
    }
    return $::env($var)
}

set TF_FILE  [env_required TF_FILE]
set DB_FILE  [env_required DB_FILE]
set LEF_FILE [env_required LEF_FILE]
set TLU_FILE [env_required TLU_FILE]

if {[info exists ::env(NDM_OUT)]} {
    set NDM_OUT $::env(NDM_OUT)
} else {
    set NDM_OUT "pnr/work/ndm"
}

foreach f [list $TF_FILE $DB_FILE $LEF_FILE $TLU_FILE] {
    if {![file exists $f]} { puts "ERROR: missing file: $f"; exit 1 }
}

set TECH_OUT "$NDM_OUT/tech_ndm"
set CELL_OUT "$NDM_OUT/cell_ndm"
file mkdir $NDM_OUT
sh rm -rf $TECH_OUT
sh rm -rf $CELL_OUT

set_app_options -name lib.setting.use_tech_scale_factor -value true

# Step 1: tech NDM (.tf + .tlup, no cells)
create_workspace -flow normal -technology $TF_FILE tech_ndm_ws
read_parasitic_tech -tlup $TLU_FILE -name nominal
commit_workspace -output $TECH_OUT -force

# Step 2: cell NDM (timing .db + physical .lef on top of tech)
create_workspace -flow normal -technology $TF_FILE cell_ndm_ws
read_db $DB_FILE
read_lef $LEF_FILE
read_parasitic_tech -tlup $TLU_FILE -name nominal
report_workspace
check_workspace -allow_missing
commit_workspace -output $CELL_OUT -force

exit
