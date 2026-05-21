#!/usr/bin/env bash
#
# setup_saed32.sh -- project-specific environment setup for the
# 64-bit adder project on the SAED32nm Educational EDK.
#
# Source this once per shell before running the flow:
#   source setup_saed32.sh
#
# Required: LIB_HOME must be set to the SAED32_EDK install root.
#
# Sets:
#   DB_FILE / LEF_FILE / TF_FILE / TLU_FILE  -- library file paths
#   DRIVE_CELL                               -- SDC driving cell
#   DC_DONT_USE                              -- DesignWare adder block
#                                               (so 'a + b + cin' maps
#                                               to basic gates / FA cells
#                                               instead of a fast macro)
#   CORNER_NAME / VOLTAGE / TEMPERATURE      -- operating point
#
# To use a different cell flavour (RVT / LVT) or corner, override the
# specific env vars after sourcing.

export LIB_HOME="/home/CAD/tech/SAED32_EDK"

# Stdcell library: HVT, typical-typical, 0.85V, 25C, NLDM
export DB_FILE="$LIB_HOME/lib/stdcell_hvt/db_nldm/saed32hvt_tt0p85v25c.db"
export LEF_FILE="$LIB_HOME/lib/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef"

# Tech files
export TF_FILE="$LIB_HOME/tech/milkyway/saed32nm_1p9m_mw.tf"
export TLU_FILE="$LIB_HOME/tech/star_rcxt/saed32nm_1p9m_nominal.tluplus"

# Driving cell for SDC (matches HVT corner)
export DRIVE_CELL="INVX1_HVT"

# Operating point
export CORNER_NAME="tt0p85v25c"
export VOLTAGE="0.85"
export TEMPERATURE="25"

# Block DesignWare adder substitution so '+' synthesizes from basic
# gates (and the standard-cell FA / HA primitives) instead of a fancy
# carry-lookahead macro. Lets the explicit RTL topology determine the
# resulting structure.
#export DC_DONT_USE="*/DW01_add* */DW_add* */DW01_addsub* */DW_addsub*"

echo "INFO: SAED32 EDK env loaded (LIB_HOME=$LIB_HOME)"
