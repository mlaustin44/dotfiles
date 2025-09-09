#!/bin/bash

MODES=("external_only" "mirrored" "extended")
STATE_FILE="/tmp/display_mode_state"
LID_STATE=$(cat /proc/acpi/button/lid/LID*/state | grep -o "open\|closed")

# Check if external display connected
EXTERNAL=$(find /sys/class/drm/*/status -exec grep -l "^connected$" {} \; | grep -v eDP)

if [ -z "$EXTERNAL" ]; then
    echo "No external display connected"
    exit 0
fi

# Check if it's the Dell monitor
if hyprctl monitors -j | grep -q "DELL U4021QW"; then
    echo "Dell monitor detected - staying in dedicated mode"
    exit 0
fi

# Detect resolution of external monitor
RESOLUTION=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | "\(.width)x\(.height)"')

# Map to profile suffix
case "$RESOLUTION" in
    1920x1080)
        SUFFIX="_1080p"
        ;;
    1920x1200)
        SUFFIX="_1920x1200"
        ;;
    3840x2160|5120x*)
        SUFFIX="_4k"
        ;;
    *)
        # Default to 1080p for unknown resolutions
        SUFFIX="_1080p"
        ;;
esac

# If lid is closed, force external only
if [ "$LID_STATE" = "closed" ]; then
    kanshictl switch "external_only${SUFFIX}"
    exit 0
fi

# Lid is open - cycle through modes
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "0")
NEXT=$(( (CURRENT + 1) % 3 ))
echo "$NEXT" > "$STATE_FILE"

MODE="${MODES[$NEXT]}${SUFFIX}"

# Special case for mirrored mode - use simplified profiles
if [[ "${MODES[$NEXT]}" == "mirrored" ]]; then
    if [[ "$SUFFIX" == "_4k" ]]; then
        MODE="mirrored_4k"
    else
        MODE="mirrored_1080p"
    fi
fi

kanshictl switch "$MODE"
notify-send "Display Mode" "Switched to: ${MODES[$NEXT]} (${RESOLUTION})" -t 2000
