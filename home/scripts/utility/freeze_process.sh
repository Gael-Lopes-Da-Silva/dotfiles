#!/usr/bin/env bash

pid=$(niri msg focused-window | grep -i pid | awk '{print $2}' | tr -d '\n')

if [ -z "$pid" ] || [ "$pid" = "null" ]; then
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
