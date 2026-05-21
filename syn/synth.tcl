#=========================================================
# synth.tcl -- Synopsys Design Compiler synthesis flow.
# Project 2: top-file references its sub-modules via `include
# directives, so SEARCH_PATH must point at the directory holding
# them.
#
# Run with: dc_shell -f syn/synth.tcl
#
# Required env vars:
#   DB_FILE     timing library (.db)
#   DUT_FILE    RTL .v (top file; sub-modules pulled in via `include)
#   DUT_TOP     top module name
#   SDC_FILE    SDC constraints file
#
# Optional:
#   SEARCH_PATH whitespace-separated dirs added to search_path
#               (default: directory containing DUT_FILE)
#=========================================================

proc env_required {var} {
    if {![info exists ::env($var)]} {
        puts "ERROR: env var '$var' must be set"; exit 1
    }
    return $::env($var)
}

set DB_FILE  [env_required DB_FILE]
set DUT_FILE [env_required DUT_FILE]
set DUT_TOP  [env_required DUT_TOP]
set SDC_FILE [env_required SDC_FILE]

foreach f [list $DB_FILE $DUT_FILE $SDC_FILE] {
    if {![file exists $f]} { puts "ERROR: missing file: $f"; exit 1 }
}

set target_library [list $DB_FILE]
if {[info exists ::env(SYNTHETIC_LIBRARY)]} {
    set synthetic_library $::env(SYNTHETIC_LIBRARY)
} else {
    set synthetic_library [list]
}
set link_library [concat [list "*" $DB_FILE] $synthetic_library]

# search_path for `include resolution.
if {[info exists ::env(SEARCH_PATH)]} {
    set extra_dirs [split $::env(SEARCH_PATH)]
} else {
    set extra_dirs [list [file dirname $DUT_FILE]]
}
foreach d $extra_dirs {
    if {$d ne "" && [file isdirectory $d]} {
        set search_path [concat $search_path [list $d]]
    }
}

set OUT_DIR "syn/work"
set RPT_DIR "syn/reports"
file mkdir $OUT_DIR
file mkdir $RPT_DIR

sh rm -rf $OUT_DIR/.WORK
sh mkdir -p $OUT_DIR/.WORK
define_design_lib WORK -path $OUT_DIR/.WORK

analyze -format verilog -library WORK [list $DUT_FILE]
elaborate $DUT_TOP
current_design $DUT_TOP
link

write -format ddc -hierarchy -output $OUT_DIR/${DUT_TOP}_elab.ddc

source -echo -verbose $SDC_FILE

if {[info exists ::env(DC_DONT_USE)] && [llength $synthetic_library] > 0} {
    foreach _patt [split $::env(DC_DONT_USE)] {
        if {$_patt ne ""} { catch {set_dont_use $_patt} }
    }
}

uniquify
compile_ultra -no_autoungroup -no_boundary_optimization

report_qor                                 > $RPT_DIR/${DUT_TOP}_qor.rpt
report_timing -significant_digits 6        > $RPT_DIR/${DUT_TOP}_timing.rpt
report_clock                               > $RPT_DIR/${DUT_TOP}_clock.rpt
report_power -significant_digits 6         > $RPT_DIR/${DUT_TOP}_power.rpt
report_area -hierarchy                     > $RPT_DIR/${DUT_TOP}_area.rpt
report_reference -hierarchy                > $RPT_DIR/${DUT_TOP}_reference.rpt

set_propagated_clock [all_clocks]
write_sdc -version 1.9 $OUT_DIR/${DUT_TOP}.sdc
write -hierarchy -format verilog -output $OUT_DIR/${DUT_TOP}.netlist.v
write -hierarchy -format ddc     -output $OUT_DIR/${DUT_TOP}.compile.ddc

exit
