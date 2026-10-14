#!/usr/bin/env bash
# HP Omen: Ryzen CPU, AMD integrated GPU, NVIDIA discrete GPU.
# Profile values are consumed by common.sh after this file is sourced.
PROFILE_HOSTNAME=poldo # shuck: ignore=C001
PROFILE_PACKAGES=(nvidia-dkms nvidia-utils lib32-nvidia-utils) # shuck: ignore=C001
PROFILE_SERVICES=(omen-fan nvidia-powerd) # shuck: ignore=C001

configure_profile() {
	sudo mkdir -p /etc/modprobe.d /etc/modules-load.d
	echo "ec_sys" | sudo tee /etc/modules-load.d/ec_sys.conf
	echo "options ec_sys write_support=1" | sudo tee /etc/modprobe.d/ec_sys.conf
	echo "blacklist nouveau" | sudo tee /etc/modprobe.d/nouveau.conf

	mic_config_dir="$SETUP_HOME/.config/wireplumber/wireplumber.conf.d"
	sudo -u "$SETUP_USER" mkdir -p "$mic_config_dir"
	sudo -u "$SETUP_USER" tee "$mic_config_dir/51-disable-stereo-mic.conf" <<EOF
monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "alsa_input.pci-0000_06_00.6.HiFi__Mic2__source"
      }
    ]
    actions = {
      update-props = {
        node.disabled = true
      }
    }
  }
]
EOF
	sudo tee /etc/udev/rules.d/99-gpu-dri.rules <<EOF
KERNEL=="card*", KERNELS=="0000:06:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
EOF
	sudo tee /etc/systemd/system/omen-fan.service <<EOF
[Unit]
Description=HP Omen Fan Control Daemon
After=multi-user.target

[Service]
Type=simple
WorkingDirectory=$SETUP_HOME/Projects/omen-fan
ExecStart=/usr/bin/uv run $SETUP_HOME/Projects/omen-fan/omen-fand.py
Restart=always
RestartSec=5s
User=root

[Install]
WantedBy=multi-user.target
EOF
	sudo mkdir -p /etc/omen-fan
	sudo tee /etc/omen-fan/config.toml <<EOF
[service]
TEMP_CURVE = [51, 60, 70, 80, 90]
SPEED_CURVE = [0, 30, 40, 70, 100]
IDLE_SPEED = 0
POLL_INTERVAL = 1

[script]
BYPASS_DEVICE_CHECK = 1
EOF
	sudo mkdir -p /etc/systemd/logind.conf.d
	sudo tee /etc/systemd/logind.conf.d/90-laptop.conf <<EOF
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF
}
