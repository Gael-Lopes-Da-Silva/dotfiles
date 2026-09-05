#!/usr/bin/env bash

pid=$(hyprctl activewindow -j | jq -r '.pid')
if [[ -z "$pid" || "$pid" = "null" ]]; then
    exit 1
fi

kill -9 "$pid"

notify-send \
    -a "notification" \
    -t 5000 \
    "Window killed" "PID: $pid"

sounds=("$HOME"/.local/sounds/sound_kill_*.mp3)
sound="${sounds[RANDOM % ${#sounds[@]}]}"

setsid nohup bash -c "
    paplay '$sound' &
" >/dev/null 2>&1 &

exit 0
