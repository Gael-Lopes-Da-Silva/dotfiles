#!/usr/bin/env bash

if ! compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
    exit 1
fi

battery=$(find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT[0-9]' | head -n1)
level=$(cat "$battery/capacity")

notify-send \
    -a "power" \
    -h string:x-dunst-stack-tag:battery \
    -u low \
    -t 5000 \
    "Battery" "$level%"

exit 0
