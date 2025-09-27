#!/bin/bash
sleep 5  # Wait for Hyprland to fully start
pkill hypridle  # Kill any existing instances
sleep 1

# Detect laptop vs docked
if hyprctl monitors | grep -A25 "Monitor eDP-1" | grep -q "disabled: false"; then
    ln -sf ~/.config/hypr/hypridle-laptop.conf ~/.config/hypr/hypridle.conf
else
    ln -sf ~/.config/hypr/hypridle-docked.conf ~/.config/hypr/hypridle.conf
fi

# Start hypridle
exec hypridle
