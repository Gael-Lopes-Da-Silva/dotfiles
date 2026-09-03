#!/usr/bin/env bash

workspace=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .idx')
if [[ -z "$workspace" || "$workspace" = "null" ]]; then
    exit 1
fi

notify-send \
    -a "osd" \
    -h string:x-dunst-stack-tag:workspace \
    -t 3000 \
    "Workspace" "$workspace"

setsid nohup bash -c "
    paplay '$HOME/.local/sounds/prop_workspace.wav' &
" >/dev/null 2>&1 &

exit 0
