#!/bin/bash

sed -i "s|#Color|Color|" /etc/pacman.conf
sed -i "s|#ParallelDownload = 5|ParallelDownload = 5|" /etc/pacman.conf
sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
