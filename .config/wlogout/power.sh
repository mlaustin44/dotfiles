#!/usr/bin/env bash

terminate_clients() {
    # Kill all Hyprland clients gracefully
    hyprctl clients -j | jq -r '.[] | .pid' | xargs -r kill -TERM
    
    # Optional: wait briefly for cleanup
    sleep 1
    
    # Stop listeners if the script exists
    [ -f "$HOME/.config/ml4w/listeners.sh" ] && \
        bash "$HOME/.config/ml4w/listeners.sh" --stopall
}

case "$1" in
    exit)
        terminate_clients
        hyprctl dispatch exit ;;
    lock)
        hyprlock ;;
    reboot)
        terminate_clients
        systemctl reboot ;;
    shutdown)
        terminate_clients
        systemctl poweroff ;;
    suspend)
        systemctl suspend ;;
    hibernate)
        systemctl hibernate ;;
esac