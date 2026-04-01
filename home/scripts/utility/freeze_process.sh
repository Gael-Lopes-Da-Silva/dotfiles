#!/usr/bin/env bash

pid=$(niri msg focused-window 2>/dev/null | awk '/PID/ {print $2}')
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
        -a "freeze" \
        -t 5000 \
        "Window unfrozen" "PID: $pid"
else
    kill -STOP "$pid"
    notify-send \
        -a "freeze" \
        -t 5000 \
        "Window frozen" "PID: $pid"
fi

exit 0
