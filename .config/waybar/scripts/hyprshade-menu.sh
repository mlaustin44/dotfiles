#!/bin/bash
# Night light filter selection menu using fuzzel

# Get current filter
CURRENT=$(hyprshade current 2>/dev/null)

# Build menu
MENU="🌙 Off (off)
---
🔥 Warm 3000K (night-3000k)
🟠 3500K (night-3500k)
🟡 4000K (night-4000k)
🌕 4500K (night-4500k)
⚪ 5000K (night-5000k)
❄️  Cool 5500K (night-5500k)
---
🌈 Vibrance (vibrance)
🔵 Blue Light Filter (blue-light-filter)"

# Show menu and get selection
CHOICE=$(echo "$MENU" | fuzzel --dmenu -p "Night Light Filter:")

# Parse selection
if [ -z "$CHOICE" ] || [ "$CHOICE" = "---" ]; then
    exit 0
fi

# Extract action from parentheses
ACTION=$(echo "$CHOICE" | grep -oP '\(\K[^)]+')

# Handle selection
if [ -z "$ACTION" ]; then
    exit 0
elif [ "$ACTION" = "off" ]; then
    hyprshade off
    notify-send -t 2000 -a "Night Light" "Filter disabled"
else
    hyprshade on "$ACTION"
    # Save temp if it's a night filter
    if [[ "$ACTION" =~ night-([0-9]+)k ]]; then
        echo "${BASH_REMATCH[1]}" > /tmp/hyprshade-temp
    fi
    notify-send -t 2000 -a "Night Light" "Applied ${ACTION}"
fi