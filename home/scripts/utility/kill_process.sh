#!/usr/bin/env bash

if [[ "$1" == "-p" ]]; then
    pid=$(niri msg --json pick-window | jq -r '.pid')
else
    pid=$(niri msg --json focused-window | jq -r '.pid')
fi

if [[ -z "$pid" || "$pid" = "null" ]]; then
    exit 1
fi

kill -9 $pid

exit 0
