#!/usr/bin/env bash

if [[ "$1" == "-s" ]]; then
    pid_file="/tmp/autoclick.pid"

    if [[ -f "$pid_file" ]]; then
        kill "$(cat "$pid_file")" 2>/dev/null
        rm -f "$pid_file"

        notify-send \
            -a "autoclick" \
            -t 5000 \
            "Autoclick" "Off"
    else
        (
            while true; do
                wlrctl pointer click left
            done
        ) &

        echo $! > "$pid_file"

        notify-send \
            -a "autoclick" \
            -t 5000 \
            "Autoclick" "On"
    fi
fi

if [[ "$1" == "-S" ]]; then
    pid_file="/tmp/autoclick_delayed.pid"

    if [[ -f "$pid_file" ]]; then
        kill "$(cat "$pid_file")" 2>/dev/null
        rm -f "$pid_file"

        notify-send \
            -a "autoclick" \
            -t 5000 \
            "Autoclick" "Off"
    else
        delay=$(
            yad --entry \
                --text="Select delay between clicks." \
                --entry-text="0.1" \
                --button="OK:0" \
                --button="Cancel:1"
        )
        [[ -z "$delay" ]] && exit 1

        if ! sleep "$delay" 2>/dev/null; then
            exit 1
        fi

        (
            while true; do
                wlrctl pointer click left
                sleep "$delay"
            done
        ) &

        echo $! > "$pid_file"

        notify-send \
            -a "autoclick" \
            -t 5000 \
            "Autoclick" "On"
    fi
fi

exit 0
