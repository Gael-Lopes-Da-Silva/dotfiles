#!/usr/bin/env bash

datetime=$(LC_TIME=fr_FR.UTF-8 date +"%A\n%d/%m/%Y\n%H:%M")

notify-send \
    -a "notification" \
    -h string:x-dunst-stack-tag:clock \
    -t 5000 \
    "Time" "$datetime"

exit 0
