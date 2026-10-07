"""Fixture mutations stay in temporary directories; no production fake state."""
import contextlib
import io
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "store-assets/scripts"))
import bilingual_asset_checks as assets
import english_freeze
import export_captures_zh_hans as exporter


class BilingualAssetsTests(unittest.TestCase):
    def test_english_freeze(self):
        self.assertEqual(english_freeze.check()["status"], "PASS")

    def test_english_image_or_contact_tamper_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(ROOT / "store-assets", root / "assets")
            target = root / "assets"
            for name in ("en/01-awareness.png", "CONTACT_SHEET_EN.png"):
                path = target / name
                original = path.read_bytes()
                path.write_bytes(original+b"tamper")
                with self.assertRaisesRegex(AssertionError, "English freeze changed"):
                    english_freeze.check(target)
                path.write_bytes(original)

    def test_chinese_capture_and_english_pipeline_separated(self):
        test = (ROOT / "UITests/S03ChineseStoreScreenshotsUITests.swift").read_text(encoding="utf-8")
        self.assertIn('"(zh-Hans)"', test)
        self.assertIn('"zh_CN"', test)
        self.assertNotIn('"(en)"', test)
        workflow = (ROOT / ".github/workflows/s03-store-screenshots-zh-hans.yml").read_text()
        for text in ("-configuration Release", "iPhone-17-Pro-Max", "-array zh-Hans", "AppleLocale zh_CN", "--time '9:41'", "--batteryLevel 100"):
            self.assertIn(text, workflow)
        self.assertNotIn("secrets.", workflow)
        self.assertNotIn("testEnglishStoreScreens", workflow)

    def test_final_bilingual_assets(self):
        # Initial capture-only commit intentionally lacks Chinese final assets.
        result = assets.check(require_chinese=(ROOT / "store-assets/RENDER_MANIFEST_ZH_HANS.json").exists())
        self.assertIn(result.get("zh_Hans"), ("NOT_RUN_CAPTURE_PENDING", "PASS_4_RGB_SRGB_HASH_GEOMETRY"))

    def test_chinese_geometry_or_stale_pixel_proof_rejected(self):
        if not (ROOT / "store-assets/RENDER_MANIFEST_ZH_HANS.json").exists():
            self.skipTest("Chinese capture/render pending, not final asset PASS")
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "assets"
            shutil.copytree(ROOT / "store-assets", root)
            path = root / "RENDER_MANIFEST_ZH_HANS.json"
            manifest = json.loads(path.read_text(encoding="utf-8"))
            manifest["frames"][0]["screen_rect"][2] += 1
            path.write_text(json.dumps(manifest), encoding="utf-8")
            with self.assertRaises(AssertionError):
                assets.check(root)

    def test_manifest_lf_crlf_is_equivalent_but_content_stays_hash_bound(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "assets"
            shutil.copytree(ROOT / "store-assets", root)
            path = root / "RENDER_MANIFEST_ZH_HANS.json"
            raw = path.read_bytes().replace(b"\r\n", b"\n")
            for newline in (b"\n", b"\r\n"):
                path.write_bytes(raw.replace(b"\n", newline))
                self.assertEqual(assets.check(root)["status"], "PASS")
            path.write_bytes(raw.replace('只是提醒。'.encode(), '只是提醒！'.encode()))
            with self.assertRaises(AssertionError):
                assets.check(root)

    def test_png_rejects_alpha_wrong_dimensions_and_missing_icc(self):
        import struct
        import zlib
        image = (ROOT / "store-assets/en/01-awareness.png").read_bytes()
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "fixture.png"
            for kind in ("alpha", "size", "icc"):
                altered = bytearray(image)
                if kind == "alpha":
                    altered[25] = 6
                elif kind == "size":
                    altered[16:20] = struct.pack(">I", 1)
                else:
                    offset = 8
                    while altered[offset+4:offset+8] != b"iCCP":
                        offset += 12+struct.unpack(">I", altered[offset:offset+4])[0]
                    length = 12+struct.unpack(">I", altered[offset:offset+4])[0]
                    del altered[offset:offset+length]
                altered[29:33] = struct.pack(">I", zlib.crc32(altered[12:29]) & 0xffffffff)
                path.write_bytes(altered)
                with self.subTest(kind=kind), self.assertRaises(AssertionError):
                    assets.png(path, (1320, 2868))

    def test_chinese_renderer_inherits_art_without_running_english_render(self):
        source = (ROOT / "store-assets/scripts/render_store_zh_hans.py").read_text(encoding="utf-8")
        for call in ("en.background()", "en.motif(", "en.phone("):
            self.assertIn(call, source)
        self.assertNotIn("en.render(", source)
        self.assertIn("finally:", source)
        self.assertIn("en.text = original", source)
        self.assertIn("assert check() == freeze_before", source)

    def test_chinese_export_accepts_only_four_safe_named_captures(self):
        import struct
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source, dest = root / "source", root / "dest"
            source.mkdir()
            dest.mkdir()
            summary = {"failedTests": 0, "passedTests": 1, "skippedTests": 0, "totalTestCount": 1}
            (dest / "test-summary.json").write_text(json.dumps(summary))
            manifest = []
            for name in assets.NAMES:
                (source / (name+".png")).write_bytes(b"\x89PNG\r\n\x1a\n"+b"\0"*8+struct.pack(">II", 1320, 2868))
                manifest.append({"name": "store-zh-hans-"+name, "exportedFileName": name+".png"})
            path = source / "manifest.json"
            path.write_text(json.dumps(manifest))
            with contextlib.redirect_stdout(io.StringIO()):
                exporter.export(source, dest)
            self.assertEqual(len(list(dest.glob("*.png"))), 4)
            for malformed in (manifest[:-1], manifest+[manifest[0]],
                              [{**manifest[0], "exportedFileName": "../private.png"}, *manifest[1:]]):
                path.write_text(json.dumps(malformed))
                with self.assertRaises(AssertionError):
                    exporter.export(source, dest)
            path.write_text(json.dumps(manifest))
            summary["skippedTests"] = 1
            (dest / "test-summary.json").write_text(json.dumps(summary))
            with self.assertRaises(AssertionError):
                exporter.export(source, dest)
