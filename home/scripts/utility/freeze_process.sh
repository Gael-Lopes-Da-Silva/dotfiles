#!/usr/bin/env bash

pid=$(niri msg focused-window | grep -i pid | awk '{print $2}' | tr -d '\\n')

if [ -z "$pid" ] || [ "$pid" = "null" ]; then
    exit 1
fi

if kill -0 "$pid" 2>/dev/null; then
    if kill -0 -"$pid" 2>/dev/null; then
        kill -CONT "$pid"
        notify-send "Window unfrozen" "PID: $pid"
    else
        kill -STOP "$pid"
        notify-send "Window frozen" "PID: $pid"
    fi
fi
