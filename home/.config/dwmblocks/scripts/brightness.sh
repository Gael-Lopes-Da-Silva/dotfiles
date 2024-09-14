#!/bin/bash

B=$(brightnessctl -m 2> /dev/null | grep backlight | awk '{split($1, a, ","); print a[4]}' | sed "s|%||g"); [[ $? -ne 0 ]] || [[ $B == "" ]] && exit
I="󰃠"

{
    [[ $B -le 50 ]] && I="󰃞"
}

B="$B%"

echo " $I $B "

exit 0
