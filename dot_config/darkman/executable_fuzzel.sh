#!/usr/bin/env sh
set -eu

case "${1:-}" in
	dark) theme=red.ini ;;
	light) theme=light.ini ;;
	*) echo "Usage: $0 dark|light" >&2; exit 1 ;;
esac

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
ln -sfn -- "$config_home/fuzzel/theme/$theme" "$config_home/fuzzel/theme/current.ini"
