#!/usr/bin/env bash

datetime=$(LC_TIME=fr_FR.UTF-8 date +"%A\n%d/%m/%Y\n%H:%M")

dunstify \
    -a "clock" \
    -h string:x-dunst-stack-tag:clock \
    -u low \
    -t 3000 \
    "Time" "$datetime"

exit 0
