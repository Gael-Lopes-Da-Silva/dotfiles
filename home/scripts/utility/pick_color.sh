#!/usr/bin/env bash

color="$(
    niri msg --json pick-color \
        | jq -r '.rgb[]' \
        | awk '{printf "%02x", int($1*255 + 0.5)}'
)"

printf "#%s" "$color" | wl-copy

notify-send \
    -a "notification" \
    -t 5000 \
    "Color picked" "You can paste the hexadecimal color from the clipboard."

exit 0
