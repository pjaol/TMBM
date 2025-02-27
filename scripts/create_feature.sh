#!/bin/bash

# Script to create a new feature branch for the TMBM project

# Check if a feature name was provided
if [ $# -eq 0 ]; then
    echo "Error: No feature name provided."
    echo "Usage: $0 <feature-name>"
    exit 1
fi

# Convert feature name to lowercase and replace spaces with hyphens
FEATURE_NAME=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

echo "Creating feature branch for: $FEATURE_NAME"

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

# Create and checkout the new feature branch
echo "Creating feature branch: feature/$FEATURE_NAME"
git checkout -b "feature/$FEATURE_NAME"

echo "Feature branch created and checked out."
echo "Current branch: $(git branch --show-current)"
echo ""
echo "Next steps:"
echo "1. Make your changes"
echo "2. Commit your changes: git add . && git commit -m \"Your commit message\""
echo "3. Push your changes: git push -u origin feature/$FEATURE_NAME"
echo "4. When ready, create a pull request to merge into develop" 