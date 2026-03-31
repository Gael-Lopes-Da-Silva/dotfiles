#!/usr/bin/env bash

set -euo pipefail

pid=$(niri msg focused-window | grep -i pid | awk '{print $2}' | tr -d '\n')

if [[ -z "$pid" ]]; then
    exit 1
fi

mapfile -t streams < <(wpctl status | awk '/Sink Inputs:/ {flag=1; next} /^$/ {flag=0} flag && /^[[:space:]]*[0-9]+/ {print $1}')

if [[ ${#streams[@]} -eq 0 ]]; then
    notify-send "No audio streams found."
    exit 0
fi

found=0
for id in "${streams[@]}"; do
    info=$(wpctl inspect "$id" 2>/dev/null || true)

    if echo "$info" | grep -q "application.process.id = \"$pid\""; then
        found=1

        if echo "$info" | grep -q "mute = true"; then
            notify-send \
                -a "mute" \
                -t 5000 \
                "Unmuting stream" "ID: $id"
            wpctl set-mute "$id" 0
        else
            notify-send \
                -a "mute" \
                -t 5000 \
                "Muting stream" "ID: $id"
            wpctl set-mute "$id" 1
        fi
    fi
done

if [[ "$found" -eq 0 ]]; then
    notify-send "No audio stream found for PID $pid"
fi
