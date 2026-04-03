#!/usr/bin/env bash

if [[ "$1" == "-p" ]]; then
    pid=$(niri msg --json pick-window | jq -r '.pid')
else
    pid=$(niri msg --json focused-window | jq -r '.pid')
fi

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
else
    kill -STOP "$pid"
    notify-send \
        -a "notification" \
        -t 5000 \
        "Window frozen" "PID: $pid"
fi

exit 0
