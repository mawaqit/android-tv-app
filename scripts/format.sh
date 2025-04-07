#!/bin/bash

# Script to format code according to project standards
# This script is typically run after commits or during CI

# Navigate to project root directory (where the script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "Running Flutter code formatter from directory: $(pwd)"

# Check if fvm is installed and configured
if command -v fvm &> /dev/null; then
  echo "Using fvm for formatting..."
  fvm dart format --set-exit-if-changed . --line-length 120
else
  echo "fvm not found, using system flutter..."
  dart format --set-exit-if-changed . --line-length 120
fi

echo "Code formatting complete!"
