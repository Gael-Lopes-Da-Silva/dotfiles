#!/bin/bash

pacman -S --noconfirm php php-apache

sed -i "s|LoadModule mpm_event_module modules/mod_mpm_event.so|#LoadModule mpm_event_module modules/mod_mpm_event.so|" /etc/httpd/conf/httpd.conf
sed -i "s|#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|" /etc/httpd/conf/httpd.conf

echo -e "LoadModule php_module modules/libphp.so\nAddHandler php-script .php\nInclude conf/extra/php_module.conf" >> /etc/httpd/conf/httpd.conf

sed -i "s|;extension=mysqli|extension=mysqli|" /etc/php/php.ini
sed -i "s|;extension=pdo_mysql|extension=pdo_mysql|" /etc/php/php.ini

sed -i "s|display_errors = Off|display_errors = On|" /etc/php/php.ini
sed -i "s|display_startup_errors = Off|display_startup_errors = On|" /etc/php/php.ini
sed -i "s|;error_prepend_string = \"<span style='color: #ff0000'>\"|error_prepend_string = \"<span style='color: #ff0000'>\"|" /etc/php/php.ini
sed -i "s|;error_append_string = \"</span>\"|error_append_string = \"</span>\"|" /etc/php/php.ini

systemctl restart httpd.service
systemctl restart mysql.service
