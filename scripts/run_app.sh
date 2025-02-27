#!/bin/bash

# Script to run the TMBM App

echo "Running TMBM App..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Check if the app bundle exists
APP_BUNDLE="build/TMBMApp.app"
if [ ! -d "$APP_BUNDLE" ]; then
    echo "App bundle not found. Building it first..."
    ./scripts/build_app_bundle.sh
else
    # Open the app bundle
    echo "Opening the app bundle..."
    open "$APP_BUNDLE"
fi 