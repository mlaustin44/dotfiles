#!/bin/bash

switch_hypridle() {
    # Check if eDP-1 is active
    if hyprctl monitors | grep -q "Monitor eDP-1.*disabled: false"; then
        CONFIG="$HOME/.config/hypr/hypridle-laptop.conf"
    else
        CONFIG="$HOME/.config/hypr/hypridle-docked.conf"
    fi
    
    # Only restart if config changed
    CURRENT=$(pgrep -a hypridle | grep -oP '(?<=-c )\S+')
    if [ "$CURRENT" != "$CONFIG" ]; then
        pkill hypridle
        hypridle -c "$CONFIG" &
    fi
}

# Initial switch on script start
switch_hypridle

# Listen for Hyprland events
handle() {
    case $1 in
        monitoradded* | monitorremoved* | focusedmon*)
            switch_hypridle
            ;;
    esac
}

socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    handle "$line"
done