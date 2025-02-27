# Project Reorganization Plan

## Current Structure Issues
- Confusing dual Sources directories (`./Sources` and `TMBMApp/Sources`)
- Multiple app-related directories (`TMBMApp`, `XcodeApp`, `XcodeProject`)
- Unclear separation between core package and UI application
- Inconsistent naming conventions

## New Structure

```
TMBM/                      # Root project directory
├── CorePackage/           # Core functionality (renamed from ./Sources)
│   ├── Sources/           # Source files for the core package
│   │   └── TMBM/          # Main module
│   │       ├── Models/    # Data models
│   │       ├── Services/  # Business logic services
│   │       └── Utilities/ # Helper utilities
│   ├── Tests/             # Tests for the core package
│   └── Package.swift      # Package manifest for the core package
│
├── App/                   # UI Application (renamed from TMBMApp)
│   ├── Sources/           # Source files for the app
│   │   ├── Views/         # SwiftUI views
│   │   ├── ViewModels/    # View models
│   │   └── App/           # App entry point
│   ├── Resources/         # App resources
│   │   ├── Assets.xcassets/
│   │   └── Info.plist
│   └── App.xcodeproj/     # Xcode project for the app
│
├── scripts/               # Build and utility scripts
│   ├── build_core.sh      # Build the core package
│   ├── build_app.sh       # Build the app
│   └── run_app.sh         # Run the app
│
├── documentation/         # Project documentation
│   ├── requirements.md
│   ├── architecture.md
│   └── user-guide.md
│
└── README.md              # Main project README
```

## Implementation Steps

1. Create the new directory structure
2. Move files to their appropriate locations
3. Update import paths in source files
4. Update build scripts to use the new structure
5. Update documentation to reflect the new structure
6. Create new Package.swift files if needed
7. Test building and running with the new structure

## Benefits

- Clear separation between core functionality and UI
- Consistent naming conventions
- Easier to understand project structure
- Better organization for future development
- Simplified build process 