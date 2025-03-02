#!/bin/bash

# Script to create a new release for the TMBM App

set -e  # Exit on any error

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Check if a version was provided
if [ $# -eq 0 ]; then
    echo "Error: No version provided."
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

# Validate version format (should be in the format x.y.z)
if ! [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version should be in the format x.y.z (e.g., 1.0.0)"
    exit 1
fi

VERSION=$1

echo "Creating release for version: $VERSION"

# Build the app bundle (which now includes code signing)
echo "Building app bundle..."
./scripts/build_app_bundle.sh

# Check if build was successful
if [ ! -d "build/TMBMApp.app" ]; then
    echo "Error: App build failed. App bundle not found."
    exit 1
fi

# Verify the signature
echo "Verifying code signature..."
codesign --verify --verbose "build/TMBMApp.app"

# Create a zip archive of the app
echo "Creating zip archive..."
cd build
zip -r "TMBMApp-v$VERSION.zip" "TMBMApp.app"
cd ..

echo "Creating release tag..."
git tag -a "v$VERSION" -m "Version $VERSION"

# Check if gh CLI is available for creating GitHub release
if command -v gh &> /dev/null; then
    echo "Creating GitHub release using gh CLI..."
    
    # Create release notes file
    cat > release_notes.md << EOF
# TMBM v$VERSION

Time Machine Backup Manager (TMBM) is a macOS application that helps you manage your Time Machine backups.

## Features

- Menu bar quick access to Time Machine functions
- Backup history and status viewing
- Disk usage monitoring with visual representation
- Custom backup scheduling
- Backup destination management

## Installation

1. Download the TMBMApp-v$VERSION.zip file
2. Unzip the file
3. Move TMBMApp.app to your Applications folder
4. Right-click on the app and select "Open" (required for the first launch)

## Requirements

- macOS 13.0 or later
- Time Machine configured and active

## Changes in this version

- Fixed code signing issue that prevented the app from launching
- Improved app bundle creation process
- Enhanced error handling and logging
EOF

    # Create GitHub release
    gh release create "v$VERSION" \
        --title "TMBM v$VERSION" \
        --notes-file release_notes.md \
        "build/TMBMApp-v$VERSION.zip"
    
    echo "GitHub release created successfully!"
    echo "Release URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases/tag/v$VERSION"
else
    echo "GitHub CLI (gh) not found. Please create the release manually:"
    echo "1. Push the tag: git push origin v$VERSION"
    echo "2. Create a new release on GitHub with the zip file: build/TMBMApp-v$VERSION.zip"
fi

echo "Release process completed successfully!" 