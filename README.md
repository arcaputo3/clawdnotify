# ClawdNotify

Native macOS notifications for [Claude Code](https://claude.ai/claude-code) with smart focus detection and terminal bell attention indicators.

## Features

- **Native macOS notifications** - Uses `UNUserNotificationCenter` for modern notification banners with a "Show" action button
- **Bell attention indicator** - Rings terminal bell to mark tabs needing attention (works great with Ghostty's tab attention feature)
- **Smart focus detection** - Only plays sounds and shows notifications when you're away from your terminal
- **tmux aware** - Properly detects focus even when running inside tmux sessions
- **Configurable terminal** - Defaults to Ghostty, but supports any terminal app
- **Auto-install** - Builds automatically on first Claude Code session

## Installation

In Claude Code, run:

```
/plugin marketplace add arcaputo3/clawdnotify
/plugin install clawdnotify@clawdnotify
```

The app builds automatically on your first Claude Code session.

<details>
<summary>Manual installation</summary>

```bash
git clone https://github.com/arcaputo3/clawdnotify.git
cd clawdnotify
./scripts/install.sh
```

Then add to your Claude Code `settings.json`:

```json
{
  "hooks": {
    "Stop": [{ "type": "command", "command": "~/.clawdnotify/notify.sh stop" }],
    "PermissionRequest": [{ "type": "command", "command": "~/.clawdnotify/notify.sh permission" }]
  }
}
```
</details>

## How It Works

When Claude Code stops (completes a task or needs input), ClawdNotify:

1. **Always** rings the terminal bell (triggers tab attention in supported terminals)
2. **If you're away from the terminal**: plays a sound and shows a notification
3. **If you're in the terminal but different tmux pane**: plays a sound (bell already visible)
4. **If you're focused on the Claude session**: does nothing extra (you're already there!)

## Configuration

Create or edit `~/.clawdnotify/config` to customize:

```bash
# Terminal bundle ID (default: Ghostty)
terminal_bundle_id=com.mitchellh.ghostty

# Other popular terminals:
# terminal_bundle_id=com.googlecode.iterm2
# terminal_bundle_id=com.apple.Terminal
# terminal_bundle_id=org.alacritty
# terminal_bundle_id=net.kovidgoyal.kitty
# terminal_bundle_id=com.github.wez.wezterm
```

## Requirements

- macOS 12.0 or later
- Swift compiler (included with Xcode Command Line Tools)

## Uninstall

```bash
./scripts/uninstall.sh
```

Or manually:

```bash
rm -rf ~/.clawdnotify
rm -f ~/.claude-notify-params
```

## License

MIT License - see [LICENSE](LICENSE) for details.
