#=========================================================
# cpu_top.sdc -- timing constraints for project2 cpu_top.
# Sourced by syn/synth.tcl; CLK_PERIOD comes from env.
#=========================================================

create_clock -name CLK -period $::env(CLK_PERIOD) [get_ports CLK]

set_dont_touch    [get_ports RSTN]
set_ideal_network [get_ports RSTN]
set_false_path -from [get_ports RSTN]

set IN_DELAY  [expr 0.3 * $::env(CLK_PERIOD)]
set OUT_DELAY [expr 0.3 * $::env(CLK_PERIOD)]

set_input_delay  $IN_DELAY  -clock CLK [get_ports {INSTR DRDATA}]
set_output_delay $OUT_DELAY -clock CLK [get_ports {IADDR IREQ DADDR DREQ DRW DWDATA CONSIG}]

if {[info exists ::env(DRIVE_CELL)]} {
    set_driving_cell -lib_cell $::env(DRIVE_CELL) [get_ports {INSTR DRDATA}]
}
set_load 0.005 [get_ports {IADDR IREQ DADDR DREQ DRW DWDATA CONSIG}]

set_max_fanout 20 [current_design]
