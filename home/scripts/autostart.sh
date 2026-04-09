#!/usr/bin/env bash

setsid nohup bash -c "
    paplay --device='SoundboardSink' --volume=65536 '$HOME/.local/sounds/windows-11-startup.mp3' &
" >/dev/null 2>&1 &

bash ~/.local/bin/soundboard_setup.sh &
bash ~/.local/bin/audio_monitor.sh &
bash ~/.local/bin/battery_monitor.sh &
bash ~/.local/bin/brightness_monitor.sh &
bash ~/.local/bin/output_monitor.sh &
bash ~/.local/bin/usb_monitor.sh &
