#!/bin/bash
# Only handle display-related disconnections

# Only process remove events from DRM subsystem
if [ "$ACTION" != "remove" ] || [ "$SUBSYSTEM" != "drm" ]; then
    exit 0
fi

# Wait for DRM to settle
sleep 2

# Check for ANY external monitor
EXTERNAL=$(find /sys/class/drm/*/status 2>/dev/null | xargs grep -l "^connected$" | grep -v eDP)

if [ -z "$EXTERNAL" ]; then
    LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null)
    if echo "$LID_STATE" | grep -q closed; then
        logger "Last external monitor disconnected with lid closed - suspending"
        systemctl suspend
    fi
fi
