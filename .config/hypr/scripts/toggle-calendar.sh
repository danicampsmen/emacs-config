#!/usr/bin/env bash
# ==============================================================================
# Toggle GNOME-style Calendar Popup para Waybar en Hyprland
# ==============================================================================
set -euo pipefail

if pgrep -f "calendar-popup.py" > /dev/null; then
    pkill -f "calendar-popup.py"
else
    python3 /home/fayfer/.config/hypr/scripts/calendar-popup.py &
fi
