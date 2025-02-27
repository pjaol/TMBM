#!/bin/bash

# Script to update the project structure

echo "Updating project structure..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Create a backup of the current App directory
echo "Creating backup of current files..."
mkdir -p App_backup
cp -r App/* App_backup/

# Update the project structure
echo "Updating project structure..."

# Create a proper project structure
mkdir -p App/Sources/{Views,ViewModels,App}
mkdir -p App/Resources

# Move Swift files to Sources
mv App/*.swift App/Sources/App/ 2>/dev/null || true

# Move resources to Resources
mv App/*.plist App/Resources/ 2>/dev/null || true
mv App/Assets.xcassets App/Resources/ 2>/dev/null || true

echo "Project structure updated. You can now open the project in Xcode."
echo "To open the project, run: ./scripts/open_app.sh" 