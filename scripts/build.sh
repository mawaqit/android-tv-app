#!/bin/bash

# NOTE: This script is designed for Unix-based environments (Linux, macOS, WSL)
# Windows users should use WSL or Git Bash to run this script

# Navigate to project root directory (where the script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "Running build_runner from directory: $(pwd)"

# Check if fvm is installed and configured
if command -v fvm &> /dev/null; then
  echo "Using fvm for build_runner..."
  fvm flutter pub run build_runner build --delete-conflicting-outputs
else
  echo "Using system flutter..."
  flutter pub run build_runner build --delete-conflicting-outputs
fi

echo "Build completed successfully!"
