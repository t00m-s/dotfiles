# Mocha bar · Quickshell

A standalone Hyprland bar inspired by your Waybar layout and Noctalia's rounded,
quiet panels. Catppuccin Mocha/Latte, lavender workspace pills, compact telemetry and
a shared quick-controls popup. This is not a Noctalia fork and does not require it.

## Run

Requires **Quickshell 0.2+**, with Hyprland and system-tray support, Qt Quick
Controls/Layouts, Python 3, `ip` (iproute2), `wpctl` (WirePlumber), and
`brightnessctl`. The font defaults to your existing **CommitMono Nerd Font**.
Install Quickshell using your distribution's packages:
<https://quickshell.org/docs/guide/install-setup/>.

```sh
quickshell -p ~/.config/bar/shell.qml
```

Quickshell watches the configuration and reloads changes. Your existing Waybar
configuration has not been modified. Both bars reserve space if run together;
for a clean preview, stop your current Waybar instance first. Only one active
system-tray host is recommended.

Once you want to replace Waybar, manually replace its startup command in your
Hyprland configuration with:

```ini
exec-once = quickshell -p ~/.config/bar/shell.qml
```

## Included

- A top bar on each monitor, showing only existing Hyprland workspaces (no empty
  numbered placeholders); click to switch, scroll to cycle existing workspaces on that monitor.
- Focused window title with full-title hover tooltip.
- CPU/GPU temperature, CPU utilization, memory utilization; detailed tooltips.
- Time and date (date moves to the time tooltip on narrower screens).
- Native StatusNotifier tray: left-click activate, right-click menu,
  middle-click secondary action, and scrolling.
- Network interface, IP address and live receive/transmit rates. A route/link
  indicates local connectivity, not guaranteed Internet access. Works without
  NetworkManager; supports IPv4 and IPv6 default routes.
- Volume and brightness: scroll in 5% steps, click for sliders. Right/middle-click
  volume to mute. The popup closes on an outside click or its close button.
- Battery percentage, charging/AC status and low-battery color on the right;
  hidden automatically on systems without a battery.
- A straight, edge-to-edge bar with no outer gaps. Stats and clock share one
  center block. Left and right sections are matching blocks with square outer
  ends and rounded inner ends. Hover effects and tooltips are disabled by default.

## Customize

Click volume, brightness, or network to open **Quick controls**, then use the
**System / Light / Dark** selector under Appearance. **System is the default**:
the entire bar and popup follow your system's light/dark preference automatically,
switching between Catppuccin Latte and Mocha on every monitor. Light and Dark are
manual overrides. Your choice is saved in `appearance.ini` next to `Theme.qml`
and restored after restarting. This changes only this bar, not your desktop/GTK theme.

Automatic detection listens to the freedesktop Settings portal's
`org.freedesktop.appearance` / `color-scheme` setting using `gdbus` (GLib). If the
portal is unavailable or has no preference, it follows Qt's platform color scheme,
falling back to dark when neither source supplies one. On Hyprland, your portal
backend must expose the Settings interface (commonly `xdg-desktop-portal-gtk`).
Changing only a GTK theme name, without publishing a color-scheme preference,
does not necessarily count as a system light/dark switch.

Edit `Settings.qml` for bar dimensions, clock format, polling,
backlight selection, or an optional network settings command. Edit `Theme.qml`
for colors and font. The title follows the **globally focused window**, while
workspace highlights follow each monitor's active workspace.

Set `hoverEnabled: true` in `Settings.qml` only if you want hover highlights and
tooltips. Quick controls use a separate overlay layer-shell panel with on-demand
keyboard focus, rather than a native Wayland popup.

Temperature sensors are selected from Linux hwmon. CPU package/Tctl/Tdie and GPU
edge sensors take priority. Unavailable readings display `—`, rather than a
misleading zero. To choose a particular driver, set `cpuSensor` or `gpuSensor`
to its hwmon name, e.g. `k10temp` / `amdgpu`.

`gpuFollowHdmi: true` (the default) switches the GPU temperature automatically:
AMD normally; the GPU owning a **connected HDMI port** when plugged in. On this
machine HDMI is wired to NVIDIA. The monitor checks DRM connector status at each
sample, uses the corresponding GPU's hwmon sensor if available, otherwise queries
that NVIDIA GPU by PCI ID with `nvidia-smi`. Unplugging immediately stops NVIDIA
queries and switches back to AMD at the next sample. Missing HDMI GPU readings
display `—`, not AMD's temperature mislabeled as NVIDIA. A nonempty `gpuSensor`
is a manual override and disables automatic switching.

HDMI connection is a useful gate on this machine, not a general GPU activity
detector: NVIDIA can also run compute/rendering workloads without a display.
This does not control GPU power or enable/disable displays. To use the original
sensor-selection behavior, set `gpuFollowHdmi: false`; `queryNvidia: true` then
allows NVIDIA querying when no GPU hwmon sensor is available (off by default
because querying can wake a sleeping GPU).

Your AMD backlight is selected automatically; you can explicitly set
`backlightDevice: "amdgpu_bl1"`.

Volume uses the default PipeWire output and caps changes at 100%. Brightness
changes stay above zero; this controls a Linux backlight, **not external-monitor
DDC/CI brightness**. If brightness writes fail, check your distribution's
brightnessctl/udev permissions. No privileged commands are run by this config.
Control and monitor readings refresh every two seconds by default.

## Checks / troubleshooting

```sh
python3 ~/.config/bar/scripts/monitor.py sample --gpu-follow-hdmi
python3 -m unittest discover -s ~/.config/bar/tests -v
```

`sample` is read-only. Its first CPU/rate reading is `null`, since those need two
samples. Use `stream` to inspect subsequent readings. Missing tools or sensors
are tolerated. Action failures appear in the popup.

The configuration loads in Quickshell 0.3.2. Theme tests run in an isolated,
windowless instance and check system light/dark updates, manual overrides and
persistence without changing your desktop preference. If a tray application is
missing, quit other tray hosts and restart the application. Missing glyphs
usually mean the configured Nerd Font is unavailable.

The interaction test also sends synthetic pointer clicks through an isolated
copy of the full bar: it opens controls, selects Dark/Light and closes controls.
It also drags and clicks both sliders, checking that stale telemetry does not
reset their thumbs. Hardware controls are mocked, so tests never change your
real volume or brightness.

If Qt logs `qt.qpa.wayland.textinput` / `Trying to disable ... but ... is focused`
when opening controls, it is a Wayland text-input focus warning, not a hardware
control error. This bar has no text-entry fields, so you can use Qt's compose
input context just for this process. Stop the existing bar, then launch:

```sh
QT_IM_MODULE=compose quickshell -p ~/.config/bar/shell.qml
```

The environment change requires restarting, not merely reloading the QML. It
does not change your desktop's input-method settings or hide unrelated warnings.
It requires QtTest and a running Wayland session, briefly displaying a test bar;
it does not move your pointer or change the real bar's saved theme.
