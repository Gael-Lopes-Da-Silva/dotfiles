#!/bin/sh

sed -i "s|#Color|Color|" /etc/pacman.conf
sed -i "s|#ParalleDownload = 5|ParalleDownload = 5|" /etc/pacman.conf
sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
