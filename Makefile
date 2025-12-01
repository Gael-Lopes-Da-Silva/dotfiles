all: system packages desktop drivers programming

USER := $(whoami)

system:
	sudo pacman -S --noconfirm terminus-font
	echo "FONT=ter-132n" | tee -a /etc/vconsole.conf
	sudo sed -i "s|#Color|Color|" /etc/pacman.conf
	sudo sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
	sudo sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
	sudo sed -i "s|#HookDir|HookDir|" /etc/pacman.conf

packages:
	sudo pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk nerd-fonts bash-completion ouch stow firefox zed neovim ripgrep feh kitty jq 7zip brightnessctl udiskie
	sudo ln -s /usr/bin/zeditor /usr/local/bin/zed

desktop:
	cd ${HOME}/.dotfiles/ && stow home --adopt && git restore .
	sudo pacman -S --noconfirm gtk3 gtk4 qt5-wayland qt6-wayland xdg-desktop-portal xdg-desktop-portal-hyprland
	sudo pacman -S --noconfirm hyprland niri xdg-desktop-portal xdg-desktop-portal-hyprland

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
	sudo pacman -S --noconfirm php composer
	sudo pacman -S --noconfirm docker docker-compose
	sudo usermod -aG docker ${USER}
	sudo systemctl enable docker.service

.PHONY: all system packages desktop drivers programming
