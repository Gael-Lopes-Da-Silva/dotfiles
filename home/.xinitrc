#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

udiskie -a -n -s &
dsound_setup &
dwmblocks &
dunst &

exec dwm
