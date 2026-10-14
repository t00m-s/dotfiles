#!/usr/bin/env python3
"""Small, dependency-free Linux telemetry bridge for the Quickshell UI."""

import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


def read(path, default=""):
    try:
        return Path(path).read_text().strip()
    except (OSError, UnicodeError):
        return default


def run(args, timeout=2):
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
        return result.stdout.strip() if result.returncode == 0 else ""
    except (OSError, subprocess.TimeoutExpired):
        return ""


def cpu_ticks(text):
    """Guest time is already counted in user/nice: only sum the first 8 fields."""
    values = [int(value) for value in text.splitlines()[0].split()[1:9]]
    return sum(values), values[3] + values[4]


def cpu_usage(previous, current):
    if previous is None or current[0] <= previous[0]:
        return None
    total = current[0] - previous[0]
    idle = current[1] - previous[1]
    return round(max(0, min(100, 100 * (total - idle) / total)), 1)


def memory_usage(text):
    fields = {}
    for line in text.splitlines():
        key, value = line.split(":", 1)
        fields[key] = int(value.split()[0])
    total = fields.get("MemTotal", 0)
    available = fields.get("MemAvailable")
    if available is None:
        available = sum(fields.get(key, 0) for key in ("MemFree", "Buffers", "Cached"))
    used = max(0, total - available)
    return {
        "memory": round(100 * used / total, 1) if total else None,
        "memoryUsedGiB": round(used / 1048576, 2),
        "memoryTotalGiB": round(total / 1048576, 2),
    }


def temperature(kind, override="", hwmon=Path("/sys/class/hwmon"), device_path=None):
    """Prefer CPU package/Tctl and GPU edge, not motherboard/SSD sensors."""
    accepted = {"cpu": {"coretemp", "k10temp", "zenpower", "cpu_thermal"},
                "gpu": {"amdgpu", "nouveau", "i915", "xe", "nvidia"}}[kind]
    candidates = []
    for device in sorted(hwmon.glob("hwmon*")):
        name = read(device / "name")
        if (override and name != override) or (not override and name not in accepted):
            continue
        if device_path is not None and (device / "device").resolve() != device_path.resolve():
            continue
        for sensor in sorted(device.glob("temp*_input")):
            try:
                value = float(read(sensor)) / 1000
            except ValueError:
                continue
            if not -20 <= value <= 150:
                continue
            label = read(sensor.with_name(sensor.name.replace("_input", "_label")))
            preferred = any(key in label.lower() for key in
                            (("package", "tctl", "tdie") if kind == "cpu" else ("edge", "gpu")))
            candidates.append((0 if preferred else 1, name, label, value))
    if not candidates:
        return None, ""
    best_priority = min(item[0] for item in candidates)
    # For multiple CPU packages, report the hottest preferred sensor.
    selected = max((item for item in candidates if item[0] == best_priority), key=lambda item: item[3])
    return round(selected[3], 1), selected[1] + (" / " + selected[2] if selected[2] else "")


def connected_display_gpu(drm=Path("/sys/class/drm"), hdmi_only=False):
    """Map a connected display (HDMI, DP, etc.) to its owning PCI GPU."""
    pattern = "card*-HDMI-*" if hdmi_only else "card*-*"
    for connector in sorted(drm.glob(pattern)):
        if read(connector / "status") != "connected":
            continue
        card = drm / connector.name.split("-", 1)[0]
        device = (card / "device").resolve()
        vendor = read(device / "vendor")
        if vendor in ("0x10de", "0x1002", "0x8086"):
            return device, vendor
    return None


def connected_hdmi_gpu(drm=Path("/sys/class/drm")):
    return connected_display_gpu(drm, hdmi_only=True)


def gpu_cards(drm=Path("/sys/class/drm")):
    cards = []
    for card in sorted(drm.glob("card*")):
        if not re.fullmatch(r"card\d+", card.name):
            continue
        device = (card / "device").resolve()
        vendor = read(device / "vendor")
        if vendor in ("0x10de", "0x1002", "0x8086"):
            cards.append((device, vendor))
    return cards


def hybrid_laptop(drm=Path("/sys/class/drm")):
    internal = any(drm.glob("card*-eDP-*")) or any(drm.glob("card*-LVDS-*"))
    vendors = {vendor for _, vendor in gpu_cards(drm)}
    return internal and {"0x1002", "0x10de"}.issubset(vendors)


def nvidia_temperature(device=""):
    command = ["nvidia-smi"] + (["-i", device] if device else [])
    output = run(command + ["--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"])
    values = [float(line) for line in output.splitlines() if re.fullmatch(r"\d+(\.\d+)?", line)]
    return (max(values), "nvidia-smi") if values else (None, "")


def card_temperature(device, vendor, hwmon):
    default_driver = {"0x10de": "nvidia", "0x1002": "amdgpu", "0x8086": "i915"}[vendor]
    driver_link = device / "driver"
    driver = driver_link.resolve().name if driver_link.exists() else default_driver
    value, sensor = temperature("gpu", driver, hwmon, device_path=device)
    if value is None and vendor == "0x10de":
        value, sensor = nvidia_temperature(device.name)
    return value, sensor or driver + " (unavailable)"


def gpu_temperature(override="", query_nvidia=False, follow_hdmi=False,
                    hwmon=Path("/sys/class/hwmon"), drm=Path("/sys/class/drm"), profile="auto"):
    # Explicit sensor selection takes priority over HDMI auto-switching.
    laptop = profile == "laptop" or (profile == "auto" and hybrid_laptop(drm))
    if follow_hdmi and laptop and not override:
        connected = connected_hdmi_gpu(drm)
        if connected:
            device, vendor = connected
            value, sensor = card_temperature(device, vendor, hwmon)
            return value, sensor + " / HDMI"
        # This machine's integrated GPU is AMD. Do not inspect NVIDIA sensors or
        # run nvidia-smi at all while HDMI is disconnected.
        return temperature("gpu", "amdgpu", hwmon)
    if not laptop and not override:
        # Desktops don't need an HDMI gate: DisplayPort and a lone headless GPU
        # work too. Prefer a connected output, then the boot GPU, then the first.
        cards = gpu_cards(drm)
        target = connected_display_gpu(drm)
        if target is None and cards:
            target = next((card for card in cards if read(card[0] / "boot_vga") == "1"), cards[0])
        if target:
            return card_temperature(*target, hwmon)
    value, sensor = temperature("gpu", override, hwmon)
    if value is None and (query_nvidia or (profile == "desktop" and not override)):
        return nvidia_temperature()
    return value, sensor


def default_interface(text):
    routes = []
    for line in text.splitlines()[1:]:
        fields = line.split()
        if len(fields) >= 8 and fields[1] == "00000000" and int(fields[3], 16) & 1:
            routes.append((int(fields[6]), fields[0]))
    return min(routes)[1] if routes else ""


def network_info():
    interface = default_interface(read("/proc/net/route"))
    if not interface:
        # Support IPv6-only connections as well.
        try:
            routes = json.loads(run(["ip", "-j", "-6", "route", "show", "default"]) or "[]")
            interface = min(routes, key=lambda route: route.get("metric", 0)).get("dev", "") if routes else ""
        except (ValueError, TypeError):
            pass
    base = Path("/sys/class/net") / interface
    address = ""
    if interface:
        try:
            devices = json.loads(run(["ip", "-j", "address", "show", "dev", interface]) or "[]")
            addresses = [entry for device in devices for entry in device.get("addr_info", [])
                         if entry.get("scope") == "global"]
            addresses.sort(key=lambda entry: entry.get("family") != "inet")
            address = addresses[0].get("local", "") if addresses else ""
        except (ValueError, TypeError):
            pass
    counters = None
    if interface:
        try:
            counters = (int(read(base / "statistics/rx_bytes")), int(read(base / "statistics/tx_bytes")))
        except ValueError:
            pass
    return {
        "networkInterface": interface,
        # A route is a local link indication, not a claim of Internet access.
        "networkOnline": bool(interface) and read(base / "operstate") not in ("down", "notpresent"),
        "networkWireless": (base / "wireless").exists() or (base / "phy80211").exists(),
        "networkAddress": address,
    }, counters


def volume_info():
    value = run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
    match = re.search(r"Volume:\s*([\d.]+)", value)
    return {"volume": round(float(match[1]) * 100) if match else None,
            "muted": "[MUTED]" in value}


def brightness_info(device=""):
    args = ["brightnessctl"] + (["-d", device] if device else ["-c", "backlight"])
    fields = run(args + ["-m"]).splitlines()
    if fields:
        columns = fields[0].split(",")
        if len(columns) >= 5:
            try:
                return {"brightness": round(100 * int(columns[2]) / int(columns[4])),
                        "backlightDevice": columns[0]}
            except (ValueError, ZeroDivisionError):
                pass
    return {"brightness": None, "backlightDevice": ""}


def battery_info(supplies=Path("/sys/class/power_supply")):
    batteries = []
    on_ac = False
    for supply in supplies.glob("*"):
        if read(supply / "type") != "Battery":
            on_ac = on_ac or read(supply / "online") == "1"
            continue
        if read(supply / "present", "1") == "0":
            continue
        try:
            capacity = max(0, min(100, float(read(supply / "capacity"))))
        except ValueError:
            continue
        batteries.append((capacity, read(supply / "status", "Unknown")))
    statuses = [status for _, status in batteries]
    charging = "Charging" in statuses
    status = "Charging" if charging else (
        "Full" if statuses and all(value == "Full" for value in statuses)
        else "Discharging" if "Discharging" in statuses else "Not charging"
    )
    return {
        "batteryPresent": bool(batteries),
        "battery": round(sum(capacity for capacity, _ in batteries) / len(batteries)) if batteries else None,
        "batteryCharging": charging,
        "batteryOnAC": on_ac,
        "batteryStatus": status if batteries else "Unavailable",
    }


class Monitor:
    def __init__(self, args):
        self.args = args
        self.previous_cpu = None
        self.previous_network = None

    def sample(self):
        result = {}
        try:
            current_cpu = cpu_ticks(read("/proc/stat"))
            result["cpu"] = cpu_usage(self.previous_cpu, current_cpu)
            self.previous_cpu = current_cpu
        except (ValueError, IndexError):
            result["cpu"] = None
        try:
            result.update(memory_usage(read("/proc/meminfo")))
        except (ValueError, IndexError):
            result.update(memory=None, memoryUsedGiB=None, memoryTotalGiB=None)
        result["cpuTemp"], result["cpuSensor"] = temperature("cpu", self.args.cpu_sensor)
        result["gpuTemp"], result["gpuSensor"] = gpu_temperature(
            self.args.gpu_sensor, self.args.nvidia, self.args.gpu_follow_hdmi,
            profile=self.args.gpu_profile,
        )
        network, counters = network_info()
        now = time.monotonic()
        interface = network["networkInterface"]
        network.update(networkRx=None, networkTx=None)
        if counters and self.previous_network and self.previous_network[0] == interface:
            _, previous_time, previous = self.previous_network
            elapsed = now - previous_time
            if elapsed > 0:
                network["networkRx"] = max(0, (counters[0] - previous[0]) / elapsed)
                network["networkTx"] = max(0, (counters[1] - previous[1]) / elapsed)
        self.previous_network = (interface, now, counters) if counters else None
        result.update(network)
        result.update(volume_info())
        result.update(brightness_info(self.args.device))
        result.update(battery_info())
        return result


def control(action, value, device):
    if action.startswith("volume"):
        if action == "volume-mute":
            command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        elif action == "volume-set":
            command = ["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", f"{max(0, min(100, value))}%"]
        else:
            amount = max(-100, min(100, value))
            command = ["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", f"{abs(amount)}%{'+' if amount >= 0 else '-'}"]
    else:
        command = ["brightnessctl"] + (["-d", device] if device else ["-c", "backlight"])
        # Never dim completely to black. Permissions are handled by brightnessctl/udev.
        command += ["-n1", "set"]
        if action == "brightness-set":
            command += [f"{max(1, min(100, value))}%"]
        else:
            amount = max(-100, min(100, value))
            command += [f"+{amount}%" if amount >= 0 else f"{abs(amount)}%-"]
    if not shutil.which(command[0]):
        raise RuntimeError(f"{command[0]} is not installed")
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=3)
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(f"{command[0]} timed out") from exc
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"{command[0]} failed")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("stream", "sample", "volume-set", "volume-step", "volume-mute", "brightness-set", "brightness-step"))
    parser.add_argument("value", nargs="?", type=int)
    parser.add_argument("--interval", type=float, default=2)
    parser.add_argument("--cpu-sensor", default="")
    parser.add_argument("--gpu-sensor", default="")
    parser.add_argument("--device", default="")
    parser.add_argument("--nvidia", action="store_true")
    parser.add_argument("--gpu-follow-hdmi", action="store_true")
    parser.add_argument("--gpu-profile", choices=("auto", "desktop", "laptop"), default="auto")
    args = parser.parse_args()
    if args.action not in ("sample", "stream"):
        if args.action != "volume-mute" and args.value is None:
            parser.error("this action requires a numeric value")
        try:
            control(args.action, args.value, args.device)
            # Feed confirmed values back immediately rather than waiting for
            # the next full telemetry sample (which may also query the GPU).
            state = volume_info() if args.action.startswith("volume") else brightness_info(args.device)
            print(json.dumps(state, allow_nan=False), flush=True)
        except (RuntimeError, OSError) as exc:
            print(str(exc), file=sys.stderr)
            return 1
        return 0
    monitor = Monitor(args)
    try:
        while True:
            start = time.monotonic()
            print(json.dumps(monitor.sample(), allow_nan=False), flush=True)
            if args.action == "sample":
                break
            time.sleep(max(0.1, max(0.5, args.interval) - (time.monotonic() - start)))
    except (KeyboardInterrupt, BrokenPipeError):
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
