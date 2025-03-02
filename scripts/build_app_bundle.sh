#!/bin/bash

# Script to build a proper macOS .app bundle for the TMBM App

echo "Building TMBM App Bundle..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Create a build directory if it doesn't exist
mkdir -p build

# Clean up any existing app bundle
rm -rf "build/TMBMApp.app"

# Generate the app icon if it doesn't exist
if [ ! -f "App/Resources/AppIcon.icns" ]; then
    echo "Generating app icon..."
    ./scripts/create_app_icon.sh
fi

# First, build the Core Package as a module
echo "Building Core Package as module..."
CORE_MODULE_PATH="build/CoreModule"
mkdir -p "$CORE_MODULE_PATH"

# Find all Swift files in the CorePackage except main.swift
CORE_FILES=$(find CorePackage/Sources -name "*.swift" | grep -v "main.swift" | tr '\n' ' ')

# Create the app bundle structure first (we need the paths for install_name)
APP_BUNDLE="build/TMBMApp.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_FRAMEWORKS="$APP_CONTENTS/Frameworks"

# Create directories
mkdir -p "$APP_MACOS"
mkdir -p "$APP_RESOURCES"
mkdir -p "$APP_FRAMEWORKS"

# Copy the app icon
echo "Copying app icon..."
cp "App/Resources/AppIcon.icns" "$APP_RESOURCES/"

# Compile the Core Package as a module with the correct install name
echo "Building Core Package module..."
swiftc -module-name TMBM \
    -emit-module \
    -emit-library \
    -module-link-name TMBM \
    -parse-as-library \
    -target arm64-apple-macosx13.0 \
    -Xlinker -install_name -Xlinker @rpath/libTMBM.dylib \
    -o "$CORE_MODULE_PATH/libTMBM.dylib" \
    $CORE_FILES

if [ $? -ne 0 ]; then
    echo "Core Package build failed. Please check the errors above."
    exit 1
fi

# Copy the Core Package module and library to the Frameworks directory
cp "$CORE_MODULE_PATH/libTMBM.dylib" "$APP_FRAMEWORKS/"

# Find all Swift files in the App
APP_FILES=$(find App/Sources -name "*.swift" | tr '\n' ' ')

# Compile the app with the Core Package module and correct rpath
echo "Building App with CorePackage..."
swiftc -o "$APP_MACOS/TMBMApp" \
    $APP_FILES \
    -I "$CORE_MODULE_PATH" \
    -L "$CORE_MODULE_PATH" \
    -lTMBM \
    -framework AppKit \
    -framework SwiftUI \
    -Xlinker -rpath -Xlinker @executable_path/../Frameworks

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Build failed. Please check the errors above."
    exit 1
fi

# Copy Info.plist from App directory
echo "Copying Info.plist..."
cp "App/Info.plist" "$APP_CONTENTS/Info.plist"

# Code sign the dylib
echo "Code signing the dylib..."
codesign --force --sign "-" "$APP_FRAMEWORKS/libTMBM.dylib"

# Create a simple entitlements file
cat > "build/entitlements.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.bookmarks.app-scope</key>
    <true/>
</dict>
</plist>
EOF

# Code sign the app
echo "Code signing the app..."
codesign --force --deep --sign "-" --entitlements "build/entitlements.plist" "$APP_BUNDLE"

echo "Build successful! App bundle created at: $APP_BUNDLE"
echo "You can now open the app with: open $APP_BUNDLE"

# Clean up build artifacts
rm -rf "$CORE_MODULE_PATH"
rm -f "build/entitlements.plist"

# Only open the app if not in CI environment
if [ -z "$CI" ]; then
    echo "Opening the app..."
    open "$APP_BUNDLE"
else
    echo "Skipping app opening in CI environment."
fi 