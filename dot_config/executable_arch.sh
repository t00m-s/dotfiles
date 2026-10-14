#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || ( "$1" != laptop && "$1" != desktop ) ]]; then
	echo "Usage: $0 laptop|desktop" >&2
	exit 1
fi

if [[ $(id -u) -eq 0 ]]; then
	echo "This script must NOT be run as root. Run it as your regular user; sudo will be used when needed." >&2
	exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROFILE=$1
SETUP_USER=tommaso

source "$SCRIPT_DIR/arch/common.sh"
source "$SCRIPT_DIR/arch/$PROFILE.sh"

sudo -v
configure_system
install_packages
configure_user
configure_common
configure_profile
install_aur_packages
enable_services
echo "Finished $PROFILE setup."
