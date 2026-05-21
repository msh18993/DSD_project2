#!/usr/bin/env bash
#
# run_pnr.sh -- ICC2 PnR wrapper.
#
# Required env vars (set by caller, e.g. via setup_<pdk>.sh):
#   TF_FILE       Milkyway .tf
#   TLU_FILE      StarRC .tluplus
#   DB_FILE       Liberty .db (only used during one-time NDM build)
#   LEF_FILE      .lef        (only used during one-time NDM build)
#   CORNER_NAME   name to use for the ICC2 corner
#   VOLTAGE       operating voltage in V
#   TEMPERATURE   operating temperature in C
#
# Required positional args:
#   $1  top module name
#
# Optional env vars:
#   NETLIST    default syn/work/<dut_top>.netlist.v
#   SDC_FILE   default syn/work/<dut_top>.sdc
#   CORE_UTIL  default 0.6
#   NDM_DIR    default pnr/work/ndm
#
# Builds the cell NDM library on first run (one-time).

set -euo pipefail

require_env () {
    local v="$1"
    if [ -z "${!v:-}" ]; then echo "ERROR: env var '$v' must be set" >&2; exit 1; fi
}

if [ $# -lt 1 ]; then echo "Usage: $0 <dut_top>" >&2; exit 1; fi
DUT_TOP="$1"

require_env TF_FILE
require_env TLU_FILE
require_env DB_FILE
require_env LEF_FILE
require_env CORNER_NAME
require_env VOLTAGE
require_env TEMPERATURE

NETLIST="${NETLIST:-syn/work/${DUT_TOP}.netlist.v}"
SDC_FILE="${SDC_FILE:-syn/work/${DUT_TOP}.sdc}"
CORE_UTIL="${CORE_UTIL:-0.6}"
NDM_DIR="${NDM_DIR:-pnr/work/ndm}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [ ! -d "$NDM_DIR/cell_ndm" ]; then
    echo "==== building NDM (one-time) ===="
    NDM_OUT="$NDM_DIR" icc2_lm_shell -f pnr/build_ndm.tcl | tee pnr/build_ndm.log
fi
if [ ! -d "$NDM_DIR/cell_ndm" ]; then
    echo "ERROR: NDM build failed: $NDM_DIR/cell_ndm still missing" >&2
    exit 1
fi

export TF_FILE TLU_FILE DUT_TOP NETLIST SDC_FILE CORE_UTIL NDM_DIR
export CORNER_NAME VOLTAGE TEMPERATURE

icc2_shell -f pnr/pnr.tcl | tee pnr/pnr.log
