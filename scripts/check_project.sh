#!/bin/bash

# Script to check the project structure and verify that everything is in place

echo "Checking project structure..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Check if the core directories exist
echo "Checking core directories..."
if [ -d "CorePackage" ]; then
    echo "✅ CorePackage directory exists"
else
    echo "❌ CorePackage directory is missing"
fi

if [ -d "App" ]; then
    echo "✅ App directory exists"
else
    echo "❌ App directory is missing"
fi

if [ -d "scripts" ]; then
    echo "✅ scripts directory exists"
else
    echo "❌ scripts directory is missing"
fi

if [ -d "documentation" ]; then
    echo "✅ documentation directory exists"
else
    echo "❌ documentation directory is missing"
fi

# Check if the core scripts exist
echo "Checking core scripts..."
if [ -f "scripts/build_core.sh" ]; then
    echo "✅ build_core.sh script exists"
else
    echo "❌ build_core.sh script is missing"
fi

if [ -f "scripts/build_app.sh" ]; then
    echo "✅ build_app.sh script exists"
else
    echo "❌ build_app.sh script is missing"
fi

if [ -f "scripts/run_app.sh" ]; then
    echo "✅ run_app.sh script exists"
else
    echo "❌ run_app.sh script is missing"
fi

if [ -f "scripts/open_app.sh" ]; then
    echo "✅ open_app.sh script exists"
else
    echo "❌ open_app.sh script is missing"
fi

if [ -f "scripts/update_project.sh" ]; then
    echo "✅ update_project.sh script exists"
else
    echo "❌ update_project.sh script is missing"
fi

if [ -f "scripts/cleanup_project.sh" ]; then
    echo "✅ cleanup_project.sh script exists"
else
    echo "❌ cleanup_project.sh script is missing"
fi

# Check if the core source files exist
echo "Checking core source files..."
if [ -f "CorePackage/Sources/TMBM/main.swift" ]; then
    echo "✅ CorePackage main.swift exists"
else
    echo "❌ CorePackage main.swift is missing"
fi

if [ -f "App/Sources/main.swift" ]; then
    echo "✅ App main.swift exists"
else
    echo "❌ App main.swift is missing"
fi

if [ -f "App/Sources/TMBMApp.swift" ]; then
    echo "✅ App TMBMApp.swift exists"
else
    echo "❌ App TMBMApp.swift is missing"
fi

echo "Project structure check complete!" 