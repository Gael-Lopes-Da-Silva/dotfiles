#!/bin/bash

echo "1 - packages"
echo "2 - desktop"
echo "3 - server"
echo "4 - drivers"
echo "5 - other"
echo ""
echo "9 - auto"

echo -n ": "
read INPUT

if [[ ! $INPUT =~ ^[0-9]+$ ]]; then
    echo "ERROR: select valid number"
    exit
fi

echo ""

case $INPUT in
    1)
        install_packages
        ;;

    2)
        install_desktop
        ;;

    3)
        install_server
        ;;

    4)
        echo "1 - intel"
        echo "2 - nvidia"

        echo -n ": "
        read INPUT

        if [[ ! $INPUT =~ ^[0-9]+$ ]]; then
            echo "ERROR: select valid number"
            exit
        fi

        echo ""

        case $INPUT in
            1)
                pacman -S --noconfirm mesa vulkan-intel
                modprobe i915 fastboot=1
                ;;

            2)
                pacman -S --noconfirm nvidia nvidia-settings lib32-nvidia-utils
                sed -i "s|MODULES=()|MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm asus_wmi)|" /etc/mkinitcpio.conf
                mkdir -p /etc/pacman.d/hooks/
                echo -e "[Trigger]\nOperation=Install\nOperation=Upgrade\nOperation=Remove\nType=Package\nTarget=nvidia\nTarget=linux\n[Action]\nDescription=Updating NVIDIA module in initcpio\nDepends=mkinitcpio\nWhen=PostTransaction\nNeedsTargets\nExec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'\n" >> /etc/pacman.d/hooks/nvidia.hook
                nvidia-xconfig
                echo -e "options nvidia_drm modeset=1 fbdev=1" >> /etc/modprobe.d/nvidia.conf
                mkinitcpio -P
                ;;
        esac
        ;;

    5)
        echo "1 - pacman"
        echo "2 - grub"
        echo "3 - steam"
        echo "4 - v4l2loopback"
        echo "5 - virtualization"

        echo -n ": "
        read INPUT

        if [[ ! $INPUT =~ ^[0-9]+$ ]]; then
            echo "ERROR: select valid number"
            exit
        fi

        echo ""

        case $INPUT in
            1)
                setup_pacman
                ;;

            2)
                setup_grub
                ;;

            3)
                pacman -S --noconfirm steam xdg-desktop-portal xdg-desktop-portal-gtk ttf-liberation
                ;;

            4)
                pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils linux-headers
                modprobe v4l2loopback
                ;;

            5)
                pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-host-modules-arch
                modprobe virtio
                modprobe vboxdrv
                modprobe vboxnetadp
                modprobe vboxnetflt
                usermod -aG vboxusers gael
                ;;
        esac
        ;;

    9)
        setup_pacman
        install_packages
        setup_grub
        install_desktop
        ;;
esac

install_packages () {
    pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code papirus-icon-theme unzip unrar p7zip stow neovim lazygit nushell feh kitty firefox chromium discord
    chsh -s /usr/bin/nu
    stow /home/gael/.dotfiles/home/
}

install_desktop () {
    pacman -S --noconfirm ly terminus-font xorg xorg-xinit xclip maim upower brightnessctl network-manager-applet
    systemctl enable ly.service
    sed -i "s|sleep_cmd = null|sleep_cmd = /sbin/systemctl suspend|" /etc/ly/config.ini
    setfont ter-132n
    echo -e "FONT=ter-132n" >> /etc/vconsole.conf
    cd /home/gael/.dotfiles/home/.config/dwm
    make clean install
    cd /home/gael/.dotfiles/home/.config/dwmblocks
    make clean install
    cd /home/gael/.dotfiles/home/.config/dmenu
    make clean install
    echo -e "#!/bin/bash\n\nnm-applet &\ndwmblocks &\n\nxsetroot -solid '#474747'\n\nexec dwm" > /home/gael/.xinitrc
    chmod +x /home/gael/.xinitrc
}

install_server () {
    pacman -S --noconfirm apache mariadb php php-apache
    sed -i "s|#LoadModule unique_id_module modules/mod_unique_id.so|LoadModule unique_id_module modules/mod_unique_id.so|" /etc/httpd/conf/httpd.conf
    sed -i "s|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|" /etc/httpd/conf/httpd.conf
    nvim /etc/httpd/conf/httpd.conf
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
    sed -i "s|display_errors = Off|display_errors = On|" /etc/php/php.ini
    sed -i "s|display_startup_errors = Off|display_startup_errors = On|" /etc/php/php.ini
    sed -i "s|;error_prepend_string = \"<span style='color: #ff0000'>\"|error_prepend_string = \"<span style='color: #ff0000'>\"|" /etc/php/php.ini
    sed -i "s|;error_append_string = \"</span>\"|error_append_string = \"</span>\"|" /etc/php/php.ini
    systemctl restart httpd.service
    systemctl restart mysql.service
}

setup_pacman () {
    sed -i "s|#Color|Color|" /etc/pacman.conf
    sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
    sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
}

setup_grub () {
    grub-mkfont -s 24 -o /boot/grub/fonts/cascadia_mono.pf2 /usr/share/fonts/TTF/CascadiaMono.ttf
    echo -e 'GRUB_FONT="/boot/grub/fonts/cascadia_mono.pf2"' >> /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
}
