import pathlib
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from s00_archive_entitlements import BUNDLES, preserve
from s00_entitlement_checks import GROUP_TARGETS, file_app_group_status, file_status


class ArchiveEntitlementsTests(unittest.TestCase):
    def test_preserves_generated_entitlements_for_all_bundles(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = pathlib.Path(directory)
            root = archive / "Products" / "Applications"
            for relative in BUNDLES.values():
                (root / relative).mkdir(parents=True)
            self.assertTrue(preserve(archive))
            for target, relative in BUNDLES.items():
                saved = root / relative / "archived-expanded-entitlements.xcent"
                self.assertEqual(file_status(saved), "TRUE")
                if target in GROUP_TARGETS:
                    self.assertEqual(file_app_group_status(saved), "EXPECTED")

    def test_missing_bundle_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertFalse(preserve(pathlib.Path(directory)))


if __name__ == "__main__":
    unittest.main()
