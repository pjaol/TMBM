# Git Workflow for TMBM Project

This document outlines the Git workflow for the Time Machine Backup Manager (TMBM) project. Following these guidelines will help maintain a clean and organized repository.

## Branch Structure

- **main**: The main branch contains the stable, production-ready code.
- **develop**: The development branch where features are integrated before being merged into main.
- **feature/[feature-name]**: Feature branches for developing new features.
- **bugfix/[bug-name]**: Branches for fixing bugs.
- **release/[version]**: Release branches for preparing releases.

## Workflow

### Starting a New Feature

1. Create a new feature branch from the develop branch:
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/your-feature-name
   ```

2. Work on your feature, making regular commits:
   ```bash
   git add .
   git commit -m "Descriptive commit message"
   ```

3. Push your feature branch to the remote repository:
   ```bash
   git push -u origin feature/your-feature-name
   ```

### Completing a Feature

1. Ensure your feature branch is up to date with the develop branch:
   ```bash
   git checkout develop
   git pull
   git checkout feature/your-feature-name
   git merge develop
   ```

2. Resolve any conflicts if necessary.

3. Push your updated feature branch:
   ```bash
   git push
   ```

4. Create a pull request from your feature branch to the develop branch.

5. After the pull request is reviewed and approved, merge it into the develop branch.

### Fixing Bugs

1. Create a bugfix branch from the develop branch (or from main for critical production bugs):
   ```bash
   git checkout develop
   git pull
   git checkout -b bugfix/bug-description
   ```

2. Fix the bug and commit your changes:
   ```bash
   git add .
   git commit -m "Fix: Description of the bug fix"
   ```

3. Push your bugfix branch and create a pull request:
   ```bash
   git push -u origin bugfix/bug-description
   ```

### Preparing a Release

1. Create a release branch from the develop branch:
   ```bash
   git checkout develop
   git pull
   git checkout -b release/v1.0.0
   ```

2. Make any final adjustments, version bumps, etc.

3. Merge the release branch into both main and develop:
   ```bash
   git checkout main
   git pull
   git merge release/v1.0.0
   git push
   
   git checkout develop
   git pull
   git merge release/v1.0.0
   git push
   ```

4. Tag the release on the main branch:
   ```bash
   git checkout main
   git tag -a v1.0.0 -m "Version 1.0.0"
   git push --tags
   ```

## Commit Message Guidelines

- Use clear, descriptive commit messages
- Start with a verb in the present tense (e.g., "Add", "Fix", "Update", "Remove")
- Keep the first line under 50 characters
- For more complex changes, add a blank line after the first line and provide more details

Examples:
- "Add backup scheduling feature"
- "Fix crash when deleting backups"
- "Update UI for better accessibility"
- "Refactor TimeMachineService for better performance"

## Code Review Guidelines

- Review code for functionality, readability, and adherence to project standards
- Ensure tests are included where appropriate
- Check for potential security issues
- Verify that documentation is updated

## Git Best Practices

- Commit early and often
- Keep commits focused on a single task
- Don't commit generated files or dependencies
- Regularly pull changes from the remote repository
- Use .gitignore to exclude unnecessary files

By following this workflow, we can maintain a clean and organized repository, making it easier to track changes, fix bugs, and collaborate effectively. 