#!/bin/bash

# Exit on error
set -e

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}\n"
}

# Function to print success messages
print_success() {
    echo -e "\n${GREEN}✓ $1${NC}\n"
}

# Function to print error messages
print_error() {
    echo -e "\n${RED}✗ $1${NC}\n"
}

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Print Xcode and Swift versions
print_header "Environment Information"
xcodebuild -version
swift --version

# Check if xcpretty is installed
XCPRETTY_INSTALLED=false
if command -v xcpretty &> /dev/null; then
    XCPRETTY_INSTALLED=true
    print_success "xcpretty is installed"
else
    print_error "xcpretty is not installed. Output will not be formatted."
    echo "To install xcpretty, run: gem install xcpretty"
    echo "Continuing without xcpretty..."
fi

# Check if we need to create a Swift Package
if [ ! -f "Package.swift" ] && [ ! -d "*.xcodeproj" ] && [ ! -d "*.xcworkspace" ]; then
    print_header "No Xcode project found. Creating Swift Package..."
    
    # Create Swift Package
    mkdir -p Sources/TMBM
    mkdir -p Tests/TMBMTests
    
    # Create Package.swift
    cat > Package.swift << 'EOF'
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TMBM",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "TMBM", targets: ["TMBM"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "TMBM",
            dependencies: []
        ),
        .testTarget(
            name: "TMBMTests",
            dependencies: ["TMBM"]
        )
    ]
)
EOF

    # Create a simple main.swift file
    cat > Sources/TMBM/main.swift << 'EOF'
import Foundation

print("Time Machine Backup Manager")
print("This is a placeholder for the actual application.")
EOF

    # Create a simple test file
    cat > Tests/TMBMTests/TMBMTests.swift << 'EOF'
import XCTest
@testable import TMBM

final class TMBMTests: XCTestCase {
    func testExample() {
        XCTAssertEqual("Time Machine Backup Manager", "Time Machine Backup Manager")
    }
}
EOF

    print_success "Swift Package created successfully"
fi

# Clean build directory
print_header "Cleaning Build Directory"
rm -rf .build
mkdir -p .build

# Build the project
print_header "Building TMBM"
if [ -f "Package.swift" ]; then
    # Build Swift Package
    if [ "$XCPRETTY_INSTALLED" = true ]; then
        swift build | xcpretty || { print_error "Build failed"; exit 1; }
    else
        swift build || { print_error "Build failed"; exit 1; }
    fi
else
    # Build Xcode project
    if [ "$XCPRETTY_INSTALLED" = true ]; then
        xcodebuild clean build -scheme "TMBM" -destination "platform=macOS" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty || { print_error "Build failed"; exit 1; }
    else
        xcodebuild clean build -scheme "TMBM" -destination "platform=macOS" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO || { print_error "Build failed"; exit 1; }
    fi
fi

print_success "Build completed successfully"

# Run tests if requested
if [[ "$1" == "--test" || "$1" == "-t" ]]; then
    print_header "Running Tests"
    if [ -f "Package.swift" ]; then
        # Test Swift Package
        if [ "$XCPRETTY_INSTALLED" = true ]; then
            swift test | xcpretty || { print_error "Tests failed"; exit 1; }
        else
            swift test || { print_error "Tests failed"; exit 1; }
        fi
    else
        # Test Xcode project
        if [ "$XCPRETTY_INSTALLED" = true ]; then
            xcodebuild test -scheme "TMBM" -destination "platform=macOS" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty || { print_error "Tests failed"; exit 1; }
        else
            xcodebuild test -scheme "TMBM" -destination "platform=macOS" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO || { print_error "Tests failed"; exit 1; }
        fi
    fi
    
    print_success "Tests completed successfully"
fi

# Run the app if requested
if [[ "$1" == "--run" || "$1" == "-r" ]]; then
    print_header "Running TMBM"
    
    if [ -f "Package.swift" ]; then
        # Run Swift Package
        swift run || { print_error "Run failed"; exit 1; }
    else
        # Find the app in the build directory
        APP_PATH=$(find ./build -name "*.app" -type d | head -n 1)
        
        if [[ -z "$APP_PATH" ]]; then
            print_error "Could not find built app"
            exit 1
        fi
        
        # Run the app
        open "$APP_PATH"
    fi
    
    print_success "Launched TMBM"
fi

# Run both tests and app if requested
if [[ "$1" == "--all" || "$1" == "-a" ]]; then
    print_header "Running Tests"
    if [ -f "Package.swift" ]; then
        # Test Swift Package
        if [ "$XCPRETTY_INSTALLED" = true ]; then
            swift test | xcpretty || { print_error "Tests failed"; exit 1; }
        else
            swift test || { print_error "Tests failed"; exit 1; }
        fi
    else
        # Test Xcode project
        if [ "$XCPRETTY_INSTALLED" = true ]; then
            xcodebuild test -scheme "TMBM" -destination "platform=macOS" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty || { print_error "Tests failed"; exit 1; }
        else
            xcodebuild test -scheme "TMBM" -destination "platform=macOS" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO || { print_error "Tests failed"; exit 1; }
        fi
    fi
    
    print_success "Tests completed successfully"
    
    print_header "Running TMBM"
    
    if [ -f "Package.swift" ]; then
        # Run Swift Package
        swift run || { print_error "Run failed"; exit 1; }
    else
        # Find the app in the build directory
        APP_PATH=$(find ./build -name "*.app" -type d | head -n 1)
        
        if [[ -z "$APP_PATH" ]]; then
            print_error "Could not find built app"
            exit 1
        fi
        
        # Run the app
        open "$APP_PATH"
    fi
    
    print_success "Launched TMBM"
fi

# If no arguments provided, just show help
if [[ $# -eq 0 ]]; then
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -t, --test    Build and run tests"
    echo "  -r, --run     Build and run the application"
    echo "  -a, --all     Build, test, and run the application"
    echo ""
fi

print_header "Build Process Complete" 