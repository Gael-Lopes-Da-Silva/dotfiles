#!/bin/bash

D=$(date +"%d/%m/%Y" 2> /dev/null); [[ $? -ne 0 ]] || [[ $D == "" ]] && exit
I=""

{
    B="19/06"
    T="11/09"
    H="20/04"

    [[ $(date +"%d/%m" 2> /dev/null) == $B ]] && I=""
    [[ $(date +"%d/%m" 2> /dev/null) == $T ]] && I=""
    [[ $(date +"%d/%m" 2> /dev/null) == $H ]] && I="󰴺"
}

echo " $I $D "

exit 0
