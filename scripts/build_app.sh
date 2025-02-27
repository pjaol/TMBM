#!/bin/bash

# Script to build and run the TMBM App

echo "Building TMBM App..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Create a build directory if it doesn't exist
mkdir -p build

# Compile the Swift files
# Note: Order matters - TMBMApp.swift must be compiled first since main.swift references its types
swiftc -o build/TMBMApp \
    App/Sources/TMBMApp.swift \
    App/Sources/main.swift \
    -framework AppKit \
    -framework SwiftUI

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Running TMBMApp..."
    ./build/TMBMApp
else
    echo "Build failed. Please check the errors above."
fi 