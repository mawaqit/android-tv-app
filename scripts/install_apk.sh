#!/bin/bash

# NOTE: This script is designed for Unix-based environments (Linux, macOS, WSL)
# Windows users should use WSL or Git Bash to run this script

# Script to install APK specifically for user 0 (primary user) on Android device
# Usage: ./scripts/install_apk.sh /path/to/your-app.apk

# Navigate to project root directory (where the script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
cd "$PROJECT_ROOT"

echo "Running APK installation script from: $(pwd)"

if [ $# -eq 0 ]; then
  echo "Error: APK path is required."
  echo "Usage: ./scripts/install_apk.sh /path/to/your-app.apk"
  exit 1
fi

APK_PATH="$1"

# Check if the APK file exists
if [ ! -f "$APK_PATH" ]; then
  echo "Error: APK file not found at path: $APK_PATH"
  exit 1
fi

# Check if ADB is installed
if ! command -v adb &> /dev/null; then
  echo "Error: ADB (Android Debug Bridge) is not installed or not in PATH."
  echo "Please install Android SDK Platform Tools."
  exit 1
fi

# Check for connected devices
DEVICES=$(adb devices | grep -v "List" | grep -v "^$" | wc -l)
if [ $DEVICES -eq 0 ]; then
  echo "Error: No Android devices connected."
  echo "Please connect your device and enable USB debugging."
  exit 1
fi

echo "Connected devices:"
adb devices

# Install APK for user 0
echo "Installing APK for user 0 (primary user)..."
adb install --user 0 "$APK_PATH"

# Check installation status
if [ $? -eq 0 ]; then
  echo "Installation successful."
  
  # Show users on the device
  echo "Users on the device:"
  adb shell pm list users
else
  echo "Installation failed."
fi

echo "Done." 