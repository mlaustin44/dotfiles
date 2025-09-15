#!/bin/bash

# Check if any external display is connected
EXTERNAL_DISPLAY=$(find /sys/class/drm/*/status -exec grep -l "^connected$" {} \; | grep -v eDP)

if [ -n "$EXTERNAL_DISPLAY" ]; then
    # External display connected - inhibit lid switch
    systemd-inhibit --what=handle-lid-switch --who="External Monitor" --why="External display connected" --mode=block sleep infinity &
    echo $! > /var/run/lid-inhibit.pid
else
    # No external display - remove inhibit
    if [ -f /var/run/lid-inhibit.pid ]; then
        kill $(cat /var/run/lid-inhibit.pid) 2>/dev/null
        rm /var/run/lid-inhibit.pid
    fi
fi
