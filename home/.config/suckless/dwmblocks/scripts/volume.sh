#!/bin/bash

V=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2> /dev/null | awk '{print $2}'); [[ $? -ne 0 ]] || [[ $V == "" ]] && exit
M=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2> /dev/null | awk '{print length($3) != 0}'); [[ $? -ne 0 ]] || [[ $M == "" ]] && exit
I="󰕾"

{
    [[ $V == "0.00" ]] && I="󰖁"

    [[ $M -eq 1 ]] && V="^c#474747^MUTED^d^" && I="󰖁"
}

echo " $I $V "

exit 0
