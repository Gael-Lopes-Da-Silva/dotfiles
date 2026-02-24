#!/usr/bin/env bash

if pgrep -f "alacritty.*--class monitor" >/dev/null; then
    exit 0
fi

alacritty --class monitor --command bash -c 'btop'

exit 0
