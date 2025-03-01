#!/bin/bash

# Script to build and run the TMBM App

echo "Building TMBM App..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Create a build directory if it doesn't exist
mkdir -p build

# Find all Swift files in the CorePackage except main.swift
CORE_FILES=$(find CorePackage/Sources -name "*.swift" | grep -v "main.swift" | tr '\n' ' ')

# Find all Swift files in the App
APP_FILES=$(find App/Sources -name "*.swift" | tr '\n' ' ')

# Compile all Swift files together
echo "Building App with CorePackage..."
swiftc -o build/TMBMApp \
    $APP_FILES \
    $CORE_FILES \
    -framework AppKit \
    -framework SwiftUI

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Build successful!"
    
    # Create app bundle structure
    mkdir -p build/TMBMApp.app/Contents/MacOS
    cp build/TMBMApp build/TMBMApp.app/Contents/MacOS/
    
    # Only run the app if not in CI environment
    if [ -z "$CI" ]; then
        echo "Running TMBMApp..."
        ./build/TMBMApp
    else
        echo "Skipping app execution in CI environment."
    fi
else
    echo "Build failed. Please check the errors above."
fi 