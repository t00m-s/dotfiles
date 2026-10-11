"""Drive actual pointer events through an isolated copy of the bar on Wayland."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


@unittest.skipUnless(shutil.which("quickshell") and os.environ.get("WAYLAND_DISPLAY"),
                     "Requires Quickshell, QtTest and a running Wayland session")
class InteractionTests(unittest.TestCase):
    def test_controls_theme_buttons_and_slider_drags(self):
        root = Path(__file__).parents[1]
        temporary_root = "/tmp/opencode" if Path("/tmp/opencode").is_dir() else None
        with tempfile.TemporaryDirectory(prefix="bar-interaction-", dir=temporary_root) as directory:
            destination = Path(directory)
            for source in root.glob("*.qml"):
                shutil.copy2(source, destination / source.name)
            # Slider tests must never alter the user's real volume/backlight.
            shutil.copy2(root / "tests/MockSystemState.qml", destination / "SystemState.qml")
            shutil.copy2(root / "qmldir", destination / "qmldir")
            shutil.copytree(root / "components", destination / "components")
            shutil.copytree(root / "scripts", destination / "scripts")
            (destination / "shell.qml").rename(destination / "app.qml")
            shutil.copy2(root / "tests/interaction_probe.qml", destination / "shell.qml")
            result = subprocess.run(
                ["quickshell", "-p", str(destination), "--no-color"],
                capture_output=True, text=True, timeout=10,
            )
            output = result.stdout + result.stderr
            self.assertEqual(result.returncode, 0, output)
            self.assertIn("INTERACTION_OK", output)
            self.assertNotIn("INTERACTION_FAILED", output)


if __name__ == "__main__":
    unittest.main()
