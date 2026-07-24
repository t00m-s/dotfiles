#!/usr/bin/env bash
set -euo pipefail

# 1. System Localization & Hostname
echo "poldo" > /etc/hostname
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us-acentos" > /etc/vconsole.conf

# 2. Hardware & Kernel Module Options
mkdir -p /etc/modprobe.d
echo "options ec_sys write_support=1" > /etc/modprobe.d/ec_sys.conf
echo "blacklist nouveau" > /etc/modprobe.d/nouveau.conf

# 3. User Setup (Tommaso)
id -u tommaso &>/dev/null || useradd -m -s /usr/bin/fish tommaso
usermod -aG wheel,networkmanager,docker,video,audio,scanner,lp,gamemode tommaso

# 4. Pacman Core Package Installation
pacman -S --needed --noconfirm \
  linux linux-headers limine amd-ucode \
  nvidia-dkms nvidia-utils lib32-nvidia-utils nvtop vulkan-tools libva-utils btop \
  hyprland greetd greetd-tuigreet gnome-keyring seahorse \
  pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber rtkit \
  bluez bluez-utils blueman \
  docker docker-compose \
  auto-cpufreq upower uv openssh networkmanager wireguard-tools \
  steam gamemode gamescope protonup-ng prismlauncher wine-staging winetricks \
  neovim tree-sitter lua-language-server stylua ruff pyright clang rustup \
  eza lazygit lazydocker fzf ripgrep bat htop fish chezmoi vim wget git gcc \
  starship zoxide tmux git-delta fastfetch unzip cmake pkg-config \
  ttf-firacode-nerd ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
  cups sane sane-airscan avahi nss-mdns \
  obsidian signal-desktop telegram-desktop nautilus gvfs udisks2 yazi 7zip \
  python-dbus spotify-launcher darkman scx-scheds

# 5. Font Configuration
cat << 'EOF' > /etc/fonts/local.conf
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
cat << 'EOF' > /etc/bluetooth/main.conf
[General]
ControllerMode = bredr
Experimental = true
FastConnectable = true
[Policy]
AutoEnable = true
EOF

# 7. Display Manager (Greetd + Tuigreet)
cat << 'EOF' > /etc/greetd/config.toml
[default_session]
command = "tuigreet --time --remember --remember-session --sessions /usr/share/wayland-sessions"
user = "greeter"
EOF

# 8. Docker & Hardened SSH Setup
mkdir -p /etc/docker /etc/ssh/sshd_config.d
cat << 'EOF' > /etc/docker/daemon.json
{
  "dns": ["1.1.1.1", "8.8.8.8"],
  "experimental": true,
  "default-address-pools": [{"base": "172.30.0.0/16", "size": 24}]
}
EOF

cat << 'EOF' > /etc/ssh/sshd_config.d/hardened.conf
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
MaxAuthTries 3
EOF

# 9. Udev Rules (DS4 & GPU DRI Symlinks)
cat << 'EOF' > /etc/udev/rules.d/99-ds4-touchpad.rules
ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
EOF

cat << 'EOF' > /etc/udev/rules.d/99-gpu-dri.rules
KERNEL=="card*", KERNELS=="0000:06:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
EOF

# 10. HP Omen Fan Control Service
cat << 'EOF' > /etc/systemd/system/omen-fan.service
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

cat << 'EOF' > /etc/omen-fan/config.toml
[service]
TEMP_CURVE = [51, 60, 70, 80, 90]
SPEED_CURVE = [0, 30, 40, 70, 100]
IDLE_SPEED = 0
POLL_INTERVAL = 1

[script]
BYPASS_DEVICE_CHECK = 1
EOF
# 11. Systemd Services Enablement
systemctl daemon-reload
systemctl enable NetworkManager bluetooth docker greetd auto-cpufreq upower sshd omen-fan cups avahi-daemon udisks2

# 12. AUR Packages Installation
pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si

AUR_PKGS=(zen-browser-bin ttf-twemoji vesktop-bin epson-inkjet-printer-escpr epson-inkjet-printer-escpr2)
if command -v paru &> /dev/null; then
    paru -S --needed --noconfirm "${AUR_PKGS[@]}"
fi

systemctl enable --now scx || true

# 13. QoL
git config --system core.pager "delta"
git config --system interactive.diffFilter "delta --color-only"
git config --system delta.navigate true
git config --system merge.conflictstyle zdiff3
