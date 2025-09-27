#!/bin/bash
# Cycle through power profiles

# Get current profile
CURRENT=$(tuned-adm active 2>/dev/null | grep -oP 'Current active profile: \K.*')

# Check AC status
AC_ONLINE=$(cat /sys/class/power_supply/AC0/online 2>/dev/null || echo "0")

# Determine next profile based on current and AC status
if [ "$AC_ONLINE" = "1" ]; then
    # On AC power - cycle: plugged-normal → max-performance → plugged-normal
    case "$CURRENT" in
        "plugged-normal")
            NEXT="max-performance"
            ;;
        "max-performance")
            NEXT="plugged-normal"
            ;;
        *)
            # Default to plugged-normal if on unknown profile
            NEXT="plugged-normal"
            ;;
    esac
else
    # On battery - cycle: battery-normal → battery-saver → battery-normal
    case "$CURRENT" in
        "battery-normal")
            NEXT="battery-saver"
            ;;
        "battery-saver")
            NEXT="battery-normal"
            ;;
        *)
            # Default to battery-normal if on unknown profile
            NEXT="battery-normal"
            ;;
    esac
fi

# Switch profile
sudo tuned-adm profile "$NEXT"

# Send notification
notify-send -t 2000 -a "Power Profile" "Switched to ${NEXT}"