#!/usr/bin/env bash

WLRCTL="$(command -v wlrctl)" || { echo "error: wlrctl not found" >&2; exit 1; }

PID_FILE="/tmp/autoclick.pid"
if [[ -f "$PID_FILE" ]]; then
    kill "$(<"$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"

    notify-send \
        -a "osd" \
        -h string:x-dunst-stack-tag:autoclick \
        -t 3000 \
        "Autoclick" "Off"

    exit 0
fi

DELAY=0
if [[ "$1" == "-d" ]]; then
    DELAY=$(
        yad --entry \
            --text="Select delay between clicks." \
            --entry-text="0.1" \
            --button="OK:0" \
            --button="Cancel:1"
    )
    [[ -z "$DELAY" ]] && exit 1
fi

if [[ "$DELAY" == "0" ]]; then
    (
        while :; do
            "$WLRCTL" pointer click &
        done
    ) &
else
    (
        while :; do
            "$WLRCTL" pointer click
            sleep "$DELAY"
        done
    ) &
fi

echo "$!" > "$PID_FILE"

notify-send \
    -a "osd" \
    -h string:x-dunst-stack-tag:autoclick \
    -t 3000 \
    "Autoclick" "On"

exit 0
