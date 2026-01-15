#!/bin/bash
# ClawdNotify uninstaller
# Removes the installed app and configuration
set -e

INSTALL_DIR="$HOME/.clawdnotify"

echo "Uninstalling ClawdNotify..."

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed $INSTALL_DIR"
else
    echo "ClawdNotify is not installed at $INSTALL_DIR"
fi

# Clean up parameter file
if [ -f "$HOME/.claude-notify-params" ]; then
    rm -f "$HOME/.claude-notify-params"
    echo "Removed ~/.claude-notify-params"
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "Remember to remove the hooks from your Claude Code settings.json if you added them manually."
echo ""
