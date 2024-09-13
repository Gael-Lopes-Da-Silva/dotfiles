#!/bin/bash

B=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep percentage | awk '{print $2}' | sed "s|%||g"); [[ $? -ne 0 ]] || [[ $B == "" ]] && exit
S=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep state | awk '{print $2}'); [[ $? -ne 0 ]] || [[ $S == "" ]] && exit
I="󰁹"

{
    [[ $S == "charging" ]] && I="󱐋"

    if [[ $S == "charging" ]]; then
        [[ $B -ge 95 ]] && B="<span foreground='#00FF00'>$B</span>"
    fi

    if [[ $S == "discharging" ]]; then
        [[ $B -le 15 ]] && B="<span foreground='#FF8000'>$B</span>"
        [[ $B -le 5 ]] && B="<span foreground='#FF0000'>$B</span>"
    fi

    [[ $B -eq 100 ]] && I="" && B="<span foreground='#0000FF'>$B</span>"
}

B="$B%"

echo " $I $B "

exit 0
