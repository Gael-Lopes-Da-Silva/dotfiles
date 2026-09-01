#!/usr/bin/env bash

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    pid=$(hyprctl activewindow -j | jq -r '.pid')
else
    pid=$(niri msg --json focused-window | jq -r '.pid')
fi

if [[ -z "$pid" || "$pid" = "null" ]]; then
    exit 1
fi

kill -9 "$pid"

notify-send \
    -a "notification" \
    -t 5000 \
    "Window killed" "PID: $pid"

setsid nohup bash -c "
    paplay '$HOME/.local/sounds/prop_kill.wav' &
" >/dev/null 2>&1 &

exit 0
