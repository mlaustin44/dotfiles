#!/bin/bash

# Get brightness percentage
BRIGHTNESS=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

# Get shade status and temp
SHADE_ON=$(hyprshade current 2>/dev/null | grep -q "night" && echo "true" || echo "false")
TEMP=$(cat /tmp/hyprshade-temp 2>/dev/null || echo "4500")

# Get schedule from config
if [ -f ~/.config/hypr/hyprshade.toml ]; then
    SUNSET=$(grep "start =" ~/.config/hypr/hyprshade.toml | cut -d'"' -f2)
    SUNRISE=$(grep "end =" ~/.config/hypr/hyprshade.toml | cut -d'"' -f2)
else
    SUNSET="19:14"
    SUNRISE="06:51"
fi

# Build tooltip
if [ "$SHADE_ON" = "true" ]; then
    SHADE_STATUS="Active (${TEMP}K)"
    CLASS="shade-on"
else
    SHADE_STATUS="Inactive"
    CLASS="shade-off"
fi

TOOLTIP="Brightness: ${BRIGHTNESS}%\nNight Light: $SHADE_STATUS\nSchedule: $SUNSET - $SUNRISE\n\nScroll: Brightness | Click: Toggle | Right-click: Temperature"

# Output with class for styling
echo "{\"text\": \"\uf0eb ${BRIGHTNESS}%\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$CLASS\"}"
