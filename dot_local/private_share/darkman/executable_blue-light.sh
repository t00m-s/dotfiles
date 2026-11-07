#!/usr/bin/env sh
set -eu

case "${1:-}" in
dark)
	pkill -x hyprsunset 2>/dev/null || true
	setsid hyprsunset --temperature 3500 >/dev/null 2>&1 &
	;;
light)
	pkill -x hyprsunset 2>/dev/null || true
	setsid hyprsunset --temperature 5500 >/dev/null 2>&1 &
	;;
esac
