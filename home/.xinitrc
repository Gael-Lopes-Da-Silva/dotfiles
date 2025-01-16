nm-applet 2>&1 >/dev/null &
dwmblocks 2>&1 >/dev/null &
dunst 2>&1 >/dev/null &
udiskie --automount --notify --tray 2>&1 >/dev/null &
xsetroot -solid "#474747"
exec dwm