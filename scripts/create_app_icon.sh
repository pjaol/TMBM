#!/bin/bash

# Create temporary iconset directory
ICONSET="AppIcon.iconset"
mkdir -p "$ICONSET"

# Generate icon files at different sizes
sips -z 16 16     assets/tmbm_icon.png --out "$ICONSET/icon_16x16.png"
sips -z 32 32     assets/tmbm_icon.png --out "$ICONSET/icon_16x16@2x.png"
sips -z 32 32     assets/tmbm_icon.png --out "$ICONSET/icon_32x32.png"
sips -z 64 64     assets/tmbm_icon.png --out "$ICONSET/icon_32x32@2x.png"
sips -z 128 128   assets/tmbm_icon.png --out "$ICONSET/icon_128x128.png"
sips -z 256 256   assets/tmbm_icon.png --out "$ICONSET/icon_128x128@2x.png"
sips -z 256 256   assets/tmbm_icon.png --out "$ICONSET/icon_256x256.png"
sips -z 512 512   assets/tmbm_icon.png --out "$ICONSET/icon_256x256@2x.png"
sips -z 512 512   assets/tmbm_icon.png --out "$ICONSET/icon_512x512.png"
sips -z 1024 1024 assets/tmbm_icon.png --out "$ICONSET/icon_512x512@2x.png"

# Convert iconset to icns file
iconutil -c icns "$ICONSET"

# Move the icns file to the app's resources
mv AppIcon.icns App/Resources/

# Clean up
rm -rf "$ICONSET"

echo "App icon created successfully!" 