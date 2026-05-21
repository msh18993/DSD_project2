#!/usr/bin/env bash
#
# run_sim.sh -- compile and run the cpu testbench against a given
# top-level DUT file (cpu_top.v).
#
# Usage:
#   sim/run_sim.sh <dut.v> [dut_module_name]
#
# Examples:
#   sim/run_sim.sh rtl/cpu_top.v
#   sim/run_sim.sh sample_answer/cpu_top.v
#   sim/run_sim.sh rtl/cpu_top.v cpu_top         # explicit override
#
# If the second arg is omitted, the module name is taken from the
# basename of the DUT file. The directory containing $DUT_FILE is
# added to the iverilog include path so the testbench's `include
# directives find cpu_top.v, imem.v, dmem.v, etc.

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <dut.v> [dut_module_name]" >&2
    exit 1
fi

DUT_FILE="$1"
DUT_MODULE="${2:-$(basename "$DUT_FILE" .v)}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORK_DIR="$SCRIPT_DIR/work"
mkdir -p "$WORK_DIR"
cd "$REPO_ROOT"

if [ ! -f "$DUT_FILE" ]; then
    echo "ERROR: DUT file not found: $DUT_FILE" >&2
    exit 1
fi

RTL_DIR="$(dirname "$DUT_FILE")"

echo "----------------------------------------------------------"
echo "  DUT file   : $DUT_FILE"
echo "  DUT module : $DUT_MODULE"
echo "----------------------------------------------------------"

iverilog -g2012 -I "$RTL_DIR" -o "$WORK_DIR/sim.out" tb/tb_cpu.v
vvp "$WORK_DIR/sim.out"
