#!/usr/bin/env bash

set -euo pipefail

pid=$(niri msg focused-window | awk '/PID/ {print $2}')
if [ -z "$pid" ] || [ "$pid" = "null" ]; then
    exit 1
fi

mapfile -t streams < <(wpctl status | awk '
    /Audio/ {in_audio=1}
    in_audio && /Streams:/ {in_streams=1; next}
    in_audio && in_streams && /^[[:space:]]*[0-9]+\./ {
        if ($2 !~ /^output_/) {
            gsub("\\.", "", $1)
            print $1
        }
    }
    /^[^[:space:]]/ && !/Audio/ {in_audio=0; in_streams=0}
')
if [[ ${#streams[@]} -eq 0 ]]; then
    exit 1
fi

for id in "${streams[@]}"; do
    if wpctl inspect "$id" 2>/dev/null | grep -q "application.process.id = \"$pid\""; then
        if wpctl get-volume "$id" 2>/dev/null | grep -qi MUTED; then
            notify-send \
                -a "mute" \
                -t 5000 \
                "Window unmuted" "PID: $pid"
        else
            notify-send \
                -a "mute" \
                -t 5000 \
                "Window muted" "PID: $pid"
        fi

        wpctl set-mute "$id" toggle
        break
    fi
done

exit 0
