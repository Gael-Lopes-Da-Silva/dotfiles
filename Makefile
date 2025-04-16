.PHONY: all terminal pacman paru packages stow desktop drivers v4l2loopback docker virtmanager soundboard

USER := gael

all: terminal pacman paru packages stow desktop drivers v4l2loopback docker virtmanager soundboard

terminal:
	pacman -S --noconfirm terminus-font
	setfont ter-132n
	echo "FONT=ter-132n" | tee -a /etc/vconsole.conf

pacman:
	sed -i "s|#Color|Color|" /etc/pacman.conf
	sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
	sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
	sed -i "s|#HookDir|HookDir|" /etc/pacman.conf

paru:
	sudo -u $(USER) git clone https://aur.archlinux.org/paru.git /home/$(USER)/.dotfiles/paru
	cd /home/$(USER)/.dotfiles/paru && sudo -u $(USER) makepkg -si --noconfirm
	rm -rf /home/$(USER)/.dotfiles/paru

packages:
	pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk \
		ttf-cascadia-code ttf-liberation papirus-icon-theme bash-completion ouch stow chromium \
		neovim ripgrep udiskie dunst feh kitty

stow:
	cd /home/$(USER)/.dotfiles/ && \
		sudo -u $(USER) stow home --adopt && \
		sudo -u $(USER) git restore .

desktop:
	pacman -S --noconfirm xorg xorg-xinit xclip xdg-desktop-portal xdg-desktop-portal-gtk \
		maim upower brightnessctl network-manager-applet
	cd /home/$(USER)/.dotfiles/home/.config/suckless/dwm && make install clean
	cd /home/$(USER)/.dotfiles/home/.config/suckless/dwmblocks && make install clean
	cd /home/$(USER)/.dotfiles/home/.config/suckless/dmenu && make install clean

drivers:
	@if lspci | grep -i vga | grep -iq nvidia; then \
		pacman -S --noconfirm nvidia; \
		sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf; \
		mkinitcpio -P; \
		nvidia-xconfig; \
		mkdir -p /etc/pacman.d/hooks; \
		echo -e "[Trigger]\nOperation=Install\nOperation=Upgrade\nOperation=Remove\nType=Package\nTarget=nvidia\nTarget=nvidia-open\nTarget=nvidia-lts\nTarget=linux\n\n[Action]\nDescription=Updating NVIDIA module in initcpio\nDepends=mkinitcpio\nWhen=PostTransaction\nNeedsTargets\nExec=/bin/sh -c 'while read -r trg; do case $$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'" | tee -a /etc/pacman.d/hooks/nvidia.hook; \
	elif lspci | grep -i vga | grep -iq intel; then \
		pacman -S --noconfirm mesa vulkan-intel; \
	fi

v4l2loopback:
	pacman -S --noconfirm linux-headers v4l2loopback-dkms v4l2loopback-utils
	modprobe v4l2loopback

docker:
	pacman -S --noconfirm docker
	usermod -aG docker $(USER)
	systemctl enable docker.service

virtmanager:
	pacman -S --noconfirm libvirt dmidecode dnsmasq qemu-full virt-manager virt-viewer
	usermod -aG libvirt $(USER)
	systemctl enable libvirtd.service

soundboard:
	sudo -i -u $(USER) && systemctl --user enable soundboard.service
