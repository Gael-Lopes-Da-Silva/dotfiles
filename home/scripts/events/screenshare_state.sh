#!/usr/bin/env bash

active="$1"
share_type="$2"
name="$3"

if [[ -z "$active" || -z "$share_type" ]]; then
    exit 1
fi

case "$share_type" in
    0) type_label="Monitor" ;;
    1) type_label="Window" ;;
    2) type_label="Region" ;;
    *) type_label="Screen" ;;
esac

body="$type_label"
if [[ -n "$name" ]]; then
    body="$type_label: $name"
fi

if [[ "$active" == "true" ]]; then
    notify-send \
        -a "notification" \
        -h string:x-dunst-stack-tag:screenshare \
        -t 5000 \
        "Screenshare Started" "$body"

    # setsid nohup bash -c "
    #     paplay '$HOME/.local/sounds/prop_kill.wav' &
    # " >/dev/null 2>&1 &
else
    notify-send \
        -a "notification" \
        -h string:x-dunst-stack-tag:screenshare \
        -t 5000 \
        "Screenshare Stopped" "$body"

    # setsid nohup bash -c "
    #     paplay '$HOME/.local/sounds/prop_kill.wav' &
    # " >/dev/null 2>&1 &
fi

exit 0
