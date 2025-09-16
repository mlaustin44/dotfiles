#!/bin/bash

# Check for external displays
EXTERNAL=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -1)

if [ -z "$EXTERNAL" ]; then
    notify-send "No external display"
    exit 0
fi

# Check lid state
LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null | grep -o "open\|closed")

if [ "$LID_STATE" = "closed" ]; then
    # Lid closed - stay in external only mode
    hyprctl keyword monitor "eDP-1,disable"
    notify-send "Clamshell mode (lid closed)"
    exit 0
fi

# Lid is open - cycle through modes
# Get current state
if ! hyprctl monitors -j | jq -e '.[] | select(.name == "eDP-1" and .disabled == false)' > /dev/null; then
    MODE="external"
elif hyprctl monitors -j | jq -e '.[] | select(.name == "eDP-1") | .x == 0 and .y == 0' > /dev/null && \
     hyprctl monitors -j | jq -e ".[] | select(.name == \"$EXTERNAL\") | .x == 0 and .y == 0" > /dev/null; then
    MODE="mirror"
else
    MODE="extend"
fi

# Cycle to next mode
case "$MODE" in
    external)
        # Switch to mirror - both at 0x0
        hyprctl keyword monitor "eDP-1,preferred,0x0,1.25"
        hyprctl keyword monitor "$EXTERNAL,preferred,0x0,1"
        notify-send "Display: Mirrored"
        ;;
    mirror)
        # Switch to extend - external to the right
        hyprctl keyword monitor "eDP-1,2880x1800,0x0,1.25"
        hyprctl keyword monitor "$EXTERNAL,preferred,2304x0,1"
        notify-send "Display: Extended"
        ;;
    extend)
        # Switch to external only
        hyprctl keyword monitor "eDP-1,disable"
        notify-send "Display: External Only"
        ;;
esac
