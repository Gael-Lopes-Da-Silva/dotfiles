#!/usr/bin/env bash

lock="${XDG_RUNTIME_DIR:-/tmp}/autostop.played"
if [[ -e $lock ]]; then
    exit 0
fi
: >"$lock"

sounds=("$HOME"/.local/sounds/sound_autostop_*.mp3)
sound="${sounds[RANDOM % ${#sounds[@]}]}"

paplay "$sound"
