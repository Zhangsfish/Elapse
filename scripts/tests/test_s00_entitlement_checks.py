import plistlib
import sys
import tempfile
import unittest
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from s00_entitlement_checks import (  # noqa: E402
    expected_path_status,
    family_controls_status,
    file_status,
)


class EntitlementChecksTests(unittest.TestCase):
    def test_signature_true_missing_false_and_parse_error(self) -> None:
        self.assertEqual(
            family_controls_status(plistlib.dumps({"com.apple.developer.family-controls": True})),
            "TRUE",
        )
        self.assertEqual(family_controls_status(plistlib.dumps({"other": True})), "MISSING")
        self.assertEqual(
            family_controls_status(plistlib.dumps({"com.apple.developer.family-controls": False})),
            "NOT_TRUE",
        )
        self.assertEqual(family_controls_status(b""), "READ_ERROR")
        self.assertEqual(family_controls_status(b"not a plist"), "READ_ERROR")

    def test_profile_allowance_is_distinct_from_signature_claim(self) -> None:
        profile = plistlib.dumps({"Entitlements": {"com.apple.developer.family-controls": True}})
        self.assertEqual(family_controls_status(profile, profile=True), "TRUE")
        self.assertEqual(family_controls_status(profile), "MISSING")
        self.assertEqual(family_controls_status(plistlib.dumps({}), profile=True), "READ_ERROR")

    def test_file_and_effective_path_fail_closed(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            good = root / "App" / "Elapse.entitlements"
            good.parent.mkdir()
            good.write_bytes(plistlib.dumps({"com.apple.developer.family-controls": True}))
            self.assertEqual(file_status(good), "TRUE")
            self.assertEqual(file_status(root / "missing.plist"), "READ_ERROR")
            self.assertEqual(expected_path_status("App/Elapse.entitlements", "App/Elapse.entitlements", root), "EXPECTED")
            self.assertEqual(expected_path_status(str(good), "App/Elapse.entitlements", root), "EXPECTED")
            self.assertEqual(expected_path_status("", "App/Elapse.entitlements", root), "MISSING")
            self.assertEqual(expected_path_status("Other.entitlements", "App/Elapse.entitlements", root), "UNEXPECTED")


if __name__ == "__main__":
    unittest.main()
