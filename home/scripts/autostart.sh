#!/usr/bin/env bash

setsid nohup bash -c "
    paplay '$HOME/.local/sounds/en-ligne.wav' &
" >/dev/null 2>&1 &

bash ~/.local/bin/soundboard_setup.sh &
