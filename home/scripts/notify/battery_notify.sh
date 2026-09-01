#!/usr/bin/env bash

if ! compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
    exit 1
fi

battery=$(find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT[0-9]' | head -n1)
level=$(cat "$battery/capacity")

notify-send \
    -a "osd" \
    -h string:x-dunst-stack-tag:battery \
    -h "int:value:$level" \
    -t 3000 \
    "Battery" "$level%"

setsid nohup bash -c "
    paplay '$HOME/.local/sounds/prop_battery.wav' &
" >/dev/null 2>&1 &

exit 0
