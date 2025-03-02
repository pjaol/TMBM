#!/bin/bash

# Script to create a DMG file for TMBM App distribution

set -e  # Exit on any error

echo "Creating DMG for TMBM App..."

# Navigate to the project directory
cd "$(dirname "$0")/.."

# Ensure the app is built first
if [ ! -d "build/TMBMApp.app" ]; then
    echo "Building app first..."
    ./scripts/build_app_bundle.sh
fi

# Set up variables
DMG_NAME="TMBM-Installer.dmg"
TEMP_DMG="temp.dmg"
VOLUME_NAME="TMBM Installer"
APP_NAME="TMBMApp.app"
DMG_DIR="build"

# Clean up any existing DMG and ensure mounted volumes are unmounted
rm -f "$DMG_DIR/$DMG_NAME"
rm -f "$DMG_DIR/$TEMP_DMG"
hdiutil detach "/Volumes/$VOLUME_NAME" -force 2>/dev/null || true

# Create a temporary directory for DMG contents
TEMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TEMP_DIR"

# Create the DMG structure
mkdir -p "$TEMP_DIR/.background"

# Copy the app bundle
cp -R "build/$APP_NAME" "$TEMP_DIR/"

# Create Applications directory symlink
ln -s /Applications "$TEMP_DIR/Applications"

# Create the background image (simple white with text)
cat > "$TEMP_DIR/.background/background.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg width="640" height="480" xmlns="http://www.w3.org/2000/svg">
    <rect width="100%" height="100%" fill="white"/>
    <text x="320" y="240" font-family="Helvetica" font-size="24" text-anchor="middle" fill="#666">
        Drag TMBM to Applications
    </text>
</svg>
EOF

# Convert SVG to PNG using sips
/usr/bin/qlmanage -t -s 640 -o "$TEMP_DIR/.background" "$TEMP_DIR/.background/background.svg" >/dev/null 2>&1
mv "$TEMP_DIR/.background/background.svg.png" "$TEMP_DIR/.background/background.png"

# Create the DMG
echo "Creating temporary DMG..."
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TEMP_DIR" -ov -format UDRW "$DMG_DIR/$TEMP_DMG" >/dev/null

# Mount the DMG
echo "Mounting DMG to configure appearance..."
MOUNT_POINT=$(hdiutil attach -readwrite -noverify "$DMG_DIR/$TEMP_DMG" | grep "$VOLUME_NAME" | cut -f 3-)
echo "Mounted at: $MOUNT_POINT"

# Wait for the disk to be fully mounted
sleep 3

# Configure the DMG appearance
echo "Configuring DMG appearance..."
cat > "$TEMP_DIR/dmg_config.applescript" << EOF
tell application "Finder"
    delay 1
    tell disk "$VOLUME_NAME"
        open
        delay 1
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {400, 100, 1040, 580}
        set theViewOptions to icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set background picture of theViewOptions to file ".background:background.png"
        set position of item "$APP_NAME" of container window to {160, 240}
        set position of item "Applications" of container window to {480, 240}
        update without registering applications
        delay 1
        close
    end tell
end tell
EOF

# Run the AppleScript
osascript "$TEMP_DIR/dmg_config.applescript" || true

# Wait a moment for Finder to update
sleep 3

# Unmount the DMG
echo "Unmounting DMG..."
hdiutil detach "$MOUNT_POINT" -force || (sleep 5 && hdiutil detach "$MOUNT_POINT" -force)

# Wait for the unmount to complete
sleep 2

# Convert the DMG to compressed, read-only format
echo "Creating final compressed DMG..."
hdiutil convert "$DMG_DIR/$TEMP_DMG" -format UDZO -o "$DMG_DIR/$DMG_NAME" >/dev/null

# Clean up
rm -f "$DMG_DIR/$TEMP_DMG"
rm -rf "$TEMP_DIR"

echo "DMG creation complete!"
echo "Final DMG is at: $DMG_DIR/$DMG_NAME" 