#!/usr/bin/env bash
#
# run_syn.sh -- DC synthesis wrapper for project2. The SDC is fixed
# to syn/cpu_top.sdc (the project's only DUT).
#
# Usage: syn/run_syn.sh <dut_top.v> <dut_top> <clk_period_ns>
# Required env: DB_FILE

set -euo pipefail

require_env () {
    local v="$1"
    if [ -z "${!v:-}" ]; then echo "ERROR: env var '$v' must be set" >&2; exit 1; fi
}

if [ $# -lt 3 ]; then
    echo "Usage: $0 <dut_top.v> <dut_top> <clk_period_ns>" >&2
    exit 1
fi

DUT_FILE="$1"
DUT_TOP="$2"
CLK_PERIOD="$3"
SDC_FILE="syn/cpu_top.sdc"

require_env DB_FILE

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

[ -f "$DUT_FILE" ] || { echo "ERROR: DUT file not found: $DUT_FILE" >&2; exit 1; }
[ -f "$SDC_FILE" ] || { echo "ERROR: SDC not found: $SDC_FILE"      >&2; exit 1; }

# Default SEARCH_PATH = directory containing the top file.
SEARCH_PATH="${SEARCH_PATH:-$(dirname "$DUT_FILE")}"

export DB_FILE DUT_FILE DUT_TOP SDC_FILE CLK_PERIOD SEARCH_PATH

dc_shell -f syn/synth.tcl | tee syn/synth.log
