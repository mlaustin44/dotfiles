#!/bin/bash
# Kill hypridle
pkill hypridle

# Detect and switch config
if hyprctl monitors | grep -A25 "Monitor eDP-1" | grep -q "disabled: false"; then
    echo "Switching to laptop mode"
    ln -sf ~/.config/hypr/hypridle-laptop.conf ~/.config/hypr/hypridle.conf
else
    echo "Switching to docked mode"
    ln -sf ~/.config/hypr/hypridle-docked.conf ~/.config/hypr/hypridle.conf
fi

# Restart hypridle
/usr/bin/hypridle &
