#!/bin/bash
# Max performance script for tuned

. /usr/lib/tuned/functions

start() {
    # Enable turbo boost
    [ -f /sys/devices/system/cpu/cpufreq/boost ] && echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
    
    # Force all USB devices fully active
    for device in /sys/bus/usb/devices/*/power; do
        if [ -d "$device" ]; then
            [ -f "$device/control" ] && echo on > "$device/control" 2>/dev/null || true
            [ -f "$device/autosuspend" ] && echo 0 > "$device/autosuspend" 2>/dev/null || true
        fi
    done
    
    # Force all PCI devices fully active
    for device in /sys/bus/pci/devices/*/power/control; do
        [ -f "$device" ] && echo on > "$device" 2>/dev/null || true
    done
    
    # Disable deep CPU idle states for lowest latency
    for state in /sys/devices/system/cpu/cpu*/cpuidle/state[3-9]/disable; do
        [ -f "$state" ] && echo 1 > "$state" 2>/dev/null || true
    done
    
    return 0
}

stop() {
    # Re-enable all CPU idle states
    for state in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
        [ -f "$state" ] && echo 0 > "$state" 2>/dev/null || true
    done
    
    return 0
}

process $@