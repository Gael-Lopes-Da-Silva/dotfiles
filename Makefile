all: packages stow desktop audio drivers programming editor

packages:
	sudo xbps-install -y linux-headers void-repo-nonfree
	sudo xbps-install -y noto-fonts-ttf noto-fonts-ttf-extra noto-fonts-ttf-variable noto-fonts-cjk noto-fonts-emoji nerd-fonts-ttf papirus-icon-theme bash-completion stow ouch chromium neovim ripgrep udiskie dunst feh kitty jq maim brightnessctl xtools v4l2loopback

stow:
	cd $(HOME)/.dotfiles/ && stow home --adopt &&  git restore .

desktop:
	sudo xbps-install -y xorg xinit xclip xclipboard xdg-desktop-portal xdg-desktop-portal-gtk
	cd $(HOME)/.dotfiles/home/.config/suckless/dwm && make install clean
	cd $(HOME)/.dotfiles/home/.config/suckless/dwmblocks && make install clean
	cd $(HOME)/.dotfiles/home/.config/suckless/dmenu && make install clean
	dconf write /org/gnome/desktop/interface/color-scheme 'prefer-dark'

audio:
	sudo xbps-install -y pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack
	sudo ln -s /etc/sv/pipewire /var/service
	sudo ln -s /etc/sv/wireplumber /var/service
	sudo sv up pipewire
	sudo sv up wireplumber

drivers:
	@if lspci | grep -i vga | grep -iq nvidia; then \
		xbps-install -y nvidia; \
		echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf; \
		mkdir -p /etc/dracut.conf.d; \
		echo 'add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "' > /etc/dracut.conf.d/nvidia.conf; \
		dracut --force; \
	elif lspci | grep -i vga | grep -iq intel; then \
		xbps-install -y mesa-vulkan-intel vulkan-loader; \
	fi

programming:
	sudo xbps-install -y nodejs
	sudo -E npm -g install bun

	sudo xbps-install -y rustup
	rustup default stable

	sudo xbps-install -y docker docker-compose
	sudo ln -s /etc/sv/docker /var/service
	sudo sv up docker
	usermod -aG docker $(shell logname)

editor:
	git clone https://github.com/zed-industries/zed.git /tmp/zed || true
	cd /tmp/zed && cargo build --release
	sudo rm -rf /tmp/zed

.PHONY: packages stow desktop audio drivers programming editor
