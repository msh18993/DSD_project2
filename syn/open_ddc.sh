#!/usr/bin/env bash
#
# open_ddc.sh -- open a synthesized .ddc in the DC GUI.
#
# Usage:
#   syn/open_ddc.sh <dut_top>
# Example:
#   syn/open_ddc.sh cpu_top

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <dut_top>" >&2
    exit 1
fi

DUT_TOP="$1"
DB_FILE="/home/CAD/tech/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_tt0p85v25c.db"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

DDC="syn/work/${DUT_TOP}.compile.ddc"
[ -f "$DDC" ]     || { echo "ERROR: ddc not found: $DDC"      >&2; exit 1; }
[ -f "$DB_FILE" ] || { echo "ERROR: .db not found: $DB_FILE"  >&2; exit 1; }

dc_shell -gui -x "
    set link_library   [list * \"$DB_FILE\"]
    set target_library \"$DB_FILE\"
    read_ddc \"$DDC\"
    current_design $DUT_TOP
    link
    gui_start
"
