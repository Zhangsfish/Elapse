"""Synthetic unit fixtures below are NOT screenshot-production inputs."""
import contextlib
import ast
import importlib.util
import io
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
import s03_preflight as preflight

spec = importlib.util.spec_from_file_location("export_captures", ROOT / "store-assets/scripts/export_captures.py")
exporter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(exporter)


class S03PreflightTests(unittest.TestCase):
    def fixture(self, root):
        source, dest = root / "source", root / "dest"
        source.mkdir()
        dest.mkdir()
        manifest = []
        for name in exporter.NAMES:
            filename = name + ".png"
            # Minimal header fixture exercises export guards, not decoded pixel proof.
            (source / filename).write_bytes(b"\x89PNG\r\n\x1a\n" + b"\0" * 8 + struct.pack(">II", 1320, 2868))
            manifest.append({"name": "store-en-" + name, "exportedFileName": filename})
        (source / "manifest.json").write_text(json.dumps(manifest))
        (dest / "test-summary.json").write_text(json.dumps(
            {"failedTests": 0, "passedTests": 1, "skippedTests": 0, "totalTestCount": 1}))
        return source, dest, manifest

    def test_export_only_named_attachments(self):
        with tempfile.TemporaryDirectory() as directory:
            source, dest, _ = self.fixture(Path(directory))
            (source / "private-unrelated.png").write_bytes(b"ignored")
            with contextlib.redirect_stdout(io.StringIO()):
                exporter.export(source, dest)
            self.assertEqual({p.stem for p in dest.glob("*.png")}, set(exporter.NAMES))
            self.assertEqual(len(json.loads((dest / "CAPTURES.json").read_text())), 4)

    def test_missing_duplicate_and_unsafe_attachments_fail_closed(self):
        for kind in ("missing", "duplicate", "unsafe"):
            with self.subTest(kind=kind), tempfile.TemporaryDirectory() as directory:
                source, dest, manifest = self.fixture(Path(directory))
                if kind == "missing":
                    manifest.pop()
                elif kind == "duplicate":
                    manifest.append(manifest[0])
                else:
                    manifest[0]["exportedFileName"] = "../outside.png"
                (source / "manifest.json").write_text(json.dumps(manifest))
                with self.assertRaises(AssertionError):
                    exporter.export(source, dest)

    def test_failed_or_skipped_ui_is_not_capture_pass(self):
        for field in ("failedTests", "skippedTests"):
            with self.subTest(field=field), tempfile.TemporaryDirectory() as directory:
                source, dest, _ = self.fixture(Path(directory))
                summary = {"failedTests": 0, "passedTests": 1, "skippedTests": 0, "totalTestCount": 1}
                summary[field] = 1
                (dest / "test-summary.json").write_text(json.dumps(summary))
                with self.assertRaises(AssertionError):
                    exporter.export(source, dest)

    def test_wrong_capture_dimensions_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            source, dest, _ = self.fixture(Path(directory))
            (source / "01-awareness.png").write_bytes(b"\x89PNG\r\n\x1a\n" + b"\0" * 8 + struct.pack(">II", 1, 1))
            with self.assertRaises(AssertionError):
                exporter.export(source, dest)

    def test_metadata_uses_utf8_bytes_not_chinese_character_count(self):
        text = (ROOT / "docs/APP_STORE_METADATA.md").read_text(encoding="utf-8")
        counts = preflight.metadata_counts(text)
        self.assertLessEqual(counts["zh-Hans"]["keywords_utf8_bytes"], 100)
        old_keywords = text.split("关键词：", 1)[1].split("\n", 1)[0]
        with self.assertRaises(AssertionError):
            preflight.metadata_counts(text.replace(old_keywords, "汉" * 34))

    def test_support_privacy_pages_are_static_bilingual_and_safe_linked(self):
        self.assertEqual(preflight.check_pages(ROOT / "public-pages"), "PASS_STATIC_SOURCE_NOT_ANONYMOUS_HTTPS")

    def test_pages_reject_script_or_remote_stylesheet(self):
        for injected in ('<script src="https://example.com/a.js"></script>',
                         '<link rel="stylesheet" href="https://example.com/a.css">'):
            with self.subTest(injected=injected), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                for name in ("index.html", "privacy.html", "style.css"):
                    text = (ROOT / "public-pages" / name).read_text(encoding="utf-8")
                    (root / name).write_text(text + (injected if name == "index.html" else ""), encoding="utf-8")
                with self.assertRaises(AssertionError):
                    preflight.check_pages(root)

    def test_source_privacy_manifest_and_report_boundary(self):
        inventory = preflight.check_privacy(ROOT)
        self.assertEqual(inventory["network_api_matches"], [])
        self.assertIn("STATIC_SOURCE_ONLY", inventory["basis"])

    def test_frozen_production_capture_hashes_and_preflight(self):
        self.assertEqual(preflight.run()["status"], "PASS")

    def test_existing_ui_dismissal_wait_is_bounded_and_keeps_assertion(self):
        test_source = (ROOT / "UITests/S02PolishUITests.swift").read_text(encoding="utf-8")
        helper = test_source.split("private func closeSupportAfterReplay", 1)[1].split("/// Run", 1)[0]
        self.assertIn('XCTAssertTrue(app.buttons["tutorial-skip"].waitForNonExistence(timeout: 5))', helper)
        self.assertIn('XCTAssertFalse(app.buttons["tutorial-skip"].exists)', helper)
        self.assertNotIn('sleep(', helper)

    def test_english_polish_preserves_copy_and_uniform_geometry(self):
        manifest = json.loads((ROOT / "store-assets/RENDER_MANIFEST_EN.json").read_text())
        self.assertEqual(manifest["polish_revision"], 2)
        frames = manifest["frames"]
        self.assertEqual([f["headline_lines"] for f in frames], [
            ["Feel time passing.", "Nothing else."],
            ["Choose the apps.", "Pick the interval."],
            ["A reminder.", "Not a restriction."],
            ["See where the", "time went."]])
        self.assertEqual([f["subtitle"] for f in frames], ["", "", "", "Total · by hour · by app"])
        for frame in frames:
            for key in ("phone_rect", "screen_rect", "brand_style", "headline_style", "subtitle_style"):
                self.assertEqual(frame[key], frames[0][key])
            self.assertIsNone(frame["in_phone_overlay"])
            self.assertGreaterEqual(frame["screen_rect"][2] / 856, 1.03)
            self.assertLessEqual(frame["screen_rect"][2] / 856, 1.05)
            self.assertEqual(frame["screen_rect"][3], round(frame["screen_rect"][2] * 2868 / 1320))
        interval = next(t for t in frames[1]["external_text_bounds"] if t["text"] == "5 · 10 · 15 · 30 · 60 min")
        self.assertEqual(interval["size"], 44)
        self.assertTrue(interval["bold"])
        self.assertGreaterEqual(interval["size"] * 360 / 1320, 12)

    def test_renderer_constants_match_committed_manifest(self):
        # Parse constants without importing Pillow/numpy on secret-free CI.
        tree = ast.parse((ROOT / "store-assets/scripts/render_store.py").read_text(encoding="utf-8"))
        constants = {node.targets[0].id: ast.literal_eval(node.value)
                     for node in tree.body if isinstance(node, ast.Assign)
                     and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name)
                     and node.targets[0].id in {"PHONE_RECT", "SCREEN_RECT", "BRAND", "HEADLINE", "SUBTITLE"}}
        frame = json.loads((ROOT / "store-assets/RENDER_MANIFEST_EN.json").read_text())["frames"][0]
        for source, recorded in (("PHONE_RECT", "phone_rect"), ("SCREEN_RECT", "screen_rect")):
            self.assertEqual(list(constants[source]), frame[recorded])
        for source, recorded in (("BRAND", "brand_style"), ("HEADLINE", "headline_style"), ("SUBTITLE", "subtitle_style")):
            self.assertEqual(constants[source], frame[recorded])


if __name__ == "__main__":
    unittest.main()
