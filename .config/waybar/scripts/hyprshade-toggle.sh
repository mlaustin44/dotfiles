#!/bin/bash

TEMP_FILE="/tmp/hyprshade-temp"

case "$1" in
    "cycle-temp")
        # Get current temperature
        CURRENT_TEMP=$(cat "$TEMP_FILE" 2>/dev/null || echo "4500")
        
        # Cycle through temperatures
        case "$CURRENT_TEMP" in
            "3000") NEW_TEMP="3500" ;;
            "3500") NEW_TEMP="4000" ;;
            "4000") NEW_TEMP="4500" ;;
            "4500") NEW_TEMP="5000" ;;
            "5000") NEW_TEMP="5500" ;;
            "5500") NEW_TEMP="3000" ;;
            *) NEW_TEMP="4500" ;;
        esac
        
        echo "$NEW_TEMP" > "$TEMP_FILE"
        
        # Update the main shader symlink
        ln -sf ~/.config/hypr/shaders/night-${NEW_TEMP}k.glsl ~/.config/hypr/shaders/night.glsl
        
        # If shader is currently on, reload it
        if hyprshade current | grep -q "night"; then
            hyprshade off
            sleep 0.1
            hyprshade on night
        fi
        ;;
        
    *)
        # Manual toggle since hyprshade toggle is broken
        if hyprshade current | grep -q "night"; then
            hyprshade off
        else
            hyprshade on night
        fi
        ;;
esac
