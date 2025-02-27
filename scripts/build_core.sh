#!/bin/bash

# Script to build the TMBM Core Package

echo "Building TMBM Core Package..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Navigate to the CorePackage directory
cd CorePackage

# Build the package
swift build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Core package build successful!"
else
    echo "Core package build failed. Please check the errors above."
fi 