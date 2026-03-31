#!/usr/bin/env bash

workspace=$(niri msg workspaces | grep \* | cut -d' ' -f3)

notify-send \
    -a "workspace" \
    -h string:x-dunst-stack-tag:workspace \
    -t 3000 \
    "Workspace" "$workspace"

exit 0
