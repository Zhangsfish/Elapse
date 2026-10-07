"""Dependency-free CI checks for frozen EN and final Chinese PNG/evidence bytes."""
import hashlib
import json
from pathlib import Path
import struct
import zlib
from english_freeze import check as freeze_check

ROOT = Path(__file__).resolve().parents[1]
NAMES = ["01-awareness", "02-choose-interval", "03-reminder", "04-today"]
HEADLINES = [["感受时间流逝。", "仅此而已。"], ["选你想留意的 App。", "设定提醒间隔。"],
             ["只是提醒。", "不是限制。"], ["看看时间", "去了哪里。"]]


def centered_text_y(top, bottom, glyph_bounds):
    """Center visible glyph bounds, not a font baseline or line-box origin."""
    assert top < bottom and 0 < glyph_bounds[3] - glyph_bounds[1] <= bottom - top
    return round((top + bottom - glyph_bounds[1] - glyph_bounds[3]) / 2)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def png(path, dimensions, expected_icc=None):
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", "Not PNG"
    width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", data[16:29])
    assert (width, height) == dimensions and depth == 8 and color == 2, "Not opaque RGB at expected size"
    offset, icc, ended = 8, None, False
    while offset < len(data):
        length = struct.unpack(">I", data[offset:offset+4])[0]
        kind = data[offset+4:offset+8]
        payload = data[offset+8:offset+8+length]
        crc = struct.unpack(">I", data[offset+8+length:offset+12+length])[0]
        assert zlib.crc32(kind+payload) & 0xffffffff == crc, "PNG CRC mismatch"
        assert kind != b"tRNS", "PNG transparency"
        if kind == b"iCCP":
            _, compressed = payload.split(b"\0", 1)
            assert compressed[0] == 0
            icc = zlib.decompress(compressed[1:])
        if kind == b"IEND":
            ended = True
        offset += 12+length
    assert ended and offset == len(data) and icc and icc[36:40] == b"acsp"
    actual_icc = hashlib.sha256(icc).hexdigest()
    if expected_icc:
        assert actual_icc == expected_icc, "ICC differs from frozen English"
    return actual_icc


def check(root=ROOT, require_chinese=True):
    frozen = freeze_check(root)
    path = root / "RENDER_MANIFEST_ZH_HANS.json"
    if not path.exists() and not require_chinese:
        return {"english_freeze": "PASS", "zh_Hans": "NOT_RUN_CAPTURE_PENDING"}
    manifest = json.loads(path.read_text(encoding="utf-8"))
    en = json.loads((root / "RENDER_MANIFEST_EN.json").read_text())
    proof = json.loads((root / "IMAGE_VALIDATION_ZH_HANS.json").read_text())
    inventory = json.loads((root / "captures/zh-Hans/CAPTURES.json").read_text())
    provenance = json.loads((root / "captures/zh-Hans/PROVENANCE.json").read_text())
    summary = json.loads((root / "captures/zh-Hans/test-summary.json").read_text())
    assert summary["passedTests"] == summary["totalTestCount"] == 1
    assert summary["failedTests"] == summary["skippedTests"] == 0
    assert provenance["private_state"] is provenance["screen_time_authorization_injected"] is False
    assert provenance["configuration"] == "Release" and provenance["locale"] == "zh-Hans / zh_CN"
    assert provenance["production_trees"] == json.loads((root / "captures/en/PROVENANCE.json").read_text())["production_trees"]
    assert manifest["english_reference_head"] == frozen["approved_reference_head"]
    assert manifest["locale"] == "zh-Hans" and len(manifest["frames"]) == len(inventory) == 4
    assert sorted(p.name for p in (root / "zh-Hans").glob("*.png")) == [n+".png" for n in NAMES]
    assert [f["headline_lines"] for f in manifest["frames"]] == HEADLINES
    assert [f["subtitle"] for f in manifest["frames"]] == ["", "", "", "总量 · 每小时 · 各 App"]
    manifest_lf_sha = hashlib.sha256(path.read_bytes().replace(b"\r\n", b"\n")).hexdigest()
    assert proof["status"] == "PASS" and proof["manifest_lf_sha256"] == manifest_lf_sha, "Stale pixel evidence"
    assert proof["capture_source_sha"] == provenance["source_sha"]
    assert proof["capture_run"] == provenance["run_url"]
    for index, (frame, english, raw) in enumerate(zip(manifest["frames"], en["frames"], inventory)):
        assert frame["file"] == "zh-Hans/"+NAMES[index]+".png"
        assert frame["raw"] == "captures/zh-Hans/"+NAMES[index]+".png"
        assert raw["file"] == NAMES[index]+".png"
        assert frame["source_sha"] == provenance["source_sha"] and frame["capture_run"] == provenance["run_url"]
        for key in ("phone_rect", "screen_rect", "screen_corner_radius", "brand_style", "headline_style", "subtitle_style"):
            assert frame[key] == english[key], "Chinese geometry mismatch: " + key
        assert frame["in_phone_overlay"] is None
        assert sha(root / frame["file"]) == frame["sha256"]
        assert sha(root / frame["raw"]) == frame["raw_sha256"] == raw["sha256"]
        assert frame["raw_sha256"] != english["raw_sha256"], "English capture reused as Chinese"
        png(root / frame["file"], (1320, 2868), english["icc_sha256"])
        for text in frame["external_text_bounds"]:
            l, t, r, b = text["bounds"]
            assert 0 <= l < r <= 1320 and 0 <= t < b < frame["phone_rect"][1], "Text clipped"
            if index == 1 and "分钟" in text["text"]:
                assert frame["interval_pill_rect"] == [614, 596, 1264, 708]
                assert 614 + 36 <= l < r <= 1264 - 36 and 596 <= t < b <= 708
                assert abs(l + r - (614 + 1264)) <= 1, "Chinese interval label not horizontally centered"
                assert abs(t + b - (596 + 708)) <= 1, "Chinese interval label not vertically centered"
        receipt = proof["frames"][index]
        assert receipt["sha256"] == frame["sha256"] and receipt["repainted_opaque_pixels"] == 0
        assert receipt["geometry_matches_english"] and receipt["contact_sheet_tile"] == "PASS"
    assert len(proof["frames"]) == 4
    png(root / "CONTACT_SHEET_ZH_HANS.png", (1440, 782), en["frames"][0]["icc_sha256"])
    assert sha(root / "CONTACT_SHEET_ZH_HANS.png") == proof["contact_sheet_sha256"]
    fonts = manifest["fonts"]
    assert fonts[0]["file"] == "NotoSansSC-VF.ttf" and fonts[0]["face_index"] == 0
    assert fonts[0]["sha256"] == "763146584cf0710223441356b4395e279021b0806c196614377a7a0174ae074a"
    assert fonts[0]["axes"] == {"regular_weight": 400, "bold_weight": 700}
    assert not list(root.rglob("*.ttf")) and not list(root.rglob("*.ttc")), "Font files must not be committed"
    return {"status": "PASS", "english_freeze": "PASS", "zh_Hans": "PASS_4_RGB_SRGB_HASH_GEOMETRY",
            "pixel_proof": "LOCAL_INDEPENDENT_VALIDATOR_BOUND_TO_EXACT_OUTPUT_HASHES",
            "capture_source_sha": provenance["source_sha"], "private_state": False}


if __name__ == "__main__":
    print(json.dumps(check(), indent=2))
