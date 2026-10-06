"""Independent output/provenance/pixel validation. Not App Store approval."""
import hashlib
import io
import json
from pathlib import Path
import argparse
import shutil
import subprocess
import tempfile

import numpy as np
from PIL import Image, ImageCms, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_NAMES = ["01-awareness", "02-choose-interval", "03-reminder", "04-today"]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(root=ROOT):
    manifest = json.loads((root / "RENDER_MANIFEST_EN.json").read_text())
    provenance = json.loads((root / "captures/en/PROVENANCE.json").read_text())
    inventory = json.loads((root / "captures/en/CAPTURES.json").read_text())
    assert [item["file"] for item in inventory] == [name+".png" for name in EXPECTED_NAMES]
    frames = manifest["frames"]
    assert len(frames) == 4
    assert [f["file"] for f in frames] == ["en/"+name+".png" for name in EXPECTED_NAMES]
    assert len(list((root / "en").glob("*.png"))) == 4
    assert provenance["private_state"] is False and provenance["screen_time_authorization_injected"] is False
    protected = list(provenance["production_trees"])
    for commit in [provenance["source_sha"], "HEAD"]:
        assert not subprocess.check_output(["git", "diff", provenance["frozen_runtime_sha"], commit, "--", *protected])
        for path, expected in provenance["production_trees"].items():
            assert subprocess.check_output(["git", "rev-parse", f"{commit}:{path}"], text=True).strip() == expected
    summary = json.loads((root / "captures/en/test-summary.json").read_text())
    assert summary["passedTests"] == 1 and summary["failedTests"] == summary["skippedTests"] == 0
    checks = []
    for record, raw_entry in zip(frames, inventory):
        for key in ["phone_rect", "screen_rect", "screen_corner_radius", "headline_style", "subtitle_style"]:
            assert record[key] == frames[0][key], f"Inconsistent {key}"
        path = root / record["file"]
        image = Image.open(path)
        assert image.format == "PNG" and image.size == (1320, 2868) and image.mode == "RGB"
        assert digest(path) == record["sha256"]
        profile = image.info["icc_profile"]
        assert "sRGB" in ImageCms.getProfileName(ImageCms.ImageCmsProfile(io.BytesIO(profile)))
        assert hashlib.sha256(profile).hexdigest() == record["icc_sha256"]
        raw_path = root / record["raw"]
        assert digest(raw_path) == record["raw_sha256"] == raw_entry["sha256"]
        assert record["source_sha"] == provenance["source_sha"] and record["capture_run"] == provenance["run_url"]
        assert record["in_phone_overlay"] is None
        px, py, pw, ph = record["phone_rect"]
        x, y, width, height = record["screen_rect"]
        assert 0 <= px < x and 0 <= py < y and px+pw <= image.width and py+ph <= image.height
        assert x+width < px+pw and y+height < py+ph
        raw = Image.open(raw_path).convert("RGB")
        assert raw.size == (1320, 2868) and height == round(width*raw.height/raw.width)
        expected = raw.resize((width, height), Image.Resampling.LANCZOS)
        mask = Image.new("L", (width, height))
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, width-1, height-1), radius=record["screen_corner_radius"], fill=255)
        opaque = np.asarray(mask) == 255
        actual = np.asarray(image)[y:y+height, x:x+width]
        changed = int(np.count_nonzero(np.any(actual != np.asarray(expected), axis=2) & opaque))
        assert changed == 0, f"Real phone pixels repainted: {changed}"
        for text in record["external_text_bounds"]:
            left, top, right, bottom = text["bounds"]
            assert 0 <= left < right <= 1320 and 0 <= top < bottom < py
        checks.append({"file": record["file"], "dimensions_rgb_srgb_hash": "PASS",
                       "raw_inventory_hash": "PASS", "visible_opaque_pixels": int(opaque.sum()),
                       "repainted_opaque_pixels": changed, "text_bounds": "PASS",
                       "common_geometry": "PASS", "private_data": "NONE_BY_CAPTURE_POLICY"})
    result = {"status": "PASS", "source_sha": provenance["source_sha"],
              "capture_run": provenance["run_url"], "production_runtime_unchanged": True,
              "frames": checks, "owner_visual_review": "NOT_RUN",
              "zh_Hans_final_assets": "NOT_RUN_ENGLISH_APPROVAL_REQUIRED",
              "app_store_upload_review_release": "NOT_RUN_NOT_AUTHORIZED"}
    (root / "IMAGE_VALIDATION_EN.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print("PASS: four opaque RGB/sRGB PNGs; fixed geometry; every opaque phone pixel intact")


def test_repaint_rejection():
    """Tamper only with a temporary copy, even update its hash: pixel guard must fail."""
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        shutil.copytree(ROOT / "en", root / "en")
        shutil.copytree(ROOT / "captures", root / "captures")
        manifest = json.loads((ROOT / "RENDER_MANIFEST_EN.json").read_text())
        frame = manifest["frames"][0]
        path = root / frame["file"]
        image = Image.open(path)
        profile = image.info["icc_profile"]
        x, y, _, _ = frame["screen_rect"]
        old = image.getpixel((x+200, y+500))
        image.putpixel((x+200, y+500), tuple(255-channel for channel in old))
        image.save(path, icc_profile=profile)
        frame["sha256"] = digest(path)
        (root / "RENDER_MANIFEST_EN.json").write_text(json.dumps(manifest), encoding="utf-8")
        try:
            validate(root)
        except AssertionError as error:
            assert str(error) == "Real phone pixels repainted: 1", error
        else:
            raise AssertionError("Pixel guard accepted a repaint")
    print("PASS: tampered temporary image rejected despite matching updated file hash")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    validate()
    if args.self_test:
        test_repaint_rejection()
