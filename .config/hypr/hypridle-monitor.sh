#!/bin/bash

switch_hypridle() {
    # Check if eDP-1 is active
    if hyprctl monitors | grep -q "Monitor eDP-1.*disabled: false"; then
        CONFIG="$HOME/.config/hypr/hypridle-laptop.conf"
    else
        CONFIG="$HOME/.config/hypr/hypridle-docked.conf"
    fi
    
    # Update symlink and restart hypridle
    CURRENT_LINK=$(readlink ~/.config/hypr/hypridle.conf)
    if [ "$CURRENT_LINK" != "$CONFIG" ]; then
        pkill hypridle
        ln -sf "$CONFIG" ~/.config/hypr/hypridle.conf
        hypridle &> /dev/null &
    fi
}

# Initial switch on script start
switch_hypridle

# Ensure hypridle is running
if ! pidof hypridle > /dev/null; then
    hypridle &> /dev/null &
fi

# Listen for Hyprland events
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "Error: Not running under Hyprland"
    exit 1
fi

handle() {
    case $1 in
        monitoradded* | monitorremoved* | focusedmon*)
            switch_hypridle
            ;;
    esac
}

SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - UNIX-CONNECT:$SOCKET_PATH | while read -r line; do
    handle "$line"
done
