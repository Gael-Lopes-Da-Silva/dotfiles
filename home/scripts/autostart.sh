#!/usr/bin/env bash

setsid nohup bash -c "
    paplay '$HOME/.local/sounds/windows-11-startup.mp3' &
" >/dev/null 2>&1 &

bash ~/.local/bin/soundboard_setup.sh &
