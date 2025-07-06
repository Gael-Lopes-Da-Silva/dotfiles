#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

systemctl --user start --no-block soundboard.service

exec dwm

while true; do
  dwm >/dev/null 2>&1
done
