#!/usr/bin/env bash

workspace=$(niri msg --json workspaces | jq -r '.[] | select(.is_active and .is_focused) | .idx')
if [[ -z "$workspace" || "$workspace" = "null" ]]; then
    exit 1
fi

notify-send \
    -a "workspace" \
    -h string:x-dunst-stack-tag:workspace \
    -t 3000 \
    "Workspace" "$workspace"

exit 0
