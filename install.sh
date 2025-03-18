#!/bin/bash

USER="gael"

# Terminal
sudo pacman -S --noconfirm terminus-font
setfont ter-132n
echo -e "FONT=ter-132n" | sudo tee -a /etc/vconsole.conf

# Pacman
sudo sed -i "s|#Color|Color|" /etc/pacman.conf
sudo sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
sudo sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf

# Paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf ./paru/

# Packages
sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code ouch stow bash-completion firefox chromium pinta neovim ripgrep udiskie dunst feh xdg-desktop-portal xdg-desktop-portal-gtk ttf-liberation papirus-icon-theme linux-headers

# Stow
cd /home/$USER/.dotfiles/
stow home

# Desktop
sudo pacman -S --noconfirm xorg xorg-xinit xclip maim upower brightnessctl network-manager-applet
cd /home/$USER/.config/suckless/dwm
sudo make clean install
cd /home/$USER/.config/suckless/dwmblocks
sudo make clean install
cd /home/$USER/.config/suckless/dmenu
sudo make clean install

# Loopback
sudo pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils
sudo modprobe v4l2loopback

# Server
sudo pacman -S --noconfirm apache mariadb php php-apache php-gd
sudo sed -i "s|#LoadModule unique_id_module modules/mod_unique_id.so|LoadModule unique_id_module modules/mod_unique_id.so|" /etc/httpd/conf/httpd.conf
sudo sed -i "s|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|" /etc/httpd/conf/httpd.conf
sudo sed -i "s|AllowOverride None|AllowOverride All|" /etc/httpd/conf/httpd.conf
sudo systemctl enable httpd.service
sudo systemctl start httpd.service
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service
sudo mariadb-secure-installation
sudo sed -i "s|LoadModule mpm_event_module modules/mod_mpm_event.so|#LoadModule mpm_event_module modules/mod_mpm_event.so|" /etc/httpd/conf/httpd.conf
sudo sed -i "s|#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|" /etc/httpd/conf/httpd.conf
echo -e "LoadModule php_module modules/libphp.so\nAddHandler php-script .php\nInclude conf/extra/php_module.conf" | sudo tee -a /etc/httpd/conf/httpd.conf
sudo sed -i "s|;extension=mysqli|extension=mysqli|" /etc/php/php.ini
sudo sed -i "s|;extension=pdo_mysql|extension=pdo_mysql|" /etc/php/php.ini
sudo sed -i "s|;extension=exif|extension=exif|" /etc/php/php.ini
sudo sed -i "s|;extension=gd|extension=gd|" /etc/php/php.ini
sudo sed -i "s|;extension=bcmath|extension=bcmath|" /etc/php/php.ini
sudo sed -i "s|;extension=curl|extension=curl|" /etc/php/php.ini
sudo sed -i "s|display_errors = Off|display_errors = On|" /etc/php/php.ini
sudo sed -i "s|display_startup_errors = Off|display_startup_errors = On|" /etc/php/php.ini
sudo sed -i "s|;html_errors = On|html_errors = On|" /etc/php/php.ini
sudo sed -i "s|;error_prepend_string = \"<span style='color: #ff0000'>\"|error_prepend_string = \"<span style='color: #ff0000'>\"|" /etc/php/php.ini
sudo sed -i "s|;error_append_string = \"</span>\"|error_append_string = \"</span>\"|" /etc/php/php.ini
sudo systemctl restart httpd.service
sudo systemctl restart mysql.service

# Docker
sudo pacman -S --noconfirm docker
sudo usermod -aG docker $USER
sudo systemctl enable docker.service

# Virtualization
sudo pacman -S --noconfirm libvirt dnsmasq qemu-full virt-manager virt-viewer
sudo usermod -aG libvirt $USER
sudo systemctl enable libvirtd.service

# Android SDK
paru -S --noconfirm sdkmanager
sudo sdkmanager --install "tools"
sudo sdkmanager --install "platform-tools"
sudo sdkmanager --install "build-tools;34.0.0"
sudo sdkmanager --install "platforms;android-35"
sudo sdkmanager --licenses

# Soundboard
systemctl --user enable soundboard.service
systemctl --user start soundboard.service
