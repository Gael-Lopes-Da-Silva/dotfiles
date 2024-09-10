#!/bin/bash

B=$(brightnessctl -m 2> /dev/null | grep backlight | awk '{split($1, a, ","); print a[4]}' | sed "s|%||g"); [[ $? -ne 0 ]] || [[ $B == "" ]] && exit
F="#FFFFFF"
I="󰃠"

{
    [[ $B -le 50 ]] && I="󰃞"
}

B="$B%"

echo " $I $B "
echo " $I $B "

echo $F

exit 0
