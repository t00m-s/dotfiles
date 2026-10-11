"""Exercise the real QML theme in an isolated, windowless Quickshell instance."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


@unittest.skipUnless(shutil.which("quickshell"), "Quickshell is not installed")
class ThemeTests(unittest.TestCase):
    def test_system_updates_overrides_and_persistence(self):
        root = Path(__file__).parents[1]
        temporary_root = "/tmp/opencode" if Path("/tmp/opencode").is_dir() else None
        with tempfile.TemporaryDirectory(prefix="bar-theme-", dir=temporary_root) as directory:
            destination = Path(directory)
            for name in ("Theme.qml", "SystemAppearance.qml"):
                shutil.copy2(root / name, destination / name)
            shutil.copy2(root / "tests/theme_probe.qml", destination / "shell.qml")
            (destination / "qmldir").write_text(
                "singleton Theme 1.0 Theme.qml\n"
                "singleton SystemAppearance 1.0 SystemAppearance.qml\n"
            )
            env = dict(os.environ, QT_QPA_PLATFORM="offscreen", QT_QPA_PLATFORMTHEME="")
            for marker in ("THEME_SWITCHING_OK", "THEME_PERSISTENCE_OK"):
                result = subprocess.run(
                    ["quickshell", "-p", str(destination), "--no-color"],
                    capture_output=True, text=True, timeout=10, env=env,
                )
                output = result.stdout + result.stderr
                self.assertEqual(result.returncode, 0, output)
                self.assertIn(marker, output)
                self.assertNotIn("THEME_TEST_FAILED", output)


if __name__ == "__main__":
    unittest.main()
