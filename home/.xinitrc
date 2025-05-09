#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

systemctl --user start graphical-session.target

exec dwm
