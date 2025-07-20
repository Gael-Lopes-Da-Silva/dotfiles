all: system packages desktop drivers programming

system:
	sudo sed -i "s|#Color|Color|" /etc/pacman.conf
	sudo sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
	sudo sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
	sudo sed -i "s|#HookDir|HookDir|" /etc/pacman.conf
	sudo pacman -S --noconfirm linux-headers

packages:
	sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk nerd-fonts papirus-icon-theme bash-completion ouch stow chromium zed neovim ripgrep udiskie dunst feh kitty jq 7zip maim brightnessctl

desktop:
	cd $(HOME)/.dotfiles/ && stow home --adopt && git restore .
	sudo pacman -S --noconfirm xorg xorg-xinit xclip xdg-desktop-portal xdg-desktop-portal-gtk
	cd $(HOME)/.dotfiles/home/.config/suckless/dwm && sudo make install clean
	cd $(HOME)/.dotfiles/home/.config/suckless/dwmblocks && sudo make install clean
	cd $(HOME)/.dotfiles/home/.config/suckless/dmenu && sudo make install clean
	cd $(HOME)/.dotfiles/home/.config/suckless/dsound && sudo make install clean

drivers:
	@if lspci | grep -i vga | grep -iq nvidia; then \
		sudo pacman -S --noconfirm nvidia; \
		sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf; \
		sudo mkinitcpio -P; \
		sudo mkdir -p /etc/pacman.d/hooks; \
		echo -e "[Trigger]\nOperation=Install\nOperation=Upgrade\nOperation=Remove\nType=Package\nTarget=nvidia\nTarget=nvidia-open\nTarget=nvidia-lts\nTarget=linux\n\n[Action]\nDescription=Updating NVIDIA module in initcpio\nDepends=mkinitcpio\nWhen=PostTransaction\nNeedsTargets\nExec=/bin/sh -c 'while read -r trg; do case $$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'" | sudo tee -a /etc/pacman.d/hooks/nvidia.hook; \
	elif lspci | grep -i vga | grep -iq intel; then \
		sudo pacman -S --noconfirm mesa vulkan-intel; \
	fi

programming:
	pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils
	modprobe v4l2loopback
	pacman -S --noconfirm nodejs npm
	sudo npm -g install bun
	pacman -S --noconfirm php php-gd composer
	pacman -S --noconfirm docker docker-compose
	usermod -aG docker $(whoami)
	systemctl enable docker.service

.PHONY: all system packages desktop drivers programming
