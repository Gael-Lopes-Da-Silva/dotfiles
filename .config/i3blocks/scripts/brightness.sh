#!/bin/bash

BRIGHTNESS=$(brightnessctl -m | grep -E -o '[0-9][0-9]?[0-9]?%')

echo " $ICON $BRIGHTNESS "

exit 0
