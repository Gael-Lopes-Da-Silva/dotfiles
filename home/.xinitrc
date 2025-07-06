#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

systemctl --user start --no-block soundboard.service

exec dwm

exec dwm
