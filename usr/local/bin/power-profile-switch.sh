#!/bin/bash
# Helper script to switch tuned profiles quickly

show_usage() {
    echo "Usage: power-profile-switch.sh [saver|normal|plugged|performance|auto]"
    echo ""
    echo "Profiles:"
    echo "  saver        - Battery saver mode"
    echo "  normal       - Battery normal mode"  
    echo "  plugged      - Plugged in normal mode"
    echo "  performance  - Maximum performance"
    echo "  auto         - Auto-select based on AC power"
    echo ""
    echo "Current profile:"
    tuned-adm active 2>/dev/null || echo "  tuned not running"
}

auto_select() {
    # Check if on AC power
    if [ -f /sys/class/power_supply/AC0/online ]; then
        online=$(cat /sys/class/power_supply/AC0/online)
        if [ "$online" = "1" ]; then
            echo "AC power detected, switching to plugged-normal"
            tuned-adm profile plugged-normal
        else
            echo "Battery power detected, switching to battery-normal"
            tuned-adm profile battery-normal
        fi
    else
        echo "Cannot detect power state"
        exit 1
    fi
}

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

case "${1,,}" in
    saver|save)
        tuned-adm profile battery-saver
        echo "Switched to battery-saver mode"
        ;;
    normal|battery)
        tuned-adm profile battery-normal
        echo "Switched to battery-normal mode"
        ;;
    plugged|ac)
        tuned-adm profile plugged-normal
        echo "Switched to plugged-normal mode"
        ;;
    performance|perf|max)
        tuned-adm profile max-performance
        echo "Switched to max-performance mode"
        ;;
    auto)
        auto_select
        ;;
    *)
        show_usage
        ;;
esac