#!/usr/bin/env bash

workspace=$(niri msg workspaces 2>/dev/null | awk '/\*/ {print $2; exit}')
if [[ -z "$workspace" || "$workspace" = "null" ]]; then
    exit 1
fi

notify-send \
    -a "workspace" \
    -h string:x-dunst-stack-tag:workspace \
    -t 3000 \
    "Workspace" "$workspace"

exit 0
