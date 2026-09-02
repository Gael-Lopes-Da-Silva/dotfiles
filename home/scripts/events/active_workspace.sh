#!/usr/bin/env bash

workspace="$1"
if [[ -z "$workspace" ]]; then
    exit 1
fi

notify-send \
    -a "osd" \
    -h string:x-dunst-stack-tag:workspace \
    -t 3000 \
    "Workspace" "$workspace"

# setsid nohup bash -c "
#     paplay '$HOME/.local/sounds/prop_kill.wav' &
# " >/dev/null 2>&1 &

exit 0
