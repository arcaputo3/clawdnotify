#!/bin/bash
# ClawdNotify - Claude Code notification hook
# - Bell: always rings (tab attention indicator)
# - Sound: plays only when away from terminal
# - Notification: shows only when away from terminal
# Usage: notify.sh [stop|permission]

event="${1:-stop}"

# Full session path
context="$PWD"

# Ring terminal bell to trigger tab attention indicator
# Find the TTY of our ancestor shell process and write bell directly to it
parent_tty=""
p=$$
while [ "$p" != "1" ] && [ -z "$parent_tty" ]; do
    tty_check=$(ps -o tty= -p "$p" 2>/dev/null | tr -d ' ')
    if [ -n "$tty_check" ] && [ "$tty_check" != "??" ]; then
        parent_tty="/dev/$tty_check"
    fi
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
done

if [ -n "$parent_tty" ] && [ -w "$parent_tty" ]; then
    printf '\a' > "$parent_tty"
fi

# Check if user is focused on this session
is_focused=false

# Get frontmost app info
frontmost_name=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null | tr '[:upper:]' '[:lower:]')

# Check if frontmost app is a known terminal
terminal_focused=false
case "$frontmost_name" in
    *ghostty*|*iterm*|*terminal*|*alacritty*|*kitty*|*wezterm*)
        terminal_focused=true
        ;;
esac

# Determine if this session is focused
if [ "$terminal_focused" = "true" ]; then
    if [ -n "$TMUX" ]; then
        # In tmux: also check if this window and pane are active
        window_active=$(tmux display-message -p '#{window_active}' 2>/dev/null)
        pane_active=$(tmux display-message -p '#{pane_active}' 2>/dev/null)
        if [ "$window_active" = "1" ] && [ "$pane_active" = "1" ]; then
            is_focused=true
        fi
    else
        # Not in tmux: terminal frontmost means focused
        is_focused=true
    fi
fi

# Play sound only if not focused
if [ "$is_focused" = "false" ]; then
    afplay /System/Library/Sounds/Submarine.aiff &
fi

# Set message based on event type
if [ "$event" = "permission" ]; then
    subtitle="Permission needed"
else
    subtitle="Ready for input"
fi

# Show notification only if not in terminal (bell handles in-terminal alerts)
if [ "$terminal_focused" = "false" ]; then
    printf '%s\n%s\n%s\n' "Claude Code" "$subtitle" "$context" > "$HOME/.claude-notify-params"
    open "$HOME/.clawdnotify/ClawdNotify.app" --args --show
fi
