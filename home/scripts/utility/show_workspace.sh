#!/usr/bin/env bash

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    workspace=$(hyprctl activeworkspace -j | jq -r '.id')
else
    workspace=$(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | .idx')
fi

if [[ -z "$workspace" || "$workspace" = "null" ]]; then
    exit 1
fi

notify-send \
    -a "osd" \
    -h string:x-dunst-stack-tag:workspace \
    -t 5000 \
    "Workspace" "$workspace"

# setsid nohup bash -c "
#     paplay '$HOME/.local/sounds/prop_kill.wav' &
# " >/dev/null 2>&1 &

exit 0
