#!/bin/bash
switch_hypridle() {
    # Check if eDP-1 exists and is enabled (need -A25 to reach the disabled line)
    if hyprctl monitors | grep -A25 "Monitor eDP-1" | grep -q "disabled: false"; then
        CONFIG="$HOME/.config/hypr/hypridle-laptop.conf"
        echo "Switching to laptop config"
    else
        CONFIG="$HOME/.config/hypr/hypridle-docked.conf"
        echo "Switching to docked config"
    fi
    
    # Kill any running hypridle first
    pkill hypridle
    sleep 1
    
    # Update symlink
    ln -sf "$CONFIG" ~/.config/hypr/hypridle.conf
    
    # Start hypridle in background
    hypridle > /dev/null 2>&1 &
    
    echo "Started hypridle with $CONFIG"
}

# Initial switch on script start
switch_hypridle

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
