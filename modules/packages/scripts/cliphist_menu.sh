#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class cliphist" >/dev/null; then
    exit 0
fi

$TERMINAL --class cliphist -e bash -c '
    selection=$(cliphist list | fzf --no-sort --prompt="Copy: ")
    [ -n "$selection" ] && echo "$selection" | cliphist decode | wl-copy
'

exit 0
