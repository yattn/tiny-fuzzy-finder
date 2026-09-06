#!/bin/bash
# Test script for tiny-fuzzy-finder (run from anywhere)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Testing tiny-fuzzy-finder..."
echo "Starting Vim with plugin..."

vim --cmd "set rtp+=${PROJECT_DIR}" -c "Tff" -c "echo 'Plugin loaded successfully. Type to narrow, BS to delete, Up/Down or C-p/C-n to move, Enter to open, Esc to exit.'"
