#!/usr/bin/env bash
#
# run_sta.sh -- PrimeTime sign-off STA wrapper.
#
# Required positional args:
#   $1  top module name
#
# Optional env vars:
#   NETLIST    default pnr/output/<dut_top>.pnr.v
#   SPEF_FILE  default pnr/output/<dut_top>.pnr.spef.nominal_25.spef
#   SDC_FILE   default syn/work/<dut_top>.sdc

set -euo pipefail

if [ $# -lt 1 ]; then echo "Usage: $0 <dut_top>" >&2; exit 1; fi
DUT_TOP="$1"

NETLIST="${NETLIST:-pnr/output/${DUT_TOP}.pnr.v}"
SPEF_FILE="${SPEF_FILE:-pnr/output/${DUT_TOP}.pnr.spef.nominal_25.spef}"
SDC_FILE="${SDC_FILE:-syn/work/${DUT_TOP}.sdc}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

export DUT_TOP NETLIST SPEF_FILE SDC_FILE

pt_shell -f sta/sta.tcl | tee sta/sta.log
