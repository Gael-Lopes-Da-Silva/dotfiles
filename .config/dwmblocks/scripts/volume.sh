#!/bin/bash

V=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2> /dev/null | awk '{print $2}'); [[ $? -ne 0 ]] || [[ $V == "" ]] && exit
M=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2> /dev/null | awk '{print length($3) != 0}'); [[ $? -ne 0 ]] || [[ $M == "" ]] && exit
F="#FFFFFF"
I="󰕾"

{
    [[ $V == "0.00" ]] && I="󰖁"

    [[ $M -eq 1 ]] && V="MUTED" && F="#b9b9b9" && I="󰖁"
}

echo " $I $V "
echo " $I $V "

echo $F

exit 0
