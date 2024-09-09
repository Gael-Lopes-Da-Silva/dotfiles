#!/bin/sh

pacman -S --noconfirm mariadb

mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

systemctl enable mariadb.service
systemctl start mariadb.service

mariadb-secure-installation
