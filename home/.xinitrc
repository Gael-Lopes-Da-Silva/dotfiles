eval $(nm-applet &)
eval $(dwmblocks &)
eval $(dunst &)
eval $(udiskie --automount --notify --tray)
eval $(gnome-keyring-daemon --start)
eval $(dbus-launch --sh-syntax --exit-with-session)

xsetroot -solid "#474747"

exec dwm
