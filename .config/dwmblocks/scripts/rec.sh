#!/bin/bash

R=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2> /dev/null | awk '{print $2}'); [[ $? -ne 0 ]] || [[ $R == "" ]] && exit
M=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2> /dev/null | awk '{print length($3) != 0}'); [[ $? -ne 0 ]] || [[ $M == "" ]] && exit
F="#FFFFFF"
I=""

{
    [[ $R == "0.00" ]] && I="󰖁"

    [[ $M -eq 1 ]] && R="MUTED" && F="#b9b9b9" && I="󰖁"
}

echo " $I $R "
echo " $I $R "

echo $F

exit 0
