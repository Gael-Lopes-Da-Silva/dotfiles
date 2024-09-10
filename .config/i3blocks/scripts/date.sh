#!/bin/bash

D=$(date +"%d/%m/%Y" 2> /dev/null); [[ $? -ne 0 ]] || [[ $D == "" ]] && exit
T=$(date +"%d/%m" 2> /dev/null); [[ $? -ne 0 ]] || [[ $T == "" ]] && exit
F="#FFFFFF"
I=""

{
    B="19/06"

    [[ $T == $D ]] && I=""
}

echo " $I $D "
echo " $I $D "

echo $F

exit 0
