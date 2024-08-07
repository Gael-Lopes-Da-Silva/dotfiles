#!/bin/bash

BRIGHTNESS=$(brightnessctl -m | grep -E -o '[0-9][0-9]?[0-9]?%')

[[ $button -eq 4 ]] && brightnessctl s +10% -q
[[ $button -eq 5 ]] && brightnessctl s 10%- -q

echo " $ICON $BRIGHTNESS "
echo " $ICON $BRIGHTNESS "

exit 0
