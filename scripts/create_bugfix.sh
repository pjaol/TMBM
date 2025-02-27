#!/bin/bash

# Script to create a new bugfix branch for the TMBM project

# Check if a bug description was provided
if [ $# -eq 0 ]; then
    echo "Error: No bug description provided."
    echo "Usage: $0 <bug-description>"
    exit 1
fi

# Convert bug description to lowercase and replace spaces with hyphens
BUG_DESCRIPTION=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

echo "Creating bugfix branch for: $BUG_DESCRIPTION"

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

# Create and checkout the new bugfix branch
echo "Creating bugfix branch: bugfix/$BUG_DESCRIPTION"
git checkout -b "bugfix/$BUG_DESCRIPTION"

echo "Bugfix branch created and checked out."
echo "Current branch: $(git branch --show-current)"
echo ""
echo "Next steps:"
echo "1. Fix the bug"
echo "2. Commit your changes: git add . && git commit -m \"Fix: Your bug fix description\""
echo "3. Push your changes: git push -u origin bugfix/$BUG_DESCRIPTION"
echo "4. When ready, create a pull request to merge into develop" 