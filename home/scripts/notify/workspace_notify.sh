#!/usr/bin/env bash

workspace=$(niri msg workspaces | awk '/\*/ {print $2; exit}')

notify-send \
    -a "workspace" \
    -h string:x-dunst-stack-tag:workspace \
    -t 3000 \
    "Workspace" "$workspace"

exit 0
