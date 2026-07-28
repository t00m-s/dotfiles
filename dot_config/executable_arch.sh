#!/usr/bin/env bash
set -euo pipefail
if ! [ $(id -u) = 0 ]; then
   echo "This script must NOT be run as root."
   exit 1
fi

# 1. System Localization & Hostname
echo "poldo" | sudo tee /etc/hostname
sudo ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
cat | sudo tee /etc/locale.conf <<EOF
en_US.UTF-8 UTF-8
it_IT.UTF-8 UTF-8
EOF
locale-gen
echo "KEYMAP=us-acentos" | sudo tee /etc/vconsole.conf
cat | sudo tee /etc/locale.conf<<EOF
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
# 2. Module Options
sudo mkdir -p /etc/modprobe.d
sudo mkdir -p /etc/modules-load.d/
echo "ec_sys" | sudo tee /etc/modules-load.d/ec_sys.conf
echo "options ec_sys write_support=1" | sudo tee /etc/modprobe.d/ec_sys.conf
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/nouveau.conf

# 3. Pacman
sudo pacman -S --needed --noconfirm \
  base base-devel linux linux-headers limine amd-ucode \
  nvidia-dkms nvidia-utils lib32-nvidia-utils nvtop vulkan-tools libva-utils btop rocm-smi-lib \
  hyprland xdg-desktop-portal-hyprland hyprpolkitagent greetd greetd-tuigreet gnome-keyring \
  seahorse fuzzel swaync qt5-wayland qt6-wayland grim slurp hyprpaper xdg-user-dirs \
  swappy wl-clipboard otf-font-awesome \
  pipewire pavucontrol pipewire-alsa pipewire-pulse pipewire-jack wireplumber rtkit \
  bluez bluez-utils blueman \
  docker docker-compose \
  upower uv openssh networkmanager wireguard-tools \
  steam gamemode gamescope \
  neovim tree-sitter tree-sitter-cli lua-language-server stylua ruff pyright clang rustup \
  eza lazygit lazydocker fzf ripgrep bat htop fish chezmoi vim wget git gcc \
  starship zoxide tmux git-delta fastfetch unzip cmake pkg-config \
  ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
  cups sane sane-airscan avahi nss-mdns \
  obsidian signal-desktop telegram-desktop nautilus gvfs udisks2 yazi 7zip ghostty \
  python-dbus python-click python-click-alias python-tomlkit spotify-launcher darkman scx-scheds scx-tools\

# 4. User Setup (Tommaso)
id -u tommaso &>/dev/null || useradd -m -s /usr/bin/fish tommaso
usermod -aG wheel,docker,video,audio,scanner,lp,gamemode tommaso

# 5. Font Configuration
cat | sudo tee /etc/fonts/local.conf<<EOF
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

# 6. Bluetooth Tweaks
cat | sudo tee /etc/bluetooth/main.conf<<EOF
[General]
ControllerMode = bredr
Experimental = true
FastConnectable = true
[Policy]
AutoEnable = true
EOF

# 7. Display Manager (Greetd + Tuigreet)
cat | sudo tee /etc/greetd/config.toml<<EOF
[default_session]
command = "tuigreet --time --remember --remember-session --sessions /usr/share/wayland-sessions"
user = "greeter"
[terminal]
vt = 1
EOF

# 8. Docker & Hardened SSH Setup
mkdir -p /etc/docker /etc/ssh/sshd_config.d
cat | sudo tee /etc/docker/daemon.json<<EOF
{
  "dns": ["1.1.1.1", "8.8.8.8"],
  "experimental": true,
  "default-address-pools": [{"base": "172.30.0.0/16", "size": 24}]
}
EOF

cat | sudo tee /etc/ssh/sshd_config.d/hardened.conf<<EOF
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
MaxAuthTries 3
EOF

# 9. Udev Rules (DS4 & GPU DRI Symlinks)
cat | sudo tee /etc/udev/rules.d/99-ds4-touchpad.rules<<EOF
ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
EOF

cat | sudo tee /etc/udev/rules.d/99-gpu-dri.rules<<EOF
KERNEL=="card*", KERNELS=="0000:06:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
EOF

# 10. HP Omen Fan Control Service
cat | sudo tee /etc/systemd/system/omen-fan.service<<EOF
[Unit]
Description=HP Omen Fan Control Daemon
After=multi-user.target

[Service]
Type=simple
WorkingDirectory=/home/tommaso/Projects/omen-fan
ExecStart=/usr/bin/uv run /home/tommaso/Projects/omen-fan/omen-fand.py
Restart=always
RestartSec=5s
User=root

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/omen-fan/
cat | sudo tee /etc/omen-fan/config.toml<<EOF
[service]
TEMP_CURVE = [51, 60, 70, 80, 90]
SPEED_CURVE = [0, 30, 40, 70, 100]
IDLE_SPEED = 0
POLL_INTERVAL = 1

[script]
BYPASS_DEVICE_CHECK = 1
EOF

# Lid handling laptop
cat | sudo tee /etc/systemd/logind.conf<<EOF
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF
# 11. AUR Packages Installation
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si

AUR_PKGS=(zen-browser-bin ttf-twemoji vesktop-bin epson-inkjet-printer-escpr epson-inkjet-printer-escpr2 bibata-cursor-theme-bin)
if command -v paru &> /dev/null; then
    paru -S --needed --noconfirm "${AUR_PKGS[@]}"
fi

# 12. Systemd Services Enablement
systemctl daemon-reload
systemctl enable scx NetworkManager bluetooth docker greetd upower sshd omen-fan cups auto-cpufreq nvidia-powerd avahi-daemon udisks2

# 13. QoL
git config --system core.pager "delta"
git config --system interactive.diffFilter "delta --color-only"
git config --system delta.navigate true
git config --system merge.conflictstyle zdiff3
