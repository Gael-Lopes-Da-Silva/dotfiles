#!/usr/bin/env bash

caps_led=$(find /sys/class/leds -maxdepth 1 -type l -name '*::capslock' | head -n1)
num_led=$(find /sys/class/leds -maxdepth 1 -type l -name '*::numlock' | head -n1)
scroll_led=$(find /sys/class/leds -maxdepth 1 -type l -name '*::scrolllock' | head -n1)

[ -z "$caps_led" ] && echo "No capslock LED found" && exit 1
[ -z "$num_led" ] && echo "No numlock LED found" && exit 1
[ -z "$scroll_led" ] && echo "No scrolllock LED found" && exit 1

prev_caps=$(cat "$caps_led/brightness")
prev_num=$(cat "$num_led/brightness")
prev_scroll=$(cat "$scroll_led/brightness")

while true; do
    caps=$(cat "$caps_led/brightness")
    num=$(cat "$num_led/brightness")
    scroll=$(cat "$scroll_led/brightness")

    if [ "$caps" != "$prev_caps" ]; then
        [ "$caps" = "1" ] && notify-send "Keyboard" "Caps Lock ON" || notify-send "Keyboard" "Caps Lock OFF"
        prev_caps="$caps"
    fi

    if [ "$num" != "$prev_num" ]; then
        [ "$num" = "1" ] && notify-send "Keyboard" "Num Lock ON" || notify-send "Keyboard" "Num Lock OFF"
        prev_num="$num"
    fi

    if [ "$scroll" != "$prev_scroll" ]; then
        [ "$scroll" = "1" ] && notify-send "Keyboard" "Scroll Lock ON" || notify-send "Keyboard" "Scroll Lock OFF"
        prev_scroll="$scroll"
    fi

    sleep 0.1
done
