#!/bin/bash

B=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep percentage | awk '{print $2}' | sed "s|%||g"); [[ $? -ne 0 ]] || [[ $B == "" ]] && exit
S=$(upower -i $(upower -e 2> /dev/null | grep /battery) 2> /dev/null | grep state | awk '{print $2}'); [[ $? -ne 0 ]] || [[ $S == "" ]] && exit
I="󰁹"

T=0
C=""

{
    [[ $S == "charging" ]] && I="󱐋"

    if [[ $S == "charging" ]]; then
        [[ $B -ge 95 ]] && C="#00FF00" && T=1
    fi

    if [[ $S == "discharging" ]]; then
        [[ $B -le 20 ]] && C="#FF8000" && T=1
        [[ $B -le 10 ]] && C="#FF0000" && T=2
    fi

    [[ $B -eq 100 ]] && I="" && C="#0000FF" && T=2
}

B="$B%"

if [[ $T -eq 0 ]]; then
    echo " $I $B "
elif [[ $T -eq 1 ]]; then
    echo " $I ^c$C^$B^d^ "
elif [[ $T -eq 2 ]]; then
    echo "^b$C^ $I $B ^d^"
fi

exit 0
