#!/bin/bash

FG_RESET="\033[0m"
FG_RED="\033[1;31m"
FG_GREEN="\033[1;32m"
FG_GREY="\033[1;37m"
FG_BLACK="\033[1;30m"

write_line () {
    echo -e "${FG_RED}$1${FG_RESET} - ${FG_GREY}$2${FG_RESET} ${FG_BLACK}$3${FG_RESET}"
}

write_prompt () {
    echo -en "${FG_GREEN}$1${FG_RESET} "
}

install_packages () {
    pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code papirus-icon-theme unzip unrar p7zip stow neovim lazygit nushell feh kitty firefox chromium discord
    chsh -s /usr/bin/nu gael
    stow $0/home/
}

install_desktop () {
    pacman -S --noconfirm lemurs terminus-font xorg xorg-xinit xclip maim upower brightnessctl network-manager-applet
    systemctl enable lemurs.service
    echo -e "#!/bin/sh\n\nnm-applet &\ndwmblocks &\n\nxsetroot -solid '#474747'\n\nexec dwm" >> /etc/lemurs/wms/dwm
    chmod +x /etc/lemurs/wms/dwm
    setfont ter-132n
    echo -e "FONT=ter-132n" >> /etc/vconsole.conf
    cd /home/gael/.dotfiles/home/.config/dwm
    make clean install
    cd /home/gael/.dotfiles/home/.config/dwmblocks
    make clean install
    cd /home/gael/.dotfiles/home/.config/dmenu
    make clean install
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

main () {
    write_line 1 "packages" "Install my packages and stow config into user home"
    write_line 2 "desktop"  "Install my desktop and greeter"
    write_line 3 "server"   "Install and setup a server with php and mariadb"
    write_line 4 "drivers"  "List drivers to install"
    write_line 5 "other"    "List other install options"
    echo ""
    write_line 8 "stow"     "Only stow config into user home"
    write_line 9 "auto"     "Automatic installation and setup"
    write_prompt ":"

    read INPUT

    [[ ${INPUT,,} == "quit" ]] || [[ ${INPUT,,} == "q" ]] && exit

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
            write_line 1 "intel" "Install intel graphics dsh rivers"
            write_line 2 "nvidia" "Install nvidia proprietary graphics drivers"
            write_prompt ":"

            read INPUT

            [[ ${INPUT,,} == "quit" ]] || [[ ${INPUT,,} == "q" ]] && exit

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
            write_line 1 "pacman" "Setup pacman to be more usable"
            write_line 2 "steam" "Install and setup steam"
            write_line 3 "v4l2loopback" "Install and setup v4l2loopback"
            write_line 4 "virtualization" "Install and setup virtualbox"
            write_prompt ":"

            read INPUT

            [[ ${INPUT,,} == "quit" ]] || [[ ${INPUT,,} == "q" ]] && exit

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
                    pacman -S --noconfirm steam xdg-desktop-portal xdg-desktop-portal-gtk ttf-liberation
                    ;;

                3)
                    pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils linux-headers
                    modprobe v4l2loopback
                    ;;

                4)
                    pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-host-modules-arch
                    modprobe virtio
                    modprobe vboxdrv
                    modprobe vboxnetadp
                    modprobe vboxnetflt
                    usermod -aG vboxusers gael
                    ;;
            esac
            ;;

        8)
            stow $0/home/
            ;;

        9)
            setup_pacman
            install_packages
            install_desktop
            ;;
    esac
}

main
