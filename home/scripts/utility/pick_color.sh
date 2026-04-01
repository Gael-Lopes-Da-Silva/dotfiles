#!/usr/bin/env bash


color="$(
    niri msg --json pick-color \
        | jq -r '.rgb[]' \
        | awk '{printf "%02x", int($1*255 + 0.5)}'
)"

printf "#%s" "$color" | wl-copy

exit 0
