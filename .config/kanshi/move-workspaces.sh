#!/bin/bash
# Move workspaces 1-5 to the active monitor when docking/undocking

sleep 1  # Give Hyprland time to process monitor change

# Move workspaces 1-5 to the first active monitor
for i in {1..5}; do
    hyprctl dispatch moveworkspacetomonitor "$i" +0
done