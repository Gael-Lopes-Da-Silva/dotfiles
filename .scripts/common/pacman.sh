#!/bin/bash

sed -i "s|#Color|Color|" /etc/pacman.conf
sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
