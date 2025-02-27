#!/bin/bash

# Script to clean up the project structure

echo "Cleaning up project structure..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Create a backup directory for files we're removing
mkdir -p .backup

# Move outdated directories to backup
echo "Moving outdated directories to backup..."
mv -f TMBMApp .backup/ 2>/dev/null || true
mv -f TMBMApp_backup .backup/ 2>/dev/null || true
mv -f XcodeApp .backup/ 2>/dev/null || true
mv -f XcodeProject .backup/ 2>/dev/null || true
mv -f TMBMApp.xcodeproj .backup/ 2>/dev/null || true

# Move outdated scripts to backup
echo "Moving outdated scripts to backup..."
mv -f update_xcode_project.sh .backup/ 2>/dev/null || true
mv -f open_xcode_project.sh .backup/ 2>/dev/null || true
mv -f build_tmbm_app.sh .backup/ 2>/dev/null || true

# Clean up build artifacts
echo "Cleaning up build artifacts..."
rm -rf build 2>/dev/null || true
rm -rf build-logs 2>/dev/null || true
rm -rf .build 2>/dev/null || true

# Clean up root package files if they're redundant
echo "Cleaning up redundant files..."
mv -f Package.swift .backup/ 2>/dev/null || true
mv -f Sources .backup/ 2>/dev/null || true
mv -f Tests .backup/ 2>/dev/null || true
mv -f Resources .backup/ 2>/dev/null || true
mv -f project_reorganization.md .backup/ 2>/dev/null || true
mv -f FIXES.md .backup/ 2>/dev/null || true

# Update .gitignore to ignore the backup directory
if ! grep -q "^.backup/" .gitignore; then
    echo "" >> .gitignore
    echo "# Backup directory" >> .gitignore
    echo ".backup/" >> .gitignore
fi

echo "Project cleanup complete!"
echo "Backup of removed files is in the .backup directory."
echo "You can delete this directory if you don't need those files anymore." 