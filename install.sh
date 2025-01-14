#!/bin/bash

USER="gael"

# Pacman
sed -i "s|#Color|Color|" /etc/pacman.conf
sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf

# Paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf ./paru/

# Packages
pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code unzip unrar 7zip stow nushell firefox chromium lazygit zed pinta zed neovim kitty dunst feh xdg-desktop-portal xdg-desktop-portal-gtk ttf-liberation
chsh -s /usr/bin/nu $USER

# Virtualization
pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-host-modules-arch
modprobe virtio
modprobe vboxdrv
modprobe vboxnetadp
modprobe vboxnetflt
usermod -aG vboxusers gael

# Loopback
pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils linux-headers
modprobe v4l2loopback

# Desktop
pacman -S --noconfirm lemurs terminus-font xorg xorg-xinit xclip maim upower brightnessctl network-manager-applet
systemctl enable lemurs.service
echo -e "#!/bin/sh\n\nnm-applet 2>&1 >/dev/null &&\ndwmblocks 2>&1 >/dev/null &\n\nxsetroot -solid \"#474747\"\n\nexec dwm" > /etc/lemurs/wms/dwm
chmod +x /etc/lemurs/wms/dwm
setfont ter-132n
echo -e "FONT=ter-132n" >> /etc/vconsole.conf
cd $(pwd)/home/.config/suckless/dwm
make clean install
cd $(pwd)/home/.config/suckless/dwmblocks
make clean install
cd $(pwd)/home/.config/suckless/dmenu
make clean install

# Server
pacman -S --noconfirm apache mariadb php php-apache
sed -i "s|#LoadModule unique_id_module modules/mod_unique_id.so|LoadModule unique_id_module modules/mod_unique_id.so|" /etc/httpd/conf/httpd.conf
sed -i "s|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|" /etc/httpd/conf/httpd.conf
sed -i "s|#\nAllowOverride None|#\nAllowOverride All|" /etc/httpd/conf/httpd.conf
systemctl enable httpd.service
systemctl start httpd.service
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl enable mariadb.service
systemctl start mariadb.service
mariadb-secure-installation
sed -i "s|LoadModule mpm_event_module modules/mod_mpm_event.so|#LoadModule mpm_event_module modules/mod_mpm_event.so|" /etc/httpd/conf/httpd.conf
sed -i "s|#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|" /etc/httpd/conf/httpd.conf
echo -e "LoadModule php_module modules/libphp.so\nAddHandler php-script .php\nInclude conf/extra/php_module.conf" >> /etc/httpd/conf/httpd.conf
sed -i "s|;extension=mysqli|extension=mysqli|" /etc/php/php.ini
sed -i "s|;extension=pdo_mysql|extension=pdo_mysql|" /etc/php/php.ini
sed -i "s|;extension=exif|extension=exif|" /etc/php/php.ini
sed -i "s|;extension=gd|extension=gd|" /etc/php/php.ini
sed -i "s|;extension=bcmath|extension=bcmath|" /etc/php/php.ini
sed -i "s|;extension=curl|extension=curl|" /etc/php/php.ini
sed -i "s|display_errors = Off|display_errors = On|" /etc/php/php.ini
sed -i "s|display_startup_errors = Off|display_startup_errors = On|" /etc/php/php.ini
sed -i "s|;error_prepend_string = \"<span style='color: #ff0000'>\"|error_prepend_string = \"<span style='color: #ff0000'>\"|" /etc/php/php.ini
sed -i "s|;error_append_string = \"</span>\"|error_append_string = \"</span>\"|" /etc/php/php.ini
systemctl restart httpd.service
systemctl restart mysql.service

# Android SDK
paru -S --noconfirm sdkmanager
sdkmanager --install "tools"
sdkmanager --install "platform-tools"
sdkmanager --install "build-tools;34.0.0"
sdkmanager --install "platforms;android-35"
sdkmanager --licenses

# Stow
cd /home/$USER/.dotfiles/
stow home