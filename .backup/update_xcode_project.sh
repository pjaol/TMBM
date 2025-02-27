#!/bin/bash

# Script to update the Xcode project structure

echo "Updating Xcode project structure..."

# Navigate to the project directory
cd "$(dirname "$0")"

# Create a backup of the current TMBMApp directory
echo "Creating backup of current files..."
mkdir -p TMBMApp_backup
cp -r TMBMApp/* TMBMApp_backup/

# Update the project structure
echo "Updating project structure..."

# Create a proper project structure
mkdir -p TMBMApp/Sources
mkdir -p TMBMApp/Resources

# Move Swift files to Sources
mv TMBMApp/*.swift TMBMApp/Sources/ 2>/dev/null || true

# Move resources to Resources
mv TMBMApp/*.plist TMBMApp/Resources/ 2>/dev/null || true
mv TMBMApp/Assets.xcassets TMBMApp/Resources/ 2>/dev/null || true

echo "Project structure updated. You can now open the project in Xcode."
echo "To open the project, run: ./open_xcode_project.sh" 