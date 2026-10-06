"""Deterministic English posters; never repaint pixels inside real app screens.

Run with installed Pillow/numpy and Windows Segoe UI, matching Lecture Asset's
tooling. No download, generated fake App state or in-phone marketing overlay.
"""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
SIZE = (1320, 2868)
BLUE, INK, MUTED = "#167DEA", "#162B46", "#60748C"
PHONE_RECT = (220, 840, 880, 1884)
SCREEN_RECT = (232, 852, 856, 1860)
RADIUS = 92
HEADLINE = {"origin": [104, 238], "size": 94, "line_height": 120}
SUBTITLE = {"origin": [108, 496], "size": 38}
STORY = [
    ("01-awareness", ["Feel time passing.", "Nothing else."], ""),
    ("02-choose-interval", ["Choose the apps.", "Pick the interval."], ""),
    ("03-reminder", ["A reminder.", "Not a restriction."], ""),
    ("04-today", ["See where the", "time went."], "Total · by hour · by app"),
]


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def background():
    # Compute at quarter resolution: smooth stationary blue glow, low memory.
    yy, xx = np.mgrid[0:717, 0:330]
    color = np.zeros((717, 330, 3), dtype=np.float32) + [247, 249, 253]
    for cx, cy, spread, strength in [(340, 340, 180, .42), (-30, 520, 160, .21)]:
        alpha = np.exp(-((xx-cx)**2+(yy-cy)**2)/(2*spread**2))*strength
        color = color*(1-alpha[:, :, None]) + np.array([216, 232, 255])*alpha[:, :, None]
    return Image.fromarray(color.clip(0, 255).astype(np.uint8)).resize(SIZE, Image.Resampling.BICUBIC).convert("RGBA")


def font(directory, size, bold=False):
    return ImageFont.truetype(str(directory / ("segoeuib.ttf" if bold else "segoeui.ttf")), size)


def text(image, xy, value, directory, records, size, fill=INK, bold=False):
    draw = ImageDraw.Draw(image)
    face = font(directory, size, bold)
    bounds = draw.textbbox(xy, value, font=face)
    assert 0 <= bounds[0] < bounds[2] <= SIZE[0]
    assert 0 <= bounds[1] < bounds[3] <= SIZE[1]
    records.append({"text": value, "bounds": list(bounds), "size": size,
                    "origin": list(xy), "bold": bold})
    draw.text(xy, value, fill=fill, font=face)


def motif(image, index, directory, records):
    """Small explicitly illustrative layers above the phone; no usage claims."""
    d = ImageDraw.Draw(image)
    if index == 0:
        # Clock hands, not a filled timer or countdown.
        d.ellipse((106, 594, 240, 728), outline=BLUE, width=5)
        d.line([(173, 614), (173, 661), (205, 680)], fill=BLUE, width=5, joint="curve")
        d.ellipse((166, 654, 180, 668), fill=BLUE)
        for x, radius in [(340, 7), (400, 9), (463, 11), (530, 13)]:
            d.ellipse((x-radius, 661-radius, x+radius, 661+radius), fill="#B0D3FC")
        d.line((574, 661, 1180, 661), fill="#D8E8FA", width=3)
    elif index == 1:
        for x in [108, 246, 384]:
            d.rounded_rectangle((x, 600, x+104, 704), radius=25, fill="white", outline="#CEDFF4", width=2)
            d.ellipse((x+26, 626, x+78, 678), fill="#E2EFFF")
            d.line([(x+39, 651), (x+49, 661), (x+67, 642)], fill=BLUE, width=4, joint="curve")
        d.line([(523, 652), (673, 652)], fill="#AFCFF5", width=4)
        d.polygon([(663, 642), (678, 652), (663, 662)], fill="#AFCFF5")
        d.rounded_rectangle((712, 600, 1198, 704), radius=52, fill="#E2EFFF")
        text(image, (746, 620), "5 · 10 · 15 · 30 · 60 min", directory, records, 34, BLUE, True)
    elif index == 2:
        # A neutral pulse mark outside the phone, not an iOS banner mockup.
        for radius in [26, 49, 73]:
            d.ellipse((177-radius, 662-radius, 177+radius, 662+radius), outline="#AFCFF5", width=3)
        d.ellipse((165, 650, 189, 674), fill=BLUE)
        d.line((306, 662, 1188, 662), fill="#C8DFF9", width=3)
        for x in [470, 770, 1070]:
            d.ellipse((x-9, 653, x+9, 671), fill=BLUE)
    else:
        # Abstract bars echo an hourly chart; no labels, numbers or sessions.
        for index, height in enumerate([36, 62, 93, 48, 114, 76, 132, 55]):
            x = 110 + index*63
            d.rounded_rectangle((x, 724-height, x+32, 724), radius=8, fill="#6FABF4")
        d.line((109, 736, 620, 736), fill="#C8DFF9", width=2)
        for x in [746, 850, 954]:
            d.rounded_rectangle((x, 639, x+70, 709), radius=20, fill="white", outline="#CEDFF4", width=2)
            d.ellipse((x+22, 661, x+48, 687), fill="#BCD9FC")


def phone(image, raw_path):
    x, y, width, height = PHONE_RECT
    sx, sy, sw, sh = SCREEN_RECT
    raw = Image.open(raw_path)
    assert raw.size == SIZE, raw.size
    assert sh == round(sw*raw.height/raw.width), "Non-uniform capture scaling"
    shadow = Image.new("RGBA", SIZE)
    ImageDraw.Draw(shadow).rounded_rectangle((x-4, y+20, x+width+4, y+height+20), radius=110, fill=(24, 47, 77, 42))
    image.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(28)))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((x, y, x+width-1, y+height-1), radius=104, fill="#243346")
    draw.rounded_rectangle((x+3, y+3, x+width-4, y+height-4), radius=101, outline="#61748A", width=2)
    screen = raw.convert("RGB").resize((sw, sh), Image.Resampling.LANCZOS).convert("RGBA")
    mask = Image.new("L", (sw, sh))
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw-1, sh-1), radius=RADIUS, fill=255)
    screen.putalpha(mask)
    # Native screen last: shadows and marketing decorations cannot tint it.
    image.alpha_composite(screen, (sx, sy))


def render(font_dir, icc_path):
    provenance = json.loads((ROOT / "captures/en/PROVENANCE.json").read_text(encoding="utf-8"))
    inventory = {item["file"]: item for item in json.loads((ROOT / "captures/en/CAPTURES.json").read_text())}
    icc = icc_path.read_bytes()
    results = []
    for index, (name, lines, subtitle) in enumerate(STORY):
        image = background()
        bounds = []
        icon_path = REPO / "App/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
        icon = Image.open(icon_path).convert("RGBA").resize((68, 68), Image.Resampling.LANCZOS)
        mask = Image.new("L", (68, 68))
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, 67, 67), radius=16, fill=255)
        icon.putalpha(mask)
        image.alpha_composite(icon, (108, 106))
        text(image, (198, 114), "Everwhile", font_dir, bounds, 38, MUTED, True)
        for line_index, line in enumerate(lines):
            text(image, (HEADLINE["origin"][0], HEADLINE["origin"][1]+line_index*HEADLINE["line_height"]),
                 line, font_dir, bounds, HEADLINE["size"], BLUE if line_index else INK, True)
        if subtitle:
            text(image, tuple(SUBTITLE["origin"]), subtitle, font_dir, bounds, SUBTITLE["size"], MUTED)
        motif(image, index, font_dir, bounds)
        capture = ROOT / "captures/en" / (name + ".png")
        assert sha(capture) == inventory[capture.name]["sha256"]
        phone(image, capture)
        output = ROOT / "en" / (name + ".png")
        output.parent.mkdir(parents=True, exist_ok=True)
        image.convert("RGB").save(output, icc_profile=icc, optimize=True)
        results.append({"file": output.relative_to(ROOT).as_posix(), "sha256": sha(output),
                        "raw": capture.relative_to(ROOT).as_posix(), "raw_sha256": sha(capture),
                        "source_sha": provenance["source_sha"], "capture_run": provenance["run_url"],
                        "source_description": provenance["sources"][name],
                        "pixels": list(SIZE), "mode": "RGB", "icc_sha256": sha(icc_path),
                        "phone_rect": list(PHONE_RECT), "screen_rect": list(SCREEN_RECT),
                        "screen_corner_radius": RADIUS, "phone_bottom_cropped": False,
                        "headline_lines": lines, "headline_style": HEADLINE, "subtitle": subtitle,
                        "subtitle_style": SUBTITLE, "external_text_bounds": bounds,
                        "in_phone_overlay": None, "outside_phone_illustration": True,
                        "transformation": "Uniform LANCZOS resize and rounded-corner mask only"})
    manifest = {"status": "DRAFT_WAITING_FOR_OWNER_VISUAL_REVIEW", "locale": "en",
                "reference_sha": "4995c1d0d70ebdf3712416bf96ee31219fc67720",
                "renderer_pillow_version": __import__("PIL").__version__,
                "fonts": [{"file": name, "sha256": sha(font_dir / name)} for name in ["segoeui.ttf", "segoeuib.ttf"]],
                "icon_sha256": sha(icon_path), "frames": results}
    (ROOT / "RENDER_MANIFEST_EN.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    sheet = Image.new("RGB", (1440, 782), "#F7F9FD")
    for index, record in enumerate(results):
        thumb = Image.open(ROOT / record["file"]).resize((360, 782), Image.Resampling.LANCZOS)
        sheet.paste(thumb, (index*360, 0))
    sheet.save(ROOT / "CONTACT_SHEET_EN.png", icc_profile=icc)
    print("Rendered four English draft PNGs and a 4-up contact sheet")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--font-dir", type=Path, default=Path("C:/Windows/Fonts"))
    parser.add_argument("--icc", type=Path, default=Path("C:/Windows/System32/spool/drivers/color/sRGB Color Space Profile.icm"))
    args = parser.parse_args()
    render(args.font_dir, args.icc)
