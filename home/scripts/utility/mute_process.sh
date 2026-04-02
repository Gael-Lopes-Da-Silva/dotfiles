#!/usr/bin/env bash

if [[ "$1" == "-p" ]]; then
    pid=$(niri msg --json pick-window | jq -r '.pid')
else
    pid=$(niri msg --json focused-window | jq -r '.pid')
fi

if [[ -z "$pid" || "$pid" = "null" ]]; then
    exit 1
fi

mapfile -t streams < <(pw-dump | jq -r '
    .[]
    | select(.type == "PipeWire:Interface:Node")
    | select((.info.props."media.class" // "") | test("^Stream/.*/Audio$"))
    | .id
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
    fi
done

exit 0
