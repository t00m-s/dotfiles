import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


@unittest.skipUnless(shutil.which("quickshell"), "Requires Quickshell")
class ControlQueueTests(unittest.TestCase):
    def test_latest_slider_value_and_immediate_feedback(self):
        root = Path(__file__).parents[1]
        temporary_root = "/tmp/opencode" if Path("/tmp/opencode").is_dir() else None
        with tempfile.TemporaryDirectory(prefix="bar-controls-", dir=temporary_root) as directory:
            destination = Path(directory)
            for name in ("SystemState.qml", "Settings.qml"):
                shutil.copy2(root / name, destination / name)
            (destination / "qmldir").write_text(
                "singleton SystemState 1.0 SystemState.qml\nsingleton Settings 1.0 Settings.qml\n"
            )
            shutil.copy2(root / "tests/control_queue_probe.qml", destination / "shell.qml")
            scripts = destination / "scripts"
            scripts.mkdir()
            shutil.copy2(root / "tests/fake_control_backend.py", scripts / "monitor.py")
            env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QPA_PLATFORMTHEME="")
            result = subprocess.run(
                ["quickshell", "-p", str(destination), "--no-color"],
                capture_output=True, text=True, timeout=10, env=env,
            )
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn("CONTROL_QUEUE_OK", output)
            self.assertEqual((scripts / "commands.log").read_text().splitlines(), [
                "volume-set:10", "brightness-set:40", "volume-step:5", "volume-set:80",
            ])


if __name__ == "__main__":
    unittest.main()
