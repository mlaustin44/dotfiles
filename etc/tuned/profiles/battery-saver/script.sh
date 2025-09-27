#!/bin/bash
# Battery saver script for tuned

. /usr/lib/tuned/functions

start() {
    # Disable turbo boost
    [ -f /sys/devices/system/cpu/cpufreq/boost ] && echo 0 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
    
    # Aggressive USB autosuspend - 2 second delay
    for device in /sys/bus/usb/devices/*/power; do
        if [ -d "$device" ]; then
            [ -f "$device/control" ] && echo auto > "$device/control" 2>/dev/null || true
            [ -f "$device/autosuspend" ] && echo 1 > "$device/autosuspend" 2>/dev/null || true
            [ -f "$device/autosuspend_delay_ms" ] && echo 2000 > "$device/autosuspend_delay_ms" 2>/dev/null || true
        fi
    done
    
    # Enable runtime PM for all PCI devices
    for device in /sys/bus/pci/devices/*/power/control; do
        [ -f "$device" ] && echo auto > "$device" 2>/dev/null || true
    done
    
    return 0
}

stop() {
    # Restore defaults on profile deactivation
    [ -f /sys/devices/system/cpu/cpufreq/boost ] && echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
    
    return 0
}

process $@