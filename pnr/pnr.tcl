#=========================================================
# pnr.tcl -- generic Synopsys IC Compiler II PnR flow.
#
# Run with: icc2_shell -f pnr/pnr.tcl
# Prerequisite: pnr/build_ndm.tcl already run.
#
# Required env vars:
#   TF_FILE       Milkyway .tf
#   TLU_FILE      StarRC .tluplus
#   DUT_TOP       top module name
#   NETLIST       gate-level netlist .v from synthesis
#   SDC_FILE      SDC from synthesis
#   CORE_UTIL     floorplan core utilization
#   CORNER_NAME   name to use for the ICC2 corner
#   VOLTAGE       operating voltage in V
#   TEMPERATURE   operating temperature in C
#
# Optional env vars:
#   NDM_DIR       NDM root (default pnr/work/ndm)
#
# Outputs:
#   pnr/output/${DUT_TOP}.pnr.v                post-route netlist
#   pnr/output/${DUT_TOP}.pnr.spef.<...>.spef  parasitics
#   pnr/work/${DUT_TOP}.dlib/                  ICC2 design library
#   pnr/reports/*.rpt
#=========================================================

proc env_required {var} {
    if {![info exists ::env($var)]} {
        puts "ERROR: env var '$var' must be set"
        exit 1
    }
    return $::env($var)
}

set TF_FILE     [env_required TF_FILE]
set TLU_FILE    [env_required TLU_FILE]
set DUT_TOP     [env_required DUT_TOP]
set NETLIST     [env_required NETLIST]
set SDC_FILE    [env_required SDC_FILE]
set CORE_UTIL   [env_required CORE_UTIL]
set CORNER_NAME [env_required CORNER_NAME]
set VOLTAGE     [env_required VOLTAGE]
set TEMPERATURE [env_required TEMPERATURE]

if {[info exists ::env(NDM_DIR)]} {
    set NDM_DIR $::env(NDM_DIR)
} else {
    set NDM_DIR "pnr/work/ndm"
}
set TECH_NDM "$NDM_DIR/tech_ndm"
set CELL_NDM "$NDM_DIR/cell_ndm"

foreach f [list $TF_FILE $TLU_FILE $NETLIST $SDC_FILE] {
    if {![file exists $f]} { puts "ERROR: missing file: $f"; exit 1 }
}
foreach d [list $TECH_NDM $CELL_NDM] {
    if {![file isdirectory $d]} {
        puts "ERROR: NDM not found: $d (run pnr/build_ndm.tcl first)"
        exit 1
    }
}

set OUT_DIR "pnr/output"
set WRK_DIR "pnr/work"
set RPT_DIR "pnr/reports"
file mkdir $OUT_DIR
file mkdir $WRK_DIR
file mkdir $RPT_DIR

set DLIB_NAME "${DUT_TOP}.dlib"
set DLIB_PATH "$WRK_DIR/${DLIB_NAME}"
sh rm -rf $DLIB_PATH

create_lib -technology $TF_FILE -ref_libs [list $TECH_NDM $CELL_NDM] $DLIB_PATH
read_verilog -library $DLIB_NAME -design $DUT_TOP -top $DUT_TOP $NETLIST
link_block

set_user_units -type time -value 1ns
set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction horizontal
set_attribute [get_layers {M2 M4 M6 M8}]    routing_direction vertical
set_ignored_layers -min_routing_layer M1 -max_routing_layer M8

set MODE_NAME     "func"
set SCENARIO_NAME "${MODE_NAME}_${CORNER_NAME}"

remove_modes     -all
remove_corners   -all
remove_scenarios -all
create_mode     $MODE_NAME
create_corner   $CORNER_NAME
create_scenario -mode $MODE_NAME -corner $CORNER_NAME -name $SCENARIO_NAME
current_mode     $MODE_NAME
current_corner   $CORNER_NAME
current_scenario $SCENARIO_NAME

read_parasitic_tech -tlup $TLU_FILE -name nominal
set_voltage $VOLTAGE     -object_list VDD
set_voltage 0            -object_list VSS
set_temperature -corners [current_corner] $TEMPERATURE
set_parasitic_parameters -corners [current_corner] -early_spec nominal -late_spec nominal

read_sdc $SDC_FILE

set_scenario_status $SCENARIO_NAME \
    -active true -setup true -hold false \
    -leakage_power false -dynamic_power false \
    -max_transition true -max_capacitance true -min_capacitance true

initialize_floorplan -core_utilization $CORE_UTIL \
                     -side_ratio {1 1} \
                     -row_core_ratio 1

place_opt
report_qor                          > $RPT_DIR/${DUT_TOP}_qor_postplace.rpt
report_timing -delay max -nworst 5  > $RPT_DIR/${DUT_TOP}_timing_postplace.rpt
save_block

clock_opt
report_qor                          > $RPT_DIR/${DUT_TOP}_qor_postcts.rpt
report_timing -delay max -nworst 5  > $RPT_DIR/${DUT_TOP}_timing_postcts.rpt
save_block

route_auto
route_opt

report_qor                          > $RPT_DIR/${DUT_TOP}_qor.rpt
report_timing -delay max -nworst 10 > $RPT_DIR/${DUT_TOP}_timing.rpt
report_design -summary              > $RPT_DIR/${DUT_TOP}_design.rpt
report_power                        > $RPT_DIR/${DUT_TOP}_power.rpt
report_clock_qor                    > $RPT_DIR/${DUT_TOP}_clock.rpt

write_verilog "$OUT_DIR/${DUT_TOP}.pnr.v"
write_parasitics -format spef -output "$OUT_DIR/${DUT_TOP}.pnr.spef"

save_block
save_lib

exit
