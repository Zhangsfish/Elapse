"""Independent Chinese pixel/provenance validation; never writes English files."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

import numpy as np
from PIL import Image, ImageCms, ImageDraw
from english_freeze import check

ROOT = Path(__file__).resolve().parents[1]
NAMES = ["01-awareness", "02-choose-interval", "03-reminder", "04-today"]
HEADLINES = [["感受时间流逝。", "仅此而已。"], ["选你想留意的 App。", "设定提醒间隔。"],
             ["只是提醒。", "不是限制。"], ["看看时间", "去了哪里。"]]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(root=ROOT):
    frozen = check(root)
    english = json.loads((root / "RENDER_MANIFEST_EN.json").read_text())
    manifest = json.loads((root / "RENDER_MANIFEST_ZH_HANS.json").read_text(encoding="utf-8"))
    provenance = json.loads((root / "captures/zh-Hans/PROVENANCE.json").read_text())
    inventory = json.loads((root / "captures/zh-Hans/CAPTURES.json").read_text())
    summary = json.loads((root / "captures/zh-Hans/test-summary.json").read_text())
    assert summary["passedTests"] == summary["totalTestCount"] == 1
    assert summary["failedTests"] == summary["skippedTests"] == 0
    assert provenance["configuration"] == "Release" and provenance["locale"] == "zh-Hans / zh_CN"
    assert provenance["private_state"] is provenance["screen_time_authorization_injected"] is False
    assert provenance["status_bar"] == "9:41 / Wi-Fi / full battery"
    en_provenance = json.loads((root / "captures/en/PROVENANCE.json").read_text())
    assert provenance["production_trees"] == en_provenance["production_trees"]
    for commit in (provenance["source_sha"], "HEAD"):
        for path, expected in provenance["production_trees"].items():
            actual = subprocess.check_output(["git", "rev-parse", f"{commit}:{path}"], text=True).strip()
            assert actual == expected, (commit, path)
    frames = manifest["frames"]
    assert manifest["locale"] == "zh-Hans" and len(frames) == len(inventory) == 4
    assert [p.name for p in sorted((root / "zh-Hans").glob("*.png"))] == [n+".png" for n in NAMES]
    assert [f["headline_lines"] for f in frames] == HEADLINES
    assert [f["subtitle"] for f in frames] == ["", "", "", "总量 · 每小时 · 各 App"]
    sheet = Image.open(root / "CONTACT_SHEET_ZH_HANS.png")
    assert sheet.size == (1440, 782) and sheet.mode == "RGB"
    checks = []
    for index, (record, en, raw_entry) in enumerate(zip(frames, english["frames"], inventory)):
        assert record["file"] == "zh-Hans/"+NAMES[index]+".png"
        for key in ("phone_rect", "screen_rect", "screen_corner_radius", "brand_style", "headline_style", "subtitle_style"):
            assert record[key] == en[key], f"Chinese geometry changed: {key}"
        assert record["in_phone_overlay"] is None
        path = root / record["file"]
        image = Image.open(path)
        assert image.format == "PNG" and image.size == (1320, 2868) and image.mode == "RGB"
        assert sha(path) == record["sha256"]
        profile = image.info["icc_profile"]
        assert "sRGB" in ImageCms.getProfileName(ImageCms.ImageCmsProfile(io.BytesIO(profile)))
        assert hashlib.sha256(profile).hexdigest() == record["icc_sha256"] == en["icc_sha256"]
        raw = root / record["raw"]
        assert raw_entry["file"] == NAMES[index]+".png"
        assert sha(raw) == record["raw_sha256"] == raw_entry["sha256"]
        assert record["source_sha"] == provenance["source_sha"] and record["capture_run"] == provenance["run_url"]
        x, y, w, h = record["screen_rect"]
        capture = Image.open(raw).convert("RGB")
        assert capture.size == (1320, 2868) and h == round(w*2868/1320)
        expected = np.asarray(capture.resize((w, h), Image.Resampling.LANCZOS))
        mask = Image.new("L", (w, h))
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, w-1, h-1), radius=record["screen_corner_radius"], fill=255)
        opaque = np.asarray(mask) == 255
        changed = int(np.count_nonzero(np.any(np.asarray(image)[y:y+h, x:x+w] != expected, axis=2) & opaque))
        assert changed == 0, f"Real phone pixels repainted: {changed}"
        for text in record["external_text_bounds"]:
            left, top, right, bottom = text["bounds"]
            assert 0 <= left < right <= 1320 and 0 <= top < bottom < record["phone_rect"][1]
            if "分钟" in text["text"]:
                assert record["interval_pill_rect"] == [614, 596, 1264, 708]
                assert 614 + 36 <= left < right <= 1264 - 36 and 596 <= top < bottom <= 708
                assert abs(left + right - (614 + 1264)) <= 1, "Chinese interval label not horizontally centered"
                assert abs(top + bottom - (596 + 708)) <= 1, "Chinese interval label not vertically centered"
        # Untranslated brand/background and illustrations retain exact English pixels.
        old = np.asarray(Image.open(root / en["file"]))
        actual = np.asarray(image)
        assert np.array_equal(actual[:210], old[:210])
        assert np.array_equal(actual[:, :75], old[:, :75])
        if index != 1:
            assert np.array_equal(actual[575:780], old[575:780])
        thumb = image.resize((360, 782), Image.Resampling.LANCZOS)
        assert np.array_equal(np.asarray(thumb), np.asarray(sheet)[:, index*360:(index+1)*360])
        checks.append({"file": record["file"], "sha256": sha(path), "status": "PASS",
                       "repainted_opaque_pixels": changed, "geometry_matches_english": True,
                       "raw_inventory": "PASS", "text_bounds": "PASS", "contact_sheet_tile": "PASS"})
    result = {"status": "PASS", "english_freeze": frozen,
              "manifest_sha256": sha(root / "RENDER_MANIFEST_ZH_HANS.json"),
              "manifest_lf_sha256": hashlib.sha256((root / "RENDER_MANIFEST_ZH_HANS.json").read_bytes().replace(b"\r\n", b"\n")).hexdigest(),
              "contact_sheet_sha256": sha(root / "CONTACT_SHEET_ZH_HANS.png"),
              "capture_source_sha": provenance["source_sha"], "capture_run": provenance["run_url"],
              "frames": checks, "private_state": False, "production_runtime_unchanged": True,
              "visual_review": "CODEX_CONTACT_SHEET_INSPECTION_REQUIRED_SEPARATE_FROM_CLOUD_AUDIT",
              "app_review_public_release": "NOT_RUN_NOT_AUTHORIZED"}
    (root / "IMAGE_VALIDATION_ZH_HANS.json").write_text(json.dumps(result, indent=2)+"\n", encoding="utf-8", newline="\n")
    print("PASS: Chinese pixels/geometry/profile/text/contact + frozen English")


def test_repaint_rejection():
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        for folder in ("zh-Hans", "en", "captures", "scripts"):
            shutil.copytree(ROOT / folder, root / folder)
        for name in ("ENGLISH_FREEZE.json", "RENDER_MANIFEST_EN.json", "IMAGE_VALIDATION_EN.json", "RENDER_MANIFEST_ZH_HANS.json", "CONTACT_SHEET_EN.png", "CONTACT_SHEET_ZH_HANS.png"):
            shutil.copyfile(ROOT / name, root / name)
        manifest = json.loads((root / "RENDER_MANIFEST_ZH_HANS.json").read_text(encoding="utf-8"))
        frame = manifest["frames"][0]
        path = root / frame["file"]
        image = Image.open(path)
        profile = image.info["icc_profile"]
        x, y, _, _ = frame["screen_rect"]
        image.putpixel((x+200, y+500), tuple(255-v for v in image.getpixel((x+200, y+500))))
        image.save(path, icc_profile=profile)
        frame["sha256"] = sha(path)
        (root / "RENDER_MANIFEST_ZH_HANS.json").write_text(json.dumps(manifest), encoding="utf-8")
        try:
            validate(root)
        except AssertionError as error:
            assert str(error) == "Real phone pixels repainted: 1", error
        else:
            raise AssertionError("Chinese pixel guard accepted repaint")
    print("PASS: Chinese one-pixel tamper rejected despite updated output hash")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    validate()
    if args.self_test:
        test_repaint_rejection()
