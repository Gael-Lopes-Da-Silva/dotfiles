#!/bin/sh

pacman -S --noconfirm apache

sed -i "s|#LoadModule unique_id_module modules/mod_unique_id.so|LoadModule unique_id_module modules/mod_unique_id.so|" /etc/httpd/conf/httpd.conf
sed -i "s|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|" /etc/httpd/conf/httpd.conf

nvim /etc/httpd/conf/httpd.conf

systemctl enable httpd.service
systemctl start httpd.service
