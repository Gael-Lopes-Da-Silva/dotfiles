#!/usr/bin/env bash

if [[ "$1" == "-p" ]]; then
    window_json=$(niri msg --json pick-window)
else
    window_json=$(niri msg --json focused-window)
fi

app_id=$(jq -r '.app_id' <<< "$window_json")
pid=$(jq -r '.pid' <<< "$window_json")

if [[ -z "$app_id" || "$app_id" = "null" ]]; then
    exit 1
fi

is_child_of() {
    local child=$1
    local parent=$2

    while [[ "$child" -ne 1 ]]; do
        [[ "$child" -eq "$parent" ]] && return 0
        child=$(ps -o ppid= -p "$child" 2>/dev/null | tr -d ' ')
        [[ -z "$child" ]] && break
    done
    return 1
}

mapfile -t streams < <(pw-dump | jq -r '
    .[]
    | select(.type == "PipeWire:Interface:Node")
    | select((.info.props."media.class" // "") | test("^Stream/.*/Audio$"))
    | .id
')

[[ ${#streams[@]} -eq 0 ]] && exit 1

for id in "${streams[@]}"; do
    inspect=$(wpctl inspect "$id" 2>/dev/null) || continue

    stream_pid=$(grep -oP 'application.process.id = "\K[0-9]+' <<< "$inspect")
    stream_bin=$(grep -oP 'application.process.binary = "\K[^"]+' <<< "$inspect")

    match=false

    if [[ "$stream_pid" == "$pid" ]]; then
        match=true
    fi

    if [[ "$stream_bin" == "$app_id" ]]; then
        match=true
    fi

    if [[ -n "$stream_pid" && -n "$pid" ]] && is_child_of "$stream_pid" "$pid"; then
        match=true
    fi

    if $match; then
        if wpctl get-volume "$id" 2>/dev/null | grep -qi MUTED; then
            notify-send \
                -a "notification" \
                -h string:x-dunst-stack-tag:mute-unmuted \
                -t 2000 \
                "Window unmuted" "$app_id"
        else
            notify-send \
                -a "notification" \
                -h string:x-dunst-stack-tag:mute-muted \
                -t 2000 \
                "Window muted" "$app_id"
        fi

        wpctl set-mute "$id" toggle
    fi
done

exit 0
