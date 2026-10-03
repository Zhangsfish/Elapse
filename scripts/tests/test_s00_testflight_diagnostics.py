"""Ensure Apple validation metadata survives while arbitrary log text stays private."""

from pathlib import Path
import json
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "s00_testflight_diagnostics.py"


class DiagnosticsTests(unittest.TestCase):
    def test_validation_metadata_is_bounded_and_redacted(self) -> None:
        sample = (
            "error: exportArchive: Missing required icon file. The bundle "
            "com.zhangsfish.elapse does not contain an app icon of exactly "
            "120x120 pixels. (ID: 12345678-1234-1234-1234-123456789abc) "
            "FAKE_PRIVATE_TOKEN\n"
            "error: exportArchive: Missing Info.plist key 'CFBundleIconName' "
            "for com.zhangsfish.elapse. ITMS-90713 FAKE_PRIVATE_TOKEN\n"
            "error: exportArchive: Invalid Bundle: no orientations were specified "
            "in UISupportedInterfaceOrientations for com.zhangsfish.elapse.\n"
        )
        with tempfile.TemporaryDirectory() as temp:
            log = Path(temp) / "export.log"
            log.write_text(sample, encoding="utf-8")
            result = subprocess.run(
                [sys.executable, str(SCRIPT), str(log)],
                capture_output=True,
                text=True,
                check=True,
            )

        self.assertNotIn("FAKE_PRIVATE_TOKEN", result.stdout)
        details = [
            json.loads(line.split("=", 1)[1])
            for line in result.stdout.splitlines()
            if line.startswith("S00_TF_VALIDATION_")
        ]
        self.assertEqual(len(details), 3)
        self.assertIn("120x120", details[0]["required_pixels"])
        self.assertIn("com.zhangsfish.elapse", details[0]["own_bundle_ids"])
        self.assertIn("cfbundleiconname", details[1]["plist_keys"])
        self.assertIn("itms-90713", details[1]["apple_codes"])
        self.assertIn("uisupportedinterfaceorientations", details[2]["plist_keys"])


if __name__ == "__main__":
    unittest.main()
