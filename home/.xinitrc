#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

exec dwm
