#!/bin/bash
logger "dock-disconnect.sh triggered"
LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null)
logger "Lid state: $LID_STATE"
if echo "$LID_STATE" | grep -q closed; then
    logger "Lid is closed - suspending"
    systemctl suspend
else
    logger "Lid is open - not suspending"
fi
