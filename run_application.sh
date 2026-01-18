#!/bin/bash

# GymGuard Mobile Launcher Script for macOS/Linux
# Optimized for iOS and Android deployment only

set -e  # Exit on any error

echo "==================================================="
echo "              GymGuard Mobile App"
echo "          iOS and Android Ready"
echo "            OPTIMIZED and WORKING"
echo "==================================================="
echo

# Auto-detect project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Detected project directory: $PROJECT_DIR"

cd "$PROJECT_DIR" || {
    echo "ERROR: Could not change to project directory!"
    echo "Make sure you run this script from the project folder."
    exit 1
}

echo "Current directory: $(pwd)"
echo

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed or not in PATH!"
    echo "Please install Flutter and add it to your system PATH."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if this is a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "ERROR: This is not a Flutter project directory!"
    echo "pubspec.yaml not found."
    exit 1
fi

echo "MOBILE OPTIMIZATIONS ACTIVE:"
echo "* Motion detection fixed (pose mirroring corrected)"
echo "* Bicep Curl detection optimized (less false errors)"
echo "* Android camera compatibility enhanced"
echo "* iOS pose detection improved"
echo "* Enhanced visual feedback with angle display"
echo "* Universal mobile deployment script"
echo "* AI-powered movement analysis integrated"
echo

# Check for connected mobile devices
echo "Checking for connected mobile devices..."
if ! flutter devices --machine &> /dev/null; then
    echo "Warning: Could not check devices, but continuing..."
fi

echo
echo "Starting GymGuard on your mobile device..."
echo "This may take a moment for the first build..."
echo

# Run Flutter
if flutter run; then
    echo
    echo "GymGuard Mobile App started successfully!"
    echo "App is now running on your device. Enjoy your workout!"
    echo "Perfect for iOS and Android fitness tracking!"
else
    FLUTTER_EXIT_CODE=$?
    echo
    echo "Failed to start GymGuard Mobile App! (Exit code: $FLUTTER_EXIT_CODE)"
    echo
    echo "MOBILE DEVICE TROUBLESHOOTING:"
    echo
    echo "ANDROID:"
    echo "1. Enable Developer Options (Settings > About > Tap Build Number 7x)"
    echo "2. Enable USB Debugging (Settings > Developer Options)"
    echo "3. Connect via USB and trust computer"
    echo "4. For wireless: Enable Wireless Debugging in Developer Options"
    echo
    echo "iOS:"
    echo "1. Connect via USB cable"
    echo "2. Trust this computer when prompted"
    echo "3. Enter device passcode if requested"
    echo "4. Ensure device is unlocked during deployment"
    echo
    echo "Common mobile solutions:"
    echo "- Check if device appears in: flutter devices"
    echo "- Try different USB cable or port"
    echo "- Restart both computer and mobile device"
    echo "- Grant camera permissions when app launches"
    echo
    exit $FLUTTER_EXIT_CODE
fi
