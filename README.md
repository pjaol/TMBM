# TMBM - Time Machine Backup Manager

A macOS application for managing Time Machine backups.

## Features

- View backup status and history
- Schedule backups
- Monitor disk usage
- Manage backup destinations

## Development

### Prerequisites

- macOS 10.15 or later
- Xcode 12.0 or later
- Swift 5.3 or later

### Building the App

To build the app, run the build script:

```bash
./scripts/build_app_bundle.sh
```

This will create the app bundle in the `build` directory. You can then open the app with:

```bash
open build/TMBMApp.app
```

### Project Maintenance

#### Cleanup

To clean up temporary files and directories, run the cleanup script:

```bash
./scripts/cleanup.sh
```

This script will:
- Remove the `.backup` directory
- Remove the `build-logs` directory
- Clean the `build` directory (keeping the app but removing other files)
- Remove Xcode user data
- Remove macOS system files
- Remove vim swap files
- Remove other temporary files

### Project Structure

- `App/` - The main application code
  - `Sources/` - Swift source files
    - `ViewModels/` - View models
    - `Views/` - SwiftUI views
  - `Resources/` - Assets and resources
- `CorePackage/` - The core functionality as a Swift Package
  - `Sources/TMBM/` - Core functionality
    - `Models/` - Data models
    - `Services/` - Services for interacting with Time Machine
  - `Tests/` - Unit tests
- `scripts/` - Build and utility scripts
- `documentation/` - Project documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or feedback, please open an issue on the project repository. 