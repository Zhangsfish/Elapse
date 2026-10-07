"""Release-only closeout invariants; no live API/credentials in ordinary tests."""
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
import s03_preflight

PROMOTIONAL = ("Choose the apps you want to notice and set a 5-minute interval. "
               "Everwhile sends reminders based on cumulative use and shows total, hourly, "
               "and per-app time in Today.")


class CloseoutTests(unittest.TestCase):
    def test_exact_owner_english_promotional_copy_and_limits(self):
        text = (ROOT / "docs/APP_STORE_METADATA.md").read_text(encoding="utf-8")
        actual = text.split("Promotional text: ", 1)[1].split("\n", 1)[0]
        self.assertEqual(actual, PROMOTIONAL)
        self.assertEqual(len(actual), 165)
        self.assertEqual(s03_preflight.metadata_counts(text)["en"]["promotional_text"], 165)

    def test_default_query_and_explicit_narrow_prepare_have_no_upload_or_submission(self):
        source = (ROOT / "scripts/s03_asc_readback.swift").read_text(encoding="utf-8")
        self.assertIn('request.httpMethod = "GET"', source)
        self.assertIn('"filter[version]": "92.1"', source)
        self.assertIn('version == "0.1.0"', source)
        self.assertNotIn('httpMethod = "POST"', source)
        self.assertIn('CommandLine.arguments[2] == "--prepare-fields"', source)
        self.assertIn('path.hasSuffix("/relationships/build")', source)
        self.assertNotIn('"territory"', source)
        self.assertNotIn('"releaseType": "AFTER_APPROVAL"', source)
        self.assertNotIn('print(token)', source)
        self.assertNotIn('print(keyID)', source)
        self.assertNotIn('print(issuer)', source)
        self.assertNotIn('appStoreVersionSubmissions', source)

    def test_query_secrets_are_not_used_by_ordinary_ci(self):
        text = (ROOT / ".github/workflows/s03-review-rc.yml").read_text(encoding="utf-8")
        readback = text.split("  read-existing-rc:", 1)[1].split("  verify-release-tooling:", 1)[0]
        self.assertIn("if: github.event_name == 'workflow_dispatch'", readback)
        ordinary = text.split("  verify-release-tooling:", 1)[1].split("  review-rc:", 1)[0]
        self.assertNotIn("secrets.", ordinary)
        self.assertIn("swiftc -typecheck scripts/s03_asc_readback.swift", ordinary)
        self.assertNotIn("s03_review_release.sh", readback)

    def test_live_pages_verifier_never_uses_a_session(self):
        text = (ROOT / "scripts/s03_live_pages.py").read_text(encoding="utf-8")
        self.assertIn('response.status == 200', text)
        self.assertIn('raw == expected', text)
        self.assertNotIn('HTTPCookieProcessor', text)
        self.assertNotIn('"Authorization":', text)
        self.assertIn('"LIVE_VERIFIED"', text)


if __name__ == "__main__":
    unittest.main()
