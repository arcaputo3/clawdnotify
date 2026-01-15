#!/bin/bash
# Build ClawdNotify.app from Swift source
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="ClawdNotify"
APP_BUNDLE="${APP_NAME}.app"

echo "Building ${APP_NAME}..."

# Remove old app bundle
rm -rf "$APP_BUNDLE"

# Create app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    TARGET="arm64-apple-macosx12.0"
else
    TARGET="x86_64-apple-macosx12.0"
fi

# Compile Swift source
swiftc -O -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    -target "$TARGET" \
    Sources/main.swift

# Copy Info.plist
cp Info.plist "$APP_BUNDLE/Contents/"

# Copy icon if it exists
ASSETS_DIR="../assets"
if [ -f "$ASSETS_DIR/clawd.icns" ]; then
    cp "$ASSETS_DIR/clawd.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    # Add icon reference to Info.plist
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP_BUNDLE/Contents/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$APP_BUNDLE/Contents/Info.plist"
fi

# Ad-hoc code sign
codesign --force --deep --sign - "$APP_BUNDLE"

echo "Built: $APP_BUNDLE"
echo "Done!"
