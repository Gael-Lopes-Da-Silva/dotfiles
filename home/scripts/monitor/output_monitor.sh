#!/usr/bin/env bash

if ! ls /sys/class/drm/ 1> /dev/null 2>&1; then
    exit 1
fi

declare -A last_status

for connector in /sys/class/drm/*-*; do
    [ -f "$connector/status" ] || continue

    name=$(basename "$connector")
    last_status[$name]=$(<"$connector/status")
done

udevadm monitor --environment --udev --subsystem-match=drm | while read -r line; do
    case "$line" in
        ACTION=change)
            device=""
            ;;
        DEVPATH=*)
            devpath=${line#*=}
            device=$(basename "$devpath")
            ;;
        HOTPLUG=1)
            if [ -n "$device" ]; then
                for connector in /sys/class/drm/"$device"-*; do
                    [ -f "$connector/status" ] || continue

                    status=$(<"$connector/status")
                    name=$(basename "$connector")

                    if [ "${last_status[$name]}" != "$status" ]; then
                        notify-send \
                            -a "monitor" \
                            -h string:x-dunst-stack-tag:output \
                            -t 3000 \
                            "Output" "$name: $status"

                        last_status[$name]=$status
                    fi
                done
            fi
            ;;
    esac
done
