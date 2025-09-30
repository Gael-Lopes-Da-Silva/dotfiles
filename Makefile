all: system packages desktop drivers programming

USER := $(whoami)

system:
	sudo pacman -S --noconfirm linux-headers terminus-font
	echo "FONT=ter-132n" | tee -a /etc/vconsole.conf
	sudo sed -i "s|#Color|Color|" /etc/pacman.conf
	sudo sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
	sudo sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
	sudo sed -i "s|#HookDir|HookDir|" /etc/pacman.conf

packages:
	sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk nerd-fonts papirus-icon-theme bash-completion ouch stow firefox zed neovim ripgrep udiskie dunst feh kitty jq 7zip maim brightnessctl
	sudo ln -s /usr/bin/zeditor /usr/local/bin/zed

desktop:
	cd ${HOME}/.dotfiles/ && stow home --adopt && git restore .
	sudo pacman -S --noconfirm xorg xorg-xinit xclip xdg-desktop-portal xdg-desktop-portal-gtk
	cd ${HOME}/.dotfiles/home/.config/suckless/dwm && sudo make install clean
	cd ${HOME}/.dotfiles/home/.config/suckless/dwmblocks && sudo make install clean
	cd ${HOME}/.dotfiles/home/.config/suckless/dmenu && sudo make install clean
	cd ${HOME}/.dotfiles/home/.config/suckless/dsound && sudo make install clean

drivers:
	@if lspci | grep -i vga | grep -iq nvidia; then \
		sudo pacman -S --noconfirm nvidia-dkms dkms libvdpau-va-gl; \
		sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf; \
		sudo mkinitcpio -P; \
	elif lspci | grep -i vga | grep -iq intel; then \
		sudo pacman -S --noconfirm mesa vulkan-intel; \
	fi

programming:
	sudo pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils
	sudo modprobe v4l2loopback
	sudo pacman -S --noconfirm nodejs npm
	sudo npm -g install bun
	sudo pacman -S --noconfirm php php-gd composer
	sudo pacman -S --noconfirm docker docker-compose
	sudo usermod -aG docker ${USER}
	sudo systemctl enable docker.service

.PHONY: all system packages desktop drivers programming
