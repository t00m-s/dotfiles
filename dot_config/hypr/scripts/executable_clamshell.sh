#!/usr/bin/env bash

# --- CONFIGURATION ---
INTERNAL_DISPLAY="eDP-1"

ICON_LAPTOP="computer-laptop"
ICON_MONITOR="video-display"

notify_user() {
  notify-send -u low -i "$3" "$1" "$2"
}

mode_close() {
  MONITORS_COUNT=$(hyprctl monitors all | grep -c "Monitor")

  if [[ $MONITORS_COUNT -gt 1 ]]; then
    # Disable internal display using Lua eval
    hyprctl eval 'hl.monitor({ output = "'"$INTERNAL_DISPLAY"'", disabled = true })'

    # Find external monitor name and shift focus to it using Lua dispatcher
    EXTERNAL_MONITOR=$(hyprctl monitors | grep "^Monitor" | awk '{print $2}' | grep -v "$INTERNAL_DISPLAY" | head -n 1)
    if [[ -n "$EXTERNAL_MONITOR" ]]; then
      hyprctl dispatch 'hl.dsp.focus({ monitor = "'"$EXTERNAL_MONITOR"'" })'
    fi

    notify_user "Clamshell Mode" "External monitor active. Laptop screen disabled." "$ICON_MONITOR"
  else
    notify_user "Clamshell Mode" "No external monitor detected. Laptop screen kept active." "$ICON_LAPTOP"
  fi
}

mode_open() {
  # Enable internal screen using Lua eval with scale 1.25
  hyprctl eval 'hl.monitor({ output = "'"$INTERNAL_DISPLAY"'", mode = "1920x1200@144", position = "0x0", scale = 1.25, disabled = false })'
  notify_user "Laptop Mode" "Laptop screen enabled." "$ICON_LAPTOP"
}

# --- LOGIC ---
case "$1" in
  close)
    mode_close
    ;;
  open)
    mode_open
    ;;
  check)
    if grep -q "open" /proc/acpi/button/lid/*/state; then
      mode_open
    else
      mode_close
    fi
    ;;
  *)
    echo "Usage: $0 [open|close|check]"
    exit 1
    ;;
esac
