# Time Machine Backup Manager (TMBM)

A macOS application to manage and monitor Time Machine backups.

## Project Structure

The project is organized into the following components:

- **CorePackage**: The core Swift package containing the business logic and models
- **App**: The macOS application that provides the user interface
- **scripts**: Utility scripts for building, running, and managing the project
- **documentation**: Project documentation including requirements, architecture, and plans

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

## Getting Started

### Building and Running

To build and run the application, use the provided script:

```bash
./scripts/run_app.sh
```

This script will:
1. Build the core package
2. Build and run the macOS application

### Individual Build Scripts

You can also use the individual scripts for more specific tasks:

- **Build Core Package**: `./scripts/build_core.sh`
- **Build and Run App**: `./scripts/build_app.sh`
- **Open App in Xcode**: `./scripts/open_app.sh`
- **Update Project Structure**: `./scripts/update_project.sh`
- **Clean Up Project**: `./scripts/cleanup_project.sh`

## Development

### Project Organization

- **CorePackage/Sources**: Contains the core business logic and models
  - **TMBM/Models**: Data models
  - **TMBM/Services**: Business logic services
  - **TMBM/Utilities**: Helper utilities
- **App/Sources**: Contains the application code
  - **App**: Application entry point and configuration
  - **Views**: SwiftUI views
  - **ViewModels**: View models for the SwiftUI views
- **App/Resources**: Contains resources like images, localization files, etc.

### Workflow

1. Make changes to the core package or app code
2. Build and test using the provided scripts
3. Open in Xcode for more detailed development using `./scripts/open_app.sh`

### Source Control

This project uses Git for source control. We follow a structured branching model:

- **main**: Stable, production-ready code
- **develop**: Integration branch for features
- **feature/[name]**: Feature development branches
- **bugfix/[name]**: Bug fix branches
- **release/[version]**: Release preparation branches

For detailed information about our Git workflow, please see [documentation/git-workflow.md](documentation/git-workflow.md).

## Documentation

The `documentation` directory contains detailed information about the project:

- **requirements.md**: Detailed functional and non-functional requirements
- **software-architecture.md**: High-level architecture design
- **implementation-plan.md**: Implementation approach and timeline
- **technical-specifications.md**: Detailed technical specifications
- **project-plan.md**: Agile project plan with user stories
- **git-workflow.md**: Git branching model and workflow guidelines

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or feedback, please open an issue on the project repository. 