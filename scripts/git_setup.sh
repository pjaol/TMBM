#!/bin/bash

# Script to set up the Git workflow for the TMBM project

echo "Setting up Git workflow for TMBM project..."

# Navigate to the project root directory
cd "$(dirname "$0")/.."

# Check if Git is initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
fi

# Check if main branch exists
if ! git show-ref --verify --quiet refs/heads/main; then
    echo "Creating main branch..."
    git checkout -b main
fi

# Check if develop branch exists
if ! git show-ref --verify --quiet refs/heads/develop; then
    echo "Creating develop branch..."
    git checkout -b develop
else
    echo "Switching to develop branch..."
    git checkout develop
fi

# Add all files to staging
echo "Adding files to staging..."
git add .

# Commit changes
echo "Committing initial project structure..."
git commit -m "Initial project structure"

# Create .github directory and workflow file if it doesn't exist
if [ ! -d ".github/workflows" ]; then
    echo "Creating GitHub Actions workflow directory..."
    mkdir -p .github/workflows
fi

# Create GitHub Actions workflow file if it doesn't exist
if [ ! -f ".github/workflows/swift.yml" ]; then
    echo "Creating GitHub Actions workflow file..."
    cat > .github/workflows/swift.yml << 'EOF'
name: Swift

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Build Core Package
      run: |
        cd CorePackage
        swift build -v
    - name: Run Core Package Tests
      run: |
        cd CorePackage
        swift test -v
    - name: Build App
      run: |
        ./scripts/build_app.sh
EOF
    git add .github/workflows/swift.yml
    git commit -m "Add GitHub Actions workflow"
fi

# Push to remote if remote is set
if git remote -v | grep -q origin; then
    echo "Pushing to remote repository..."
    git push -u origin main
    git push -u origin develop
else
    echo "No remote repository set. To push to a remote repository, use:"
    echo "git remote add origin <repository-url>"
    echo "git push -u origin main"
    echo "git push -u origin develop"
fi

echo "Git workflow setup complete!"
echo "Current branch: $(git branch --show-current)"
echo ""
echo "Next steps:"
echo "1. Create feature branches from develop: git checkout -b feature/your-feature-name"
echo "2. Follow the workflow in documentation/git-workflow.md" 