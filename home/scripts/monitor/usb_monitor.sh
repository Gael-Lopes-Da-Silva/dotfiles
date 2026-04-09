#!/usr/bin/env bash

udevadm monitor --environment --udev --subsystem-match=usb | while read -r line; do
    case "$line" in
        ACTION=add)
            action="add"
            device=""
            vendor=""
            model=""
            ;;
        ACTION=remove)
            action="remove"
            device=""
            vendor=""
            model=""
            ;;
        DEVTYPE=usb_device)
            is_device=1
            ;;
        DEVTYPE=*)
            is_device=0
            ;;
        ID_VENDOR=*)
            vendor=${line#*=}
            ;;
        ID_MODEL=*)
            model=${line#*=}
            ;;
        DEVNAME=*)
            device=${line#*=}
            ;;
        "")
            if [ "$is_device" = "1" ] && [ -n "$action" ]; then
                name="$vendor $model"

                if [ "$action" = "add" ]; then
                    notify-send \
                        -a "osd" \
                        -h string:x-dunst-stack-tag:usb \
                        -t 3000 \
                        "USB Connected" "$name"
                elif [ "$action" = "remove" ]; then
                    notify-send \
                        -a "osd" \
                        -h string:x-dunst-stack-tag:usb \
                        -t 3000 \
                        "USB Disconnected" "$name"
                fi
            fi

            action=""
            is_device=0
            ;;
    esac
done
