#!/bin/bash
# Test script for tiny-fuzzy-finder (run from anywhere)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Testing tiny-fuzzy-finder..."
echo "Starting Vim with plugin..."

vim --cmd "set rtp+=${PROJECT_DIR}" -c "Tff" -c "echo 'Type to narrow, Enter to open, Esc closes finder (then :qa to quit vim).'"
