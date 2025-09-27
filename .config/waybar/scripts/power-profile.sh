#!/bin/bash
# Waybar power profile display script

# Get current tuned profile
PROFILE=$(tuned-adm active 2>/dev/null | grep -oP 'Current active profile: \K.*')

# Get battery info
CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
CHARGE_LIMIT=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo "?")

# Get power consumption in watts (power_now is in microwatts)
POWER_NOW=$(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null || echo "0")
POWER_WATTS=$(awk "BEGIN {printf \"%.1f\", $POWER_NOW / 1000000}")

# Calculate time remaining
ENERGY_NOW=$(cat /sys/class/power_supply/BAT0/energy_now 2>/dev/null || echo "0")
ENERGY_FULL=$(cat /sys/class/power_supply/BAT0/energy_full 2>/dev/null || echo "1")

if [ "$STATUS" = "Charging" ] || [ "$STATUS" = "Full" ]; then
    # Time to full charge
    if [ "$POWER_NOW" -gt 0 ]; then
        ENERGY_TO_FULL=$((ENERGY_FULL - ENERGY_NOW))
        TIME_HOURS=$(awk "BEGIN {printf \"%.1f\", ($ENERGY_TO_FULL / $POWER_NOW)}")
        TIME_STR="${TIME_HOURS}h"
    else
        TIME_STR="Full"
    fi
else
    # Time to empty
    if [ "$POWER_NOW" -gt 0 ]; then
        TIME_HOURS=$(awk "BEGIN {printf \"%.1f\", ($ENERGY_NOW / $POWER_NOW)}")
        TIME_STR="${TIME_HOURS}h"
    else
        TIME_STR="∞"
    fi
fi

# Determine battery icon based on capacity (like standard battery module)
if [ "$CAPACITY" -ge 90 ]; then
    BATTERY_ICON="\uf240"  # Full
elif [ "$CAPACITY" -ge 70 ]; then
    BATTERY_ICON="\uf241"  # 3/4
elif [ "$CAPACITY" -ge 50 ]; then
    BATTERY_ICON="\uf242"  # 1/2
elif [ "$CAPACITY" -ge 30 ]; then
    BATTERY_ICON="\uf243"  # 1/4
else
    BATTERY_ICON="\uf244"  # Empty
fi

# Override icon if charging/plugged
if [ "$STATUS" = "Charging" ]; then
    BATTERY_ICON="\uf0e7"  # Lightning bolt
elif [ "$STATUS" = "Full" ]; then
    BATTERY_ICON="\uf1e6"  # Plug
fi

# Profile names for tooltip
case "$PROFILE" in
    "battery-saver")
        SHORT="Saver"
        CLASS="saver"
        ;;
    "battery-normal")
        SHORT="Normal"
        CLASS="battery"
        ;;
    "plugged-normal")
        SHORT="Balanced"
        CLASS="balanced"
        ;;
    "max-performance")
        SHORT="Perf"
        CLASS="performance"
        ;;
    *)
        SHORT="Unknown"
        CLASS="unknown"
        ;;
esac

# Build simple display like battery module (always uses battery icon)
TEXT="${BATTERY_ICON} ${CAPACITY}%"

# Tooltip with detailed info (escaped newlines for JSON)
TOOLTIP="Profile: ${PROFILE} (${SHORT})\\nBattery: ${CAPACITY}% (${STATUS})\\nCharge Limit: ${CHARGE_LIMIT}%\\nPower: ${POWER_WATTS}W\\nRemaining: ${TIME_STR}\\n\\nClick: Open battop\\nRight-click: Profile menu"

# Output JSON for waybar
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS"