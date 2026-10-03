import io
import pathlib
import sys
import unittest
import zipfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from s00_signed_ipa_audit import safe_extract


class SignedIpaAuditTests(unittest.TestCase):
    def test_safe_extract_rejects_parent_traversal(self):
        data = io.BytesIO()
        with zipfile.ZipFile(data, "w") as archive:
            archive.writestr("../profile", "private")
        data.seek(0)
        with zipfile.ZipFile(data) as archive:
            with self.assertRaisesRegex(ValueError, "unsafe IPA member"):
                safe_extract(archive, pathlib.Path("unused"))


if __name__ == "__main__":
    unittest.main()
