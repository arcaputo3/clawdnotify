#!/bin/bash
# Auto-install ClawdNotify on first session
# Runs silently - only outputs on error

INSTALL_DIR="$HOME/.clawdnotify"
APP_PATH="$INSTALL_DIR/ClawdNotify.app"

# Already installed? Exit silently
[ -d "$APP_PATH" ] && exit 0

# Find plugin root (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Build and install
mkdir -p "$INSTALL_DIR"
cd "$PLUGIN_ROOT/app" || exit 1

# Detect architecture
ARCH=$(uname -m)
TARGET="${ARCH}-apple-macosx12.0"

# Compile
swiftc -O -o ClawdNotify -target "$TARGET" Sources/main.swift 2>/dev/null || exit 1

# Create app bundle
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"
cp ClawdNotify "$APP_PATH/Contents/MacOS/"
cp Info.plist "$APP_PATH/Contents/"
if [ -f "$PLUGIN_ROOT/assets/clawd.icns" ]; then
    cp "$PLUGIN_ROOT/assets/clawd.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$APP_PATH/Contents/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$APP_PATH/Contents/Info.plist"
fi

# Copy notify script
cp "$PLUGIN_ROOT/hooks/notify.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/notify.sh"

# Code sign
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null

# Create default config
[ ! -f "$INSTALL_DIR/config" ] && cat > "$INSTALL_DIR/config" << 'EOF'
# ClawdNotify configuration
# terminal_bundle_id=com.mitchellh.ghostty
EOF

# Cleanup build artifact
rm -f ClawdNotify
