#!/bin/bash

B=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep percentage | awk '{print $2}' | sed "s|%||g"); [[ $? -ne 0 ]] || [[ $B == "" ]] && exit
S=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep state | awk '{print $2}'); [[ $? -ne 0 ]] || [[ $S == "" ]] && exit
I="󰁹"

{
    [[ $S == "charging" ]] && I="󱐋"

    if [[ $S == "charging" ]]; then
        [[ $B -ge 95 ]] && B="^c#00FF00^$B"
    fi

    if [[ $S == "discharging" ]]; then
        [[ $B -le 20 ]] && B="^c#FF8000^$B"
        [[ $B -le 10 ]] && B="^b#FF0000^$B"
    fi

    [[ $B -eq 100 ]] && I="" && B="^b#0000FF^$B"
}

B="$B%^d^"

echo " $I $B "

exit 0
