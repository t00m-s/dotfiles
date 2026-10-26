#!/usr/bin/env sh
set -eu

case "${1:-}" in
dark) hyprsunset --temperature 4500 ;;
light) hyprsunset --identity ;;
*)
	echo "Usage: $0 dark|light" >&2
	exit 1
	;;
esac
