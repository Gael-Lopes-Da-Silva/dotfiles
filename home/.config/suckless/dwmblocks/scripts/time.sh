#!/bin/bash

T=$(date +"%T" 2> /dev/null); [[ $? -ne 0 ]] || [[ $T == "" ]] && exit
H=$(date +"%H" 2> /dev/null); [[ $? -ne 0 ]] || [[ $H == "" ]] && exit
I="󰥔"

{
    [ $H -eq 12 ] || [ $H -eq 19 ] && I="󰩰"
    [ $H -ge 00 ] && [ $H -le 07 ] && I="󰖔"
}

echo " $I $T "

exit 0
