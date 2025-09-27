#!/bin/bash
# Power profile selection menu using fuzzel

# Get current profile and battery info
CURRENT=$(tuned-adm active 2>/dev/null | grep -oP 'Current active profile: \K.*')
CHARGE_LIMIT=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo "?")

# Check AC status
AC_ONLINE=$(cat /sys/class/power_supply/AC0/online 2>/dev/null || echo "0")

# Build menu based on AC status
if [ "$AC_ONLINE" = "1" ]; then
    # On AC - show plugged profiles
    MENU="󰚥 Balanced (plugged-normal)
󱐋 Max Performance (max-performance)
󰂄 Battery Normal (battery-normal)
󰾆 Battery Saver (battery-saver)
---
󱈏 Battery Limit: 60% (limit-60)
󱊣 Battery Limit: 80% (limit-80)
󱊦 Battery Limit: 100% (limit-100)"
else
    # On battery - show battery profiles first
    MENU="󰂄 Battery Normal (battery-normal)
󰾆 Battery Saver (battery-saver)
󰚥 Balanced (plugged-normal)
󱐋 Max Performance (max-performance)
---
󱈏 Battery Limit: 60% (limit-60)
󱊣 Battery Limit: 80% (limit-80)
󱊦 Battery Limit: 100% (limit-100)"
fi

# Show menu and get selection
CHOICE=$(echo "$MENU" | fuzzel --dmenu -p "Power [Limit: ${CHARGE_LIMIT}%]:")

# Parse selection
if [ -z "$CHOICE" ] || [ "$CHOICE" = "---" ]; then
    exit 0
fi

# Extract action from parentheses
ACTION=$(echo "$CHOICE" | grep -oP '\(\K[^)]+')

# Handle selection
if [ -z "$ACTION" ]; then
    exit 0
elif [[ "$ACTION" == limit-* ]]; then
    # Battery limit change
    LIMIT="${ACTION#limit-}"
    echo "$LIMIT" | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold >/dev/null
    notify-send -t 2000 -a "Battery Limit" "Set charge limit to ${LIMIT}%"
else
    # Profile switch
    sudo tuned-adm profile "$ACTION"
    notify-send -t 2000 -a "Power Profile" "Switched to ${ACTION}"
fi