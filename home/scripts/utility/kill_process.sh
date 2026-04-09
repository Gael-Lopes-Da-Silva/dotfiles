#!/usr/bin/env bash

pid=$(niri msg --json focused-window | jq -r '.pid')
if [[ -z "$pid" || "$pid" = "null" ]]; then
    exit 1
fi

kill -9 $pid

notify-send \
    -a "notification" \
    -t 5000 \
    "Window killed" "PID: $pid"

exit 0
