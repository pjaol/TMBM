#!/bin/bash

# Script to build a proper macOS .app bundle for the TMBM App

echo "Building TMBM App Bundle..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Create a build directory if it doesn't exist
mkdir -p build

# Find all Swift files in the CorePackage except main.swift
CORE_FILES=$(find CorePackage/Sources -name "*.swift" | grep -v "main.swift" | tr '\n' ' ')

# Find all Swift files in the App
APP_FILES=$(find App/Sources -name "*.swift" | tr '\n' ' ')

# Create the app bundle structure
APP_BUNDLE="build/TMBMApp.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"

# Create directories
mkdir -p "$APP_MACOS"
mkdir -p "$APP_RESOURCES"

# Compile all Swift files together
echo "Building App with CorePackage..."
swiftc -o "$APP_MACOS/TMBMApp" \
    $APP_FILES \
    $CORE_FILES \
    -framework AppKit \
    -framework SwiftUI

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Build failed. Please check the errors above."
    exit 1
fi

# Create Info.plist
cat > "$APP_CONTENTS/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>TMBMApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.TMBMApp</string>
    <key>CFBundleName</key>
    <string>TMBMApp</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Copy resources if any
# cp -R App/Resources/* "$APP_RESOURCES/"

echo "Build successful! App bundle created at: $APP_BUNDLE"
echo "You can now open the app with: open $APP_BUNDLE"

# Open the app
open "$APP_BUNDLE" 