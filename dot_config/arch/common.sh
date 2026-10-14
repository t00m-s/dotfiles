#!/usr/bin/env bash
# Shared setup, sourced by arch.sh.

COMMON_PACKAGES=(
	base base-devel linux linux-headers limine amd-ucode
	nvtop vulkan-tools libva-utils btop rocm-smi-lib
	hyprland xdg-desktop-portal-hyprland hyprpolkitagent greetd greetd-tuigreet gnome-keyring hyprlock seahorse fuzzel swaync qt5-wayland qt6-wayland grim slurp hyprpaper xdg-user-dirs
	swappy wl-clipboard otf-font-awesome
	pipewire pavucontrol pipewire-alsa pipewire-pulse pipewire-jack wireplumber rtkit
	bluez bluez-utils blueman
	docker docker-compose
	upower uv openssh iwd wireguard-tools
	steam gamemode gamescope
	neovim tree-sitter tree-sitter-cli lua-language-server stylua ruff pyright clang rustup
	eza lazygit lazydocker fzf ripgrep bat htop fish chezmoi vim wget git gcc
	starship zoxide tmux git-delta fastfetch unzip cmake pkg-config
	ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
	cups sane sane-airscan avahi nss-mdns
	obsidian signal-desktop telegram-desktop nautilus gvfs udisks2 yazi 7zip ghostty
	zip python-dbus python-click python-click-aliases python-tomlkit spotify-launcher darkman scx-scheds scx-tools
)
COMMON_SERVICES=(scx iwd systemd-networkd systemd-resolved bluetooth docker greetd upower sshd cups avahi-daemon udisks2)
AUR_PACKAGES=(zen-browser-bin ttf-twemoji vesktop-bin epson-inkjet-printer-escpr epson-inkjet-printer-escpr2 bibata-cursor-theme-bin)

configure_system() {
	if [[ -n ${PROFILE_HOSTNAME:-} ]]; then
		echo "$PROFILE_HOSTNAME" | sudo tee /etc/hostname
	fi
	sudo ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
	# Enable locales in locale.gen, not locale.conf.
	sudo sed -i -E 's/^#[[:space:]]*(en_US.UTF-8 UTF-8|it_IT.UTF-8 UTF-8)/\1/' /etc/locale.gen
	sudo locale-gen
	echo "KEYMAP=us-acentos" | sudo tee /etc/vconsole.conf
	sudo tee /etc/locale.conf <<EOF
LANG=en_US.UTF-8
LC_ADDRESS=it_IT.UTF-8
LC_IDENTIFICATION=it_IT.UTF-8
LC_MEASUREMENT=it_IT.UTF-8
LC_MONETARY=it_IT.UTF-8
LC_NAME=it_IT.UTF-8
LC_NUMERIC=it_IT.UTF-8
LC_PAPER=it_IT.UTF-8
LC_TELEPHONE=it_IT.UTF-8
LC_TIME=it_IT.UTF-8
EOF
}

install_packages() {
	if ! pacman-conf --repo-list | grep -qx multilib; then
		sudo tee -a /etc/pacman.conf <<EOF

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
	fi
	# Refresh databases with a full upgrade to avoid a partial Arch upgrade.
	sudo pacman -Syu --needed --noconfirm "${COMMON_PACKAGES[@]}" "${PROFILE_PACKAGES[@]}"
}

configure_user() {
	id -u "$SETUP_USER" &>/dev/null || sudo useradd -m -s /usr/bin/fish "$SETUP_USER"
	sudo usermod -aG wheel,docker,video,audio,scanner,lp,gamemode "$SETUP_USER"
	SETUP_HOME=$(getent passwd "$SETUP_USER" | cut -d: -f6) # shuck: ignore=C001 # Used by laptop.sh.
}

configure_common() {
	configure_network
	sudo tee /etc/fonts/local.conf <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>FiraCode Nerd Font</family>
      <family>JetBrainsMono Nerd Font</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF
	fc-cache -fv
	sudo tee /etc/bluetooth/main.conf <<EOF
[General]
ControllerMode = bredr
Experimental = true
FastConnectable = true
[Policy]
AutoEnable = true
EOF
	sudo tee /etc/greetd/config.toml <<EOF
[default_session]
command = "tuigreet --time --remember --remember-session --sessions /usr/share/wayland-sessions"
user = "greeter"
[terminal]
vt = 1
EOF
	sudo mkdir -p /etc/docker /etc/ssh/sshd_config.d /etc/udev/rules.d
	sudo tee /etc/docker/daemon.json <<EOF
{
  "dns": ["1.1.1.1", "8.8.8.8"],
  "experimental": true,
  "default-address-pools": [{"base": "172.30.0.0/16", "size": 24}]
}
EOF
	sudo tee /etc/ssh/sshd_config.d/hardened.conf <<EOF
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
MaxAuthTries 3
EOF
	sudo tee /etc/udev/rules.d/99-ds4-touchpad.rules <<EOF
ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
EOF
	sudo git config --system core.pager "delta"
	sudo git config --system interactive.diffFilter "delta --color-only"
	sudo git config --system delta.navigate true
	sudo git config --system merge.conflictstyle zdiff3
}

configure_network() {
	sudo mkdir -p /etc/iwd /etc/systemd/network
	# iwd handles Wi-Fi authentication; networkd handles addresses and routes.
	sudo tee /etc/iwd/main.conf <<EOF
[General]
EnableNetworkConfiguration=false
PowerSaver=true
EOF
	sudo tee /etc/systemd/network/20-wired.network <<EOF
[Match]
Name=en* eth*

[Network]
DHCP=yes
IPv6AcceptRA=yes
EOF
	sudo tee /etc/systemd/network/25-wireless.network <<EOF
[Match]
Name=wl*

[Network]
DHCP=yes
IPv6AcceptRA=yes
IgnoreCarrierLoss=yes
EOF
	sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
}

install_aur_packages() {
	if ! command -v paru &>/dev/null; then
		(
			build_dir=$(mktemp -d)
			trap 'rm -rf -- "$build_dir"' EXIT
			git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
			cd "$build_dir/paru" || exit 1
			makepkg -si
		)
	fi
	paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
}

enable_services() {
	sudo systemctl daemon-reload
	sudo systemctl enable "${COMMON_SERVICES[@]}" "${PROFILE_SERVICES[@]}"
}
