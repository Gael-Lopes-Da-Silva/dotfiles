#!/usr/bin/env bash

if ! compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
    exit 1
fi

battery=$(find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT[0-9]' | head -n1)
level=$(cat "$battery/capacity")

dunstify \
    -a "power" \
    -h string:x-dunst-stack-tag:battery \
    -h int:value:"$level" \
    -u low \
    -t 3000 \
    "Battery" "$level%"
