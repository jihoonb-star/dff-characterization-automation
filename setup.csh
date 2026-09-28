#!/bin/csh

# =============================================================================
# DFF Characterization Automation
# Environment Setup
# =============================================================================

# Use the current working directory as the project root.
setenv DFF_CHAR_ROOT `pwd`

# Create output directories if they do not exist.
mkdir -p "$DFF_CHAR_ROOT/data/raw"
mkdir -p "$DFF_CHAR_ROOT/results"
mkdir -p "$DFF_CHAR_ROOT/logs"

echo ""
echo "============================================"
echo " DFF Characterization Environment Setup"
echo "============================================"
echo "DFF_CHAR_ROOT = $DFF_CHAR_ROOT"
echo "============================================"
echo ""
