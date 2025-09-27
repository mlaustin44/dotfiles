#!/bin/bash
# Battery normal script for tuned

. /usr/lib/tuned/functions

start() {
    # Disable turbo boost to save battery
    [ -f /sys/devices/system/cpu/cpufreq/boost ] && echo 0 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true
    
    # USB autosuspend - enable with 5 second delay
    for device in /sys/bus/usb/devices/*/power; do
        if [ -d "$device" ]; then
            [ -f "$device/control" ] && echo auto > "$device/control" 2>/dev/null || true
            [ -f "$device/autosuspend" ] && echo 1 > "$device/autosuspend" 2>/dev/null || true
            [ -f "$device/autosuspend_delay_ms" ] && echo 5000 > "$device/autosuspend_delay_ms" 2>/dev/null || true
        fi
    done
    
    # Runtime PM for non-critical PCI devices (avoid GPU/NVMe)
    for device in /sys/bus/pci/devices/*/power/control; do
        if [ -f "$device" ]; then
            device_class=$(cat "$(dirname "$device")/class" 2>/dev/null || echo "")
            # Skip GPU (0x03xxxx) and NVMe (0x01xxxx)
            if [[ ! "$device_class" =~ ^0x03 ]] && [[ ! "$device_class" =~ ^0x01 ]]; then
                echo auto > "$device" 2>/dev/null || true
            fi
        fi
    done
    
    return 0
}

stop() {
    return 0
}

process $@