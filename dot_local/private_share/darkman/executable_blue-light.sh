#!/usr/bin/env sh
set -eu

case "${1:-}" in
dark) hyprsunset --temperature 3500 ;;
light) hyprsunset --temperature 6000 ;;
*)
	echo "Usage: $0 dark|light" >&2
	exit 1
	;;
esac
