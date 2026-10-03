import pathlib
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from s00_intermediate_sign import ORDER, sign


class IntermediateSigningTests(unittest.TestCase):
    def test_nested_extensions_are_signed_before_main_app(self):
        self.assertEqual(ORDER, ("ElapseReport", "ElapseMonitor", "Elapse"))

    def test_missing_archive_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertFalse(sign(pathlib.Path(directory)))


if __name__ == "__main__":
    unittest.main()
