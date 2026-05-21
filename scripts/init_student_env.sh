#!/usr/bin/env bash
#
# init_student_env.sh -- create a per-student workspace.
#
# Read-only items (testbench, all flow scripts, SDC, setup script,
# pre-built NDM) become SYMLINKS into the canonical install. Writable
# items (rtl/, all work/, reports/, output/ dirs) are local directories
# the student owns.
#
# samples/, docs/, and the *.md files are deliberately NOT exposed in
# the student workspace -- they're instructor-only.
#
# A student cannot modify the scripts because they don't own the
# symlink targets. If they try (e.g. `vi syn/synth.tcl`), the editor
# will refuse to save unless they break the symlink first -- which
# only damages their own workspace, not the canonical install.
#
# Usage:
#   scripts/init_student_env.sh <canonical_install> <student_workspace>
#
# Example (run by each student in their home dir):
#   /home/CAD/projects/adder64/scripts/init_student_env.sh \
#       /home/CAD/projects/adder64  ~/adder_project

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <canonical_install_dir> <student_workspace_dir>" >&2
    exit 1
fi

SRC="$(cd "$1" && pwd -P)"
DST="$2"

if [ ! -d "$SRC" ]; then
    echo "ERROR: canonical install not found: $SRC" >&2
    exit 1
fi

mkdir -p "$DST"
DST="$(cd "$DST" && pwd -P)"

cd "$DST"

# ---- top-level ----
mkdir -p rtl                                              # writable: student RTL
# If canonical has rtl files (skeleton students start from), copy them
# as a writable starting point. -n keeps any pre-existing student work.
if [ -n "$(ls -A "$SRC/rtl" 2>/dev/null)" ]; then
    cp -n "$SRC"/rtl/*.v rtl/ 2>/dev/null || true
fi
ln -sfn "$SRC/tb"               tb
ln -sfn "$SRC/setup_saed32.sh"  setup_saed32.sh
# Programs/ if the project provides test inputs (project2 does):
[ -d "$SRC/programs" ] && ln -sfn "$SRC/programs" programs

# ---- syn ----
mkdir -p syn syn/work syn/reports
ln -sfn "$SRC/syn/synth.tcl"    syn/synth.tcl
# Symlink whatever .sdc files canonical provides (project1: adder64.sdc;
# project2: cpu_top.sdc; future projects: their own).
shopt -s nullglob
for sdc in "$SRC"/syn/*.sdc; do
    ln -sfn "$sdc" "syn/$(basename "$sdc")"
done
shopt -u nullglob
ln -sfn "$SRC/syn/run_syn.sh"   syn/run_syn.sh

# ---- pnr ----
mkdir -p pnr pnr/work pnr/output pnr/reports
ln -sfn "$SRC/pnr/build_ndm.tcl" pnr/build_ndm.tcl
ln -sfn "$SRC/pnr/pnr.tcl"       pnr/pnr.tcl
ln -sfn "$SRC/pnr/run_pnr.sh"    pnr/run_pnr.sh
# If the canonical install pre-built the NDM, share it.
if [ -d "$SRC/pnr/work/ndm" ]; then
    ln -sfn "$SRC/pnr/work/ndm"  pnr/work/ndm
fi

# ---- sta ----
mkdir -p sta sta/reports
ln -sfn "$SRC/sta/sta.tcl"     sta/sta.tcl
ln -sfn "$SRC/sta/run_sta.sh"  sta/run_sta.sh

# ---- sim ----
mkdir -p sim sim/work
ln -sfn "$SRC/sim/run_sim.sh"  sim/run_sim.sh

echo "Workspace ready at $DST"
echo ""
echo "Next steps:"
echo "  cd $DST"
echo "  export LIB_HOME=/path/to/SAED32_EDK"
echo "  source setup_saed32.sh"
echo "  # write rtl/adder64.v, then run the flow"
