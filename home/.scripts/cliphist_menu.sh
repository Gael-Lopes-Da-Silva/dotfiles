#!/usr/bin/env bash

if pgrep -f "alacritty.*--class cliphist" >/dev/null; then
    exit 0
fi

alacritty --class cliphist --command bash -c '
    selection=$(cliphist list | fzf --no-sort --prompt="Copy: ")
    [ -n "$selection" ] && echo "$selection" | cliphist decode | wl-copy
'

exit 0
