#!/usr/bin/env bash

if ! ls /sys/class/backlight/ 1> /dev/null 2>&1; then
    exit 1
fi

prev_percent=""
device=""

udevadm monitor --environment --udev --subsystem-match=backlight | while read -r line; do
    case "$line" in
        ACTION=change)
            is_change=1
            device=""
            ;;
        DEVPATH=*)
            if [ "$is_change" = "1" ]; then
                devpath=${line#*=}
                device=$(basename "$devpath")
            fi
            ;;
        "")
            if [ "$is_change" = "1" ] && [ -n "$device" ]; then
                brightness_file="/sys/class/backlight/$device/brightness"
                max_file="/sys/class/backlight/$device/max_brightness"

                if [ -f "$brightness_file" ] && [ -f "$max_file" ]; then
                    current=$(cat "$brightness_file")
                    max=$(cat "$max_file")
                    percent=$(( current * 100 / max ))

                    if [ -n "$prev_percent" ] && [ "$percent" -ne "$prev_percent" ]; then
                        dunstify \
                            -a "brightness" \
                            -h string:x-dunst-stack-tag:brightness \
                            -h int:value:"$percent" \
                            -u low \
                            -t 5000 \
                            "Brightness" "$percent%"
                    fi

                    prev_percent="$percent"
                fi

                is_change=0
            fi
            ;;
    esac
done
