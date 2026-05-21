#=========================================================
# sta.tcl -- generic Synopsys PrimeTime sign-off STA flow.
#
# Run with: pt_shell -f sta/sta.tcl
#
# Required env vars:
#   DUT_TOP     top module name
#   NETLIST     post-route netlist .v
#   SPEF_FILE   parasitics .spef
#   SDC_FILE    SDC
#=========================================================

proc env_required {var} {
    if {![info exists ::env($var)]} {
        puts "ERROR: env var '$var' must be set"
        exit 1
    }
    return $::env($var)
}

set DB_FILE   "/home/CAD/tech/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt0p85v25c.db"
# (Note: PT prints PT-063 "Library Compiler executable path is not set"
#  at startup. It's harmless; lc_shell isn't used by our analyses.)
set DUT_TOP   [env_required DUT_TOP]
set NETLIST   [env_required NETLIST]
set SPEF_FILE [env_required SPEF_FILE]
set SDC_FILE  [env_required SDC_FILE]

foreach f [list $DB_FILE $NETLIST $SPEF_FILE $SDC_FILE] {
    if {![file exists $f]} { puts "ERROR: missing file: $f"; exit 1 }
}

set RPT_DIR "sta/reports"
file mkdir $RPT_DIR

set link_library   "* $DB_FILE"
set target_library "$DB_FILE"

read_verilog $NETLIST
current_design $DUT_TOP
link_design

read_sdc $SDC_FILE
read_parasitics -format spef $SPEF_FILE
report_annotated_parasitics -check > $RPT_DIR/${DUT_TOP}_annotation.rpt

set timing_save_pin_arrival_and_slack    true
set timing_save_pin_arrival_and_required true

report_units                                                          > $RPT_DIR/${DUT_TOP}_units.rpt
report_clock                                                          > $RPT_DIR/${DUT_TOP}_clock.rpt
report_timing -delay max -nworst 10 -capacitance -transition_time     > $RPT_DIR/${DUT_TOP}_timing.rpt
report_qor                                                            > $RPT_DIR/${DUT_TOP}_qor.rpt

set power_enable_analysis true
set power_analysis_mode   averaged
update_power
report_power -verbose > $RPT_DIR/${DUT_TOP}_power.rpt

# Save session so you can reopen it in the PT GUI:
#   pt_shell -gui
#   pt_shell> restore_session sta/work/${DUT_TOP}_session
set SES_DIR "sta/work/${DUT_TOP}_session"
file mkdir [file dirname $SES_DIR]
save_session $SES_DIR

exit
