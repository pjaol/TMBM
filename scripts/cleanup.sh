#!/bin/bash

# TMBM Project Cleanup Script
# This script removes temporary files and directories that are not needed for the project

echo "Starting cleanup of TMBM project..."

# Remove backup directory
if [ -d ".backup" ]; then
    echo "Removing .backup directory..."
    rm -rf .backup
fi

# Remove build logs
if [ -d "build-logs" ]; then
    echo "Removing build-logs directory..."
    rm -rf build-logs
fi

# Clean build directory (keep the app but remove other files)
if [ -d "build" ]; then
    echo "Cleaning build directory..."
    find build -type f -not -path "*/TMBMApp.app/*" -delete
    find build -name ".DS_Store" -delete
fi

# Remove Xcode user data
echo "Removing Xcode user data..."
find . -name "xcuserdata" -type d -exec rm -rf {} +
find . -name "*.xcuserstate" -delete

# Remove macOS system files
echo "Removing macOS system files..."
find . -name ".DS_Store" -delete
find . -name ".AppleDouble" -delete
find . -name ".LSOverride" -delete

# Remove vim swap files
echo "Removing vim swap files..."
find . -name "*.swp" -delete
find . -name "*.swo" -delete

# Remove other temporary files
echo "Removing other temporary files..."
find . -name "*~" -delete
find . -name "*.bak" -delete

echo "Cleanup complete!" 