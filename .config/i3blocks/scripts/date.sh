#!/bin/bash

D=$(date +"%d/%m/%Y" 2> /dev/null); [[ $? -ne 0 ]] || [[ $D == "" ]] && exit
F="#FFFFFF"
I=""

{
    B="19/06"

    [[ $(date +"%d/%m" 2> /dev/null) == $D ]] && I=""
}

echo " $I $D "
echo " $I $D "

echo $F

exit 0
