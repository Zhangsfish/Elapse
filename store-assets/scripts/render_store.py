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
PHONE_RECT = (202, 803, 916, 1958)
SCREEN_RECT = (215, 815, 890, 1934)
RADIUS = 96
PHONE_RADIUS = 108
BRAND = {"icon_rect": [108, 106, 76, 76], "origin": [208, 112],
         "size": 42, "color": "#536A84"}
INTERVAL_MOTIF_SIZE = 44
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
        for x in [108, 254, 400]:
            d.rounded_rectangle((x, 596, x+112, 708), radius=27, fill="white", outline="#BDD8FA", width=3)
            d.ellipse((x+27, 623, x+85, 681), fill="#DFEDFF")
            d.line([(x+40, 651), (x+52, 664), (x+74, 641)], fill=BLUE, width=5, joint="curve")
        d.line([(536, 652), (592, 652)], fill="#6FABF4", width=5)
        d.polygon([(580, 640), (597, 652), (580, 664)], fill="#6FABF4")
        d.rounded_rectangle((614, 596, 1214, 708), radius=56, fill="#DCEBFF")
        text(image, (646, 611), "5 · 10 · 15 · 30 · 60 min", directory, records,
             INTERVAL_MOTIF_SIZE, BLUE, True)
    elif index == 2:
        # Generic app group -> accumulating segments -> a quiet bell/pulse.
        # Marketing illustration only: no duration claim or OS banner mockup.
        d.rounded_rectangle((108, 609, 194, 695), radius=22, fill="#E2EFFF", outline="#BDD8FA", width=3)
        d.rounded_rectangle((166, 625, 252, 711), radius=22, fill="white", outline="#9AC4F8", width=3)
        d.rounded_rectangle((187, 646, 231, 690), radius=12, fill="#DCEBFF")
        d.line((282, 661, 935, 661), fill="#D4E5FA", width=3)
        for x, color in [(346, "#BAD7FB"), (490, "#8FBEF7"), (634, "#6FABF4")]:
            d.rounded_rectangle((x, 648, x+120, 674), radius=13, fill=color)
        d.line((794, 661, 935, 661), fill="#8FBEF7", width=4)
        d.polygon([(925, 651), (940, 661), (925, 671)], fill="#8FBEF7")
        for radius in [55, 73]:
            d.ellipse((1056-radius, 658-radius, 1056+radius, 658+radius), outline="#C5DDFA", width=3)
        d.arc((1030, 628, 1082, 680), 180, 360, fill=BLUE, width=4)
        d.line([(1030, 654), (1030, 675), (1023, 688), (1089, 688), (1082, 675), (1082, 654)],
               fill=BLUE, width=4, joint="curve")
        d.arc((1049, 685, 1063, 699), 0, 180, fill=BLUE, width=4)
        d.ellipse((1053, 617, 1059, 623), fill=BLUE)
    else:
        # Very faint echo, subordinate to the genuine tutorial's Today chart.
        for index, height in enumerate([36, 62, 93, 48, 114, 76, 132, 55]):
            x = 110 + index*63
            d.rounded_rectangle((x, 724-round(height*.5), x+24, 724), radius=6, fill="#CADFF9")
        d.line((109, 736, 620, 736), fill="#DDEAFB", width=2)
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
    ImageDraw.Draw(shadow).rounded_rectangle((x-4, y+20, x+width+4, y+height+20), radius=PHONE_RADIUS+6, fill=(24, 47, 77, 42))
    image.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(28)))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((x, y, x+width-1, y+height-1), radius=PHONE_RADIUS, fill="#243346")
    draw.rounded_rectangle((x+3, y+3, x+width-4, y+height-4), radius=PHONE_RADIUS-3, outline="#61748A", width=2)
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
        ix, iy, iw, ih = BRAND["icon_rect"]
        icon = Image.open(icon_path).convert("RGBA").resize((iw, ih), Image.Resampling.LANCZOS)
        mask = Image.new("L", (iw, ih))
        ImageDraw.Draw(mask).rounded_rectangle((0, 0, iw-1, ih-1), radius=18, fill=255)
        icon.putalpha(mask)
        image.alpha_composite(icon, (ix, iy))
        text(image, tuple(BRAND["origin"]), "Everwhile", font_dir, bounds, BRAND["size"], BRAND["color"], True)
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
                        "brand_style": BRAND,
                        "headline_lines": lines, "headline_style": HEADLINE, "subtitle": subtitle,
                        "subtitle_style": SUBTITLE, "external_text_bounds": bounds,
                        "in_phone_overlay": None, "outside_phone_illustration": True,
                        "transformation": "Uniform LANCZOS resize and rounded-corner mask only"})
    manifest = {"status": "DRAFT_WAITING_FOR_OWNER_VISUAL_REVIEW", "locale": "en", "polish_revision": 2,
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
