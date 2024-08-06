#!/bin/bash

BRIGHTNESS=$(brightnessctl -m | grep -E -o '[0-9][0-9]?[0-9]?%')

if [[ $button -eq 4 ]]; then
    brightnessctl s +10% -q
fi

if [[ $button -eq 5 ]]; then
    brightnessctl s 10%- -q
fi

echo " $ICON $BRIGHTNESS "

exit 0
