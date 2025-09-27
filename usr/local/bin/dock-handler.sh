#!/bin/bash
# Only process remove events from DRM subsystem
#if [ "$ACTION" != "remove" ] || [ "$SUBSYSTEM" != "drm" ]; then
#    exit 0
#fi

# Wait for DRM to settle
sleep 2

# Check for ANY external monitor
EXTERNAL=$(find /sys/class/drm/*/status 2>/dev/null | xargs grep -l "^connected$" | grep -v eDP)

# Switch hypridle config based on dock state
if [ -z "$EXTERNAL" ]; then
    # No external monitors - laptop mode
    ln -sf /home/mlaustin/.config/hypr/hypridle-laptop.conf /home/mlaustin/.config/hypr/hypridle.conf
    sudo -u mlaustin HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/) pkill hypridle
    sudo -u mlaustin HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/) /usr/bin/hypridle &
    logger "Switched to laptop hypridle config"

    # Original suspend logic
    LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null)
    if echo "$LID_STATE" | grep -q closed; then
        logger "Last external monitor disconnected with lid closed - suspending"
        systemctl suspend
    fi
else
    # External monitors present - docked mode
    ln -sf /home/mlaustin/.config/hypr/hypridle-docked.conf /home/mlaustin/.config/hypr/hypridle.conf
    sudo -u mlaustin HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/) pkill hypridle
    sudo -u mlaustin HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/) /usr/bin/hypridle &
    logger "Switched to docked hypridle config"
fi
