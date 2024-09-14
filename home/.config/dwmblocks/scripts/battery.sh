#!/bin/bash

B=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep percentage | awk '{print $2}' | sed "s|%||g"); [[ $? -ne 0 ]] || [[ $B == "" ]] && exit
S=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep state | awk '{print $2}'); [[ $? -ne 0 ]] || [[ $S == "" ]] && exit
I="󰁹"
F=""
K=""

{
    [[ $S == "charging" ]] && I="󱐋"

    if [[ $S == "charging" ]]; then
        [[ $B -ge 95 ]] && F="#00FF00"
    fi

    if [[ $S == "discharging" ]]; then
        [[ $B -le 20 ]] && F="#FF8000"
        [[ $B -le 10 ]] && K="#FF0000"
    fi

    [[ $B -eq 100 ]] && I="" && K="#0000FF"
}

B="$B%"

if [[ $K != "" ]]; then
    echo "<span background='$K'> $I $B </span>"
elif [[ $F != "" ]]; then
    echo "<span foreground='$F'> $I $B </span>"
else
    echo " $I $B "
fi

exit 0
