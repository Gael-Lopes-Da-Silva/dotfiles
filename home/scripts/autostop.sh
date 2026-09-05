#!/usr/bin/env bash

sounds=("$HOME"/.local/sounds/sound_autostop_*.mp3)
sound="${sounds[RANDOM % ${#sounds[@]}]}"

setsid nohup bash -c "
    paplay '$sound' &
" >/dev/null 2>&1 &
