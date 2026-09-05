#!/usr/bin/env bash

pid=$(hyprctl activewindow -j | jq -r '.pid')
if [[ -z "$pid" || "$pid" = "null" ]]; then
    exit 1
fi

if ! kill -0 "$pid" 2>/dev/null; then
    exit 1
fi

state=$(ps -o state= -p "$pid" | tr -d ' ')
if [[ "$state" == T* ]]; then
    kill -CONT "$pid"
    notify-send \
        -a "notification" \
        -t 5000 \
        "Window unfrozen" "PID: $pid"

    sounds=("$HOME"/.local/sounds/sound_unfrozen_*.mp3)
    sound="${sounds[RANDOM % ${#sounds[@]}]}"

    setsid nohup bash -c "
        paplay '$sound' &
    " >/dev/null 2>&1 &
else
    kill -STOP "$pid"
    notify-send \
        -a "notification" \
        -t 5000 \
        "Window frozen" "PID: $pid"

    sounds=("$HOME"/.local/sounds/sound_frozen_*.mp3)
    sound="${sounds[RANDOM % ${#sounds[@]}]}"

    setsid nohup bash -c "
        paplay '$sound' &
    " >/dev/null 2>&1 &
fi

exit 0
