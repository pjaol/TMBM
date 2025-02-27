#!/bin/bash

# Script to create a new release branch for the TMBM project

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

echo "Creating release branch for version: $VERSION"

# Navigate to the project root directory
cd "$(dirname "$0")/.."

# Make sure we're on the develop branch and it's up to date
echo "Checking out develop branch..."
git checkout develop

# Check if we need to pull
if git remote -v | grep -q origin; then
    echo "Updating develop branch from remote..."
    git pull origin develop
fi

# Create and checkout the new release branch
echo "Creating release branch: release/v$VERSION"
git checkout -b "release/v$VERSION"

# Update version in relevant files
echo "Updating version in files..."

# Update version in App/Resources/Info.plist if it exists
if [ -f "App/Resources/Info.plist" ]; then
    echo "Updating version in App/Resources/Info.plist..."
    # Use PlistBuddy if available, otherwise use sed
    if command -v /usr/libexec/PlistBuddy &> /dev/null; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" App/Resources/Info.plist
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" App/Resources/Info.plist
    else
        echo "PlistBuddy not found, skipping Info.plist update"
    fi
fi

# Update version in README.md if it exists
if [ -f "README.md" ]; then
    echo "Updating version in README.md..."
    # This is a simple example, you might need to adjust the sed pattern
    sed -i '' "s/Version [0-9]\+\.[0-9]\+\.[0-9]\+/Version $VERSION/g" README.md
fi

# Commit version changes
echo "Committing version changes..."
git add .
git commit -m "Bump version to $VERSION"

echo "Release branch created and checked out."
echo "Current branch: $(git branch --show-current)"
echo ""
echo "Next steps:"
echo "1. Make any final adjustments for the release"
echo "2. Commit your changes: git add . && git commit -m \"Your commit message\""
echo "3. Push your changes: git push -u origin release/v$VERSION"
echo "4. When ready, merge into main and develop:"
echo "   git checkout main"
echo "   git merge release/v$VERSION"
echo "   git push origin main"
echo "   git tag -a v$VERSION -m \"Version $VERSION\""
echo "   git push origin v$VERSION"
echo "   git checkout develop"
echo "   git merge release/v$VERSION"
echo "   git push origin develop" 