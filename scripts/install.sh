#!/bin/bash
# ClawdNotify installer
# Builds and installs the notification app to ~/.clawdnotify/
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_DIR="$HOME/.clawdnotify"

echo "Installing ClawdNotify..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Build the app
echo "Building ClawdNotify.app..."
cd "$REPO_DIR/app"
bash build.sh

# Copy app to install directory
echo "Installing to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR/ClawdNotify.app"
cp -R ClawdNotify.app "$INSTALL_DIR/"

# Copy notify.sh
cp "$REPO_DIR/hooks/notify.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/notify.sh"

# Create default config if it doesn't exist
if [ ! -f "$INSTALL_DIR/config" ]; then
    cat > "$INSTALL_DIR/config" << 'EOF'
# ClawdNotify configuration
# Uncomment and modify to customize behavior

# Terminal bundle ID (default: Ghostty)
# terminal_bundle_id=com.mitchellh.ghostty

# Other popular terminals:
# terminal_bundle_id=com.googlecode.iterm2
# terminal_bundle_id=com.apple.Terminal
# terminal_bundle_id=org.alacritty
# terminal_bundle_id=net.kovidgoyal.kitty
# terminal_bundle_id=com.github.wez.wezterm
EOF
fi

echo ""
echo "Installation complete!"
echo ""
echo "To use with Claude Code, add these hooks to your settings.json:"
echo ""
echo '  "hooks": {'
echo '    "Stop": [{ "type": "command", "command": "~/.clawdnotify/notify.sh stop" }],'
echo '    "PermissionRequest": [{ "type": "command", "command": "~/.clawdnotify/notify.sh permission" }]'
echo '  }'
echo ""
echo "Or install as a Claude Code plugin:"
echo "  claude /plugin install $REPO_DIR"
echo ""
