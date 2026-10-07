"""Chinese-only output; import frozen English art/geometry, never invoke its render."""
import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
import render_store as en
from english_freeze import check
from bilingual_asset_checks import centered_text_y

ROOT = en.ROOT
FONT_FILE = "NotoSansSC-VF.ttf"
FONT_SHA = "763146584cf0710223441356b4395e279021b0806c196614377a7a0174ae074a"
STORY = [
    ("01-awareness", ["感受时间流逝。", "仅此而已。"], ""),
    ("02-choose-interval", ["选你想留意的 App。", "设定提醒间隔。"], ""),
    ("03-reminder", ["只是提醒。", "不是限制。"], ""),
    ("04-today", ["看看时间", "去了哪里。"], "总量 · 每小时 · 各 App"),
]


def font(directory, size, bold=False):
    face = ImageFont.truetype(str(directory / FONT_FILE), size, index=0)
    face.set_variation_by_axes([700 if bold else 400])
    return face


def text(image, xy, value, directory, records, size, fill=en.INK, bold=False):
    face = font(directory, size, bold)
    draw = ImageDraw.Draw(image)
    bounds = draw.textbbox(xy, value, font=face)
    assert 0 <= bounds[0] < bounds[2] <= en.SIZE[0], (value, bounds)
    assert 0 <= bounds[1] < bounds[3] < en.PHONE_RECT[1], (value, bounds)
    records.append({"text": value, "bounds": list(bounds), "size": size,
                    "origin": list(xy), "bold": bold, "weight": 700 if bold else 400})
    draw.text(xy, value, fill=fill, font=face)


def motif(image, index, directory, records):
    # One local text callback translates ONLY the outside-phone interval label.
    # All shapes/coordinates/colors still execute the frozen English helper.
    original = en.text

    def translated(*args, **kwargs):
        args = list(args)
        assert args[2] == "5 · 10 · 15 · 30 · 60 min"
        args[2] = "5 · 10 · 15 · 30 · 60 分钟"
        args[5] = 42
        face = font(directory, 42, kwargs.get("bold", args[7] if len(args) > 7 else False))
        glyph_bounds = ImageDraw.Draw(image).textbbox((0, 0), args[2], font=face)
        args[1] = (632, centered_text_y(596, 708, glyph_bounds))
        return text(*args, **kwargs)

    en.text = translated
    try:
        en.motif(image, index, directory, records)
    finally:
        en.text = original


def render(font_dir, icc_path):
    freeze_before = check()
    assert en.sha(font_dir / FONT_FILE) == FONT_SHA, "Chinese font file changed"
    provenance = json.loads((ROOT / "captures/zh-Hans/PROVENANCE.json").read_text(encoding="utf-8"))
    assert provenance["configuration"] == "Release" and provenance["locale"] == "zh-Hans / zh_CN"
    inventory = {f["file"]: f for f in json.loads((ROOT / "captures/zh-Hans/CAPTURES.json").read_text())}
    icc = icc_path.read_bytes()
    english = json.loads((ROOT / "RENDER_MANIFEST_EN.json").read_text())
    for record in english["fonts"]:
        assert en.sha(font_dir / record["file"]) == record["sha256"], "Brand font file changed"
    results = []
    for index, (name, lines, subtitle) in enumerate(STORY):
        image, bounds = en.background(), []
        icon_path = en.REPO / "App/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
        ix, iy, iw, ih = en.BRAND["icon_rect"]
        icon = Image.open(icon_path).convert("RGBA").resize((iw, ih), Image.Resampling.LANCZOS)
        mask = Image.new("L", (iw, ih))
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, iw-1, ih-1), radius=18, fill=255)
        icon.putalpha(mask)
        image.alpha_composite(icon, (ix, iy))
        en.text(image, tuple(en.BRAND["origin"]), "Everwhile", font_dir, bounds,
                en.BRAND["size"], en.BRAND["color"], True)
        for row, line in enumerate(lines):
            text(image, (en.HEADLINE["origin"][0], en.HEADLINE["origin"][1]+row*en.HEADLINE["line_height"]),
                 line, font_dir, bounds, en.HEADLINE["size"], en.BLUE if row else en.INK, True)
        if subtitle:
            text(image, tuple(en.SUBTITLE["origin"]), subtitle, font_dir, bounds, en.SUBTITLE["size"], en.MUTED)
        motif(image, index, font_dir, bounds)
        capture = ROOT / "captures/zh-Hans" / (name + ".png")
        assert en.sha(capture) == inventory[capture.name]["sha256"]
        en.phone(image, capture)
        output = ROOT / "zh-Hans" / (name + ".png")
        output.parent.mkdir(parents=True, exist_ok=True)
        image.convert("RGB").save(output, icc_profile=icc, optimize=True)
        record = dict(english["frames"][index])
        record.update(file=output.relative_to(ROOT).as_posix(), sha256=en.sha(output),
                      raw=capture.relative_to(ROOT).as_posix(), raw_sha256=en.sha(capture),
                      source_sha=provenance["source_sha"], capture_run=provenance["run_url"],
                      source_description=provenance["sources"][name], headline_lines=lines,
                      subtitle=subtitle, external_text_bounds=bounds, icc_sha256=en.sha(icc_path))
        results.append(record)
    manifest = {"status": "FINAL_FREEZE_PENDING_INDEPENDENT_AUDIT", "locale": "zh-Hans",
                "english_reference_head": freeze_before["approved_reference_head"], "polish_revision": 2,
                "text_only_adaptation": "Interval label 42px at x=632; visible glyph bounds vertically centered in unchanged pill y=596..708. Headlines 94px.",
                "renderer_pillow_version": __import__("PIL").__version__,
                "fonts": [{"file": FONT_FILE, "family": "Noto Sans SC", "face_index": 0,
                           "sha256": FONT_SHA, "axes": {"regular_weight": 400, "bold_weight": 700}},
                          *english["fonts"]], "frames": results}
    (ROOT / "RENDER_MANIFEST_ZH_HANS.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False)+"\n", encoding="utf-8", newline="\n")
    sheet = Image.new("RGB", (1440, 782), "#F7F9FD")
    for index, record in enumerate(results):
        sheet.paste(Image.open(ROOT / record["file"]).resize((360, 782), Image.Resampling.LANCZOS), (index*360, 0))
    sheet.save(ROOT / "CONTACT_SHEET_ZH_HANS.png", icc_profile=icc)
    assert check() == freeze_before
    print("PASS: four Chinese Store PNGs/contact rendered; frozen English untouched")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--font-dir", type=Path, default=Path("C:/Windows/Fonts"))
    parser.add_argument("--icc", type=Path, default=Path("C:/Windows/System32/spool/drivers/color/sRGB Color Space Profile.icm"))
    args = parser.parse_args()
    render(args.font_dir, args.icc)
