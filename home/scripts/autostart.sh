#!/usr/bin/env bash

setsid nohup bash -c "
    paplay '$HOME/.local/sounds/prop_autostart.wav' &
" >/dev/null 2>&1 &

bash ~/.local/bin/soundboard_setup.sh &
