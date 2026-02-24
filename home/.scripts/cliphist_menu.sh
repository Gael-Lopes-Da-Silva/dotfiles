#!/usr/bin/env bash

if pgrep -f "alacritty.*--class cliphist" >/dev/null; then
    exit 0
fi

alacritty --class cliphist --command bash -c '
    cliphist list | fzf --no-sort | cliphist decode | wl-copy
'

exit 0
