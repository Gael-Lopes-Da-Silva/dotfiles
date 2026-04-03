#!/usr/bin/env bash

if ! compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
    exit 1
fi

prev_online=""
prev_capacity=""
brightness_reduced=0

udevadm monitor --environment --udev --subsystem-match=power_supply | while read -r line; do
    case "$line" in
        ACTION=change)
            is_change=1
            device=""
            ;;
        POWER_SUPPLY_NAME=*)
            device=${line#*=}
            ;;
        POWER_SUPPLY_ONLINE=*)
            if [ "$is_change" = "1" ]; then
                current=${line#*=}

                if [ "$current" != "$prev_online" ]; then
                    if [ "$current" = "1" ]; then
                        notify-send \
                            -a "osd" \
                            -h string:x-dunst-stack-tag:power \
                            -t 3000 \
                            "Power" "Charger plugged in"

                        brightness_reduced=0
                    else
                        notify-send \
                            -a "osd" \
                            -h string:x-dunst-stack-tag:power \
                            -t 3000 \
                            "Power" "Charger unplugged"
                    fi
                    prev_online="$current"
                fi
            fi
            ;;
        POWER_SUPPLY_CAPACITY=*)
            if [ "$is_change" = "1" ] && [ "$device" = "BAT1" ]; then
                level=${line#*=}

                if [ "$level" != "$prev_capacity" ]; then
                    status=$(cat /sys/class/power_supply/BAT1/status)

                    if [ "$status" = "Discharging" ]; then
                        if [ "$level" -le 15 ] && [ "$brightness_reduced" = "0" ]; then
                            notify-send \
                                -a "osd" \
                                -h string:x-dunst-stack-tag:battery \
                                -h int:value:$level \
                                -u critical \
                                -t 10000 \
                                "Battery Critical" "$level% - Reducing brightness"

                            brightnessctl set 30%
                            brightness_reduced=1
                        elif [ "$level" -le 25 ] && [ "$prev_capacity" -gt 25 ]; then
                            notify-send \
                                -a "osd" \
                                -h string:x-dunst-stack-tag:battery \
                                -h int:value:$level \
                                -t 3000 \
                                "Battery Low" "$level%"
                        elif [ "$level" -le 50 ] && [ "$prev_capacity" -gt 50 ]; then
                            notify-send \
                                -a "osd" \
                                -h string:x-dunst-stack-tag:battery \
                                -h int:value:$level \
                                -t 3000 \
                                "Battery" "$level%"
                        fi
                    else
                        if [ "$level" -ge 100 ] && [ "$prev_capacity" -lt 100 ]; then
                            notify-send \
                                -a "osd" \
                                -h string:x-dunst-stack-tag:battery \
                                -t 3000 \
                                "Battery" "Fully charged"
                        fi
                    fi

                    prev_capacity="$level"
                fi
            fi
            ;;
    esac
done
