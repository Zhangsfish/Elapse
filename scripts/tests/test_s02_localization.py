import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
KEY_PATTERN = re.compile(r'^"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)";\s*$', re.MULTILINE)
REFERENCE_PATTERN = re.compile(r'"((?:home|diagnostics|today|report)\.[A-Za-z0-9.]+)"')


class S02LocalizationTests(unittest.TestCase):
    def test_languages_have_matching_unique_keys_and_all_ui_references(self):
        languages = {}
        for language in ("en", "zh-Hans"):
            source = (ROOT / "Localization" / f"{language}.lproj" / "Localizable.strings").read_text(
                encoding="utf-8"
            )
            pairs = KEY_PATTERN.findall(source)
            self.assertEqual(len(pairs), len(set(key for key, _ in pairs)))
            languages[language] = {key for key, _ in pairs}
        self.assertEqual(languages["en"], languages["zh-Hans"])
        for file in (ROOT / "App" / "ContentView.swift", ROOT / "ReportExtension" / "ElapseReportExtension.swift"):
            references = set(REFERENCE_PATTERN.findall(file.read_text(encoding="utf-8")))
            self.assertFalse(references - languages["en"], f"Missing localizations in {file}")


if __name__ == "__main__":
    unittest.main()
