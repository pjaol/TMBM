#!/bin/bash

# Script to build and run the TMBM application

echo "Building and running TMBM application..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Build the core package
echo "Building core package..."
./scripts/build_core.sh

# Check if core build was successful
if [ $? -ne 0 ]; then
    echo "Core package build failed. Aborting."
    exit 1
fi

# Build and run the app
echo "Building and running app..."
./scripts/build_app.sh

# Check if app build/run was successful
if [ $? -ne 0 ]; then
    echo "App build/run failed."
    exit 1
fi

echo "TMBM application built and running successfully." 