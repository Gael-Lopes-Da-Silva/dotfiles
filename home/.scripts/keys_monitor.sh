#!/usr/bin/env bash

caps_led=$(find /sys/class/leds -maxdepth 1 -type l -name '*::capslock' | head -n1)
num_led=$(find /sys/class/leds -maxdepth 1 -type l -name '*::numlock' | head -n1)

[ -z "$caps_led" ] && echo "No capslock LED found" && exit 1
[ -z "$num_led" ] && echo "No numlock LED found" && exit 1

prev_caps=$(cat "$caps_led/brightness")
prev_num=$(cat "$num_led/brightness")

while true; do
    caps=$(cat "$caps_led/brightness")
    num=$(cat "$num_led/brightness")
    scroll=$(cat "$scroll_led/brightness")

    if [ "$caps" != "$prev_caps" ]; then
        if [ "$caps" = "1" ]; then
            dunstify \
                -a "capslock" \
                -h string:x-dunst-stack-tag:capslock \
                -u low \
                "Caps Lock" "On"
        else
            dunstify \
                -a "capslock" \
                -h string:x-dunst-stack-tag:capslock \
                -u low \
                "Caps Lock" "Off"
        fi
        prev_caps="$caps"
    fi

    if [ "$num" != "$prev_num" ]; then
        if [ "$num" = "1" ]; then
            dunstify \
                -a "numlock" \
                -h string:x-dunst-stack-tag:numlock \
                -u low \
                "Num Lock" "On"
        else
            dunstify \
                -a "numlock" \
                -h string:x-dunst-stack-tag:numlock \
                -u low \
                "Num Lock" "Off"
        fi
        prev_num="$num"
    fi

    sleep 0.1
done
