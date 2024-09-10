#!/bin/bash

pacman -S --noconfirm php php-apache

sed -i "s|LoadModule mpm_event_module modules/mod_mpm_event.so|#LoadModule mpm_event_module modules/mod_mpm_event.so|" /etc/httpd/conf/httpd.conf
sed -i "s|#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|" /etc/httpd/conf/httpd.conf

echo -e "LoadModule php_module modules/libphp.so\nAddHandler php-script .php\nInclude conf/extra/php_module.conf" >> /etc/httpd/conf/httpd.conf

systemctl restart httpd.service
