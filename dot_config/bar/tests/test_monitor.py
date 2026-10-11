import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("monitor", Path(__file__).parents[1] / "scripts/monitor.py")
monitor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(monitor)


class MonitorTests(unittest.TestCase):
    def test_cpu_does_not_double_count_guest(self):
        self.assertEqual(monitor.cpu_ticks("cpu 100 20 30 400 10 5 5 0 50 10"), (570, 410))

    def test_battery_and_ac_status(self):
        with tempfile.TemporaryDirectory() as directory:
            supplies = Path(directory)
            battery = supplies / "BAT0"
            battery.mkdir()
            (battery / "type").write_text("Battery")
            (battery / "capacity").write_text("63")
            (battery / "status").write_text("Charging")
            ac = supplies / "AC"
            ac.mkdir()
            (ac / "type").write_text("Mains")
            (ac / "online").write_text("1")
            result = monitor.battery_info(supplies)
            self.assertEqual(result["battery"], 63)
            self.assertTrue(result["batteryCharging"])
            self.assertTrue(result["batteryOnAC"])
            (battery / "present").write_text("0")
            self.assertFalse(monitor.battery_info(supplies)["batteryPresent"])

    def test_cpu_delta(self):
        self.assertIsNone(monitor.cpu_usage(None, (100, 50)))
        self.assertEqual(monitor.cpu_usage((100, 50), (200, 75)), 75)
        self.assertIsNone(monitor.cpu_usage((200, 75), (200, 75)))

    def test_memory_available(self):
        result = monitor.memory_usage("MemTotal: 1000 kB\nMemFree: 100 kB\nMemAvailable: 400 kB")
        self.assertEqual(result["memory"], 60)

    def test_route_uses_lowest_metric(self):
        text = "Iface Destination Gateway Flags RefCnt Use Metric Mask\nwlan0 00000000 1 0003 0 0 600 00000000\neth0 00000000 1 0003 0 0 100 00000000"
        self.assertEqual(monitor.default_interface(text), "eth0")
        self.assertEqual(monitor.default_interface(""), "")

    def test_temperature_prefers_package_over_core(self):
        with tempfile.TemporaryDirectory() as directory:
            device = Path(directory) / "hwmon0"
            device.mkdir()
            (device / "name").write_text("coretemp")
            (device / "temp1_label").write_text("Package id 0")
            (device / "temp1_input").write_text("55000")
            (device / "temp2_label").write_text("Core 0")
            (device / "temp2_input").write_text("65000")
            self.assertEqual(monitor.temperature("cpu", hwmon=Path(directory)), (55, "coretemp / Package id 0"))
            self.assertEqual(monitor.temperature("gpu", hwmon=Path(directory)), (None, ""))

    @patch.object(monitor, "run", return_value="Volume: 0.42 [MUTED]")
    def test_volume(self, mocked):
        self.assertEqual(monitor.volume_info(), {"volume": 42, "muted": True})

    @patch.object(monitor, "run", return_value="panel,backlight,50,50%,100")
    def test_brightness(self, mocked):
        self.assertEqual(monitor.brightness_info()["brightness"], 50)

    @patch.object(monitor.shutil, "which", return_value="/usr/bin/wpctl")
    @patch.object(monitor.subprocess, "run")
    def test_volume_clamped(self, mocked, which):
        mocked.return_value.returncode = 0
        monitor.control("volume-set", 200, "")
        self.assertEqual(mocked.call_args.args[0][-1], "100%")

    @patch.object(monitor.shutil, "which", return_value="/usr/bin/brightnessctl")
    @patch.object(monitor.subprocess, "run")
    def test_brightness_floor(self, mocked, which):
        mocked.return_value.returncode = 0
        monitor.control("brightness-set", 0, "panel")
        self.assertEqual(mocked.call_args.args[0][-1], "1%")
        self.assertIn("panel", mocked.call_args.args[0])
        self.assertIn("-n1", mocked.call_args.args[0])

    @patch.object(monitor, "run", return_value="")
    def test_unavailable_controls(self, mocked):
        self.assertIsNone(monitor.volume_info()["volume"])
        self.assertIsNone(monitor.brightness_info()["brightness"])


if __name__ == "__main__":
    unittest.main()
