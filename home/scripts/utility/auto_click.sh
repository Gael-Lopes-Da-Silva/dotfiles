#!/usr/bin/env bash

pid_file_fast="/tmp/autoclick.pid"
pid_file_slow="/tmp/autoclick_delayed.pid"

stop_autoclick() {
    if [[ -f "$pid_file_fast" ]]; then
        kill "$(cat "$pid_file_fast")" 2>/dev/null
        rm -f "$pid_file_fast"
    fi

    if [[ -f "$pid_file_slow" ]]; then
        kill "$(cat "$pid_file_slow")" 2>/dev/null
        rm -f "$pid_file_slow"
    fi
}

if [[ "$1" == "-s" ]]; then
    pid_file="/tmp/autoclick.pid"

    if [[ -f "$pid_file_fast" || -f "$pid_file_slow" ]]; then
        stop_autoclick

        notify-send \
            -a "osd" \
            -h string:x-dunst-stack-tag:autoclick \
            -t 3000 \
            "Autoclick" "Off"
    else
        (
            while true; do
                wlrctl pointer click left
            done
        ) &

        echo $! > "$pid_file"

        notify-send \
            -a "osd" \
            -h string:x-dunst-stack-tag:autoclick \
            -t 3000 \
            "Autoclick" "On"
    fi
fi

if [[ "$1" == "-S" ]]; then
    pid_file="/tmp/autoclick_delayed.pid"

    if [[ -f "$pid_file_slow" || -f "$pid_file_fast" ]]; then
        stop_autoclick

        notify-send \
            -a "osd" \
            -h string:x-dunst-stack-tag:autoclick \
            -t 3000 \
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

        if (( $(awk "BEGIN {print ($delay <= 0)}") )); then
            cps="∞"
        else
            cps=$(awk "BEGIN { printf \"%.2f\", 1 / $delay }")
        fi

        notify-send \
            -a "osd" \
            -h string:x-dunst-stack-tag:autoclick \
            -t 3000 \
            "Autoclick" "On (${cps} clicks/sec)"
    fi
fi

exit 0
