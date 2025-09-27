#!/bin/bash
# Plugged normal script for tuned

. /usr/lib/tuned/functions

start() {
    # Enable turbo boost for performance
    [ -f /sys/devices/system/cpu/cpufreq/boost ] && echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
    
    # Disable USB autosuspend for responsiveness
    for device in /sys/bus/usb/devices/*/power; do
        if [ -d "$device" ]; then
            [ -f "$device/control" ] && echo on > "$device/control" 2>/dev/null || true
            [ -f "$device/autosuspend" ] && echo 0 > "$device/autosuspend" 2>/dev/null || true
        fi
    done
    
    # Disable runtime PM for all PCI devices
    for device in /sys/bus/pci/devices/*/power/control; do
        [ -f "$device" ] && echo on > "$device" 2>/dev/null || true
    done
    
    return 0
}

stop() {
    return 0
}

process $@