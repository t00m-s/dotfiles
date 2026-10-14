#!/usr/bin/env bash
# Ryzen CPU and Radeon RX 9070 XT.
# Profile values are consumed by common.sh after this file is sourced.
PROFILE_HOSTNAME=renzo # shuck: ignore=C001
PROFILE_PACKAGES=(mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon linux-firmware-amdgpu) # shuck: ignore=C001
PROFILE_SERVICES=() # shuck: ignore=C001

configure_profile() {
	:
}
