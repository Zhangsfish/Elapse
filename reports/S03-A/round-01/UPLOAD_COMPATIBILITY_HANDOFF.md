# Screenshot upload handoff — size and interval centering

2026-10-07. Narrow owner-authorized side-conversation change/record only.
No product implementation, shared renderer edit, merge, stage unlock,
ASC automation or new TestFlight. Owner subsequently authorized committing/pushing
this documentation to the existing branch so other Codex/audit readers see the
actual upload error and corrections. Current task dispatch still comes from STATUS.

## What happened

The frozen English master `01-awareness.png` is 1320×2868. Owner's actual ASC
uploader rejected it as invalid size. Its visible medium-display iPhone slot
lists 1179×2556 / 1206×2622 portrait screenshots. The suggested large-display
option was not available. Lecture Asset's marketing/release evidence also uses
1320×2868; reuse its production technique, not an assumed destination slot.

**Final deliverables for this lane need 1206×2622 upload copies in both locales.**
Keep approved 1320×2868 masters and English freeze/contact files intact.

Owner also requested English Frame2's `5 · 10 · 15 · 30 · 60 min` be centered
in both axes within the existing pill. Only that outside-phone text changed in
the local variant. Chinese must use equivalent visible-ink centering, preserving
its approved wider pill and all other geometry/copy/captures.

## Local files — already generated, ignored / not committed

Task directory: `E:/Elapse/.build/app-store-upload/iphone-medium/`

- `export_upload.py`: four size-only English derivative exports / validation.
- `en/01-awareness.png`, `en/03-reminder.png`, `en/04-today.png`: final-size copies.
- `en/02-choose-interval.png`: size-only copy; **superseded for upload by centered version**.
- `center_interval.py`: uses native renderer in memory, centers label by glyph ink.
- `centered/02-choose-interval.png`: use this as the second upload image.
- `EXPORT_VALIDATION.json`, `centered/VALIDATION.json`: local executed check results.

These paths are local outputs, not portable repo inputs. A future Codex must
implement/reproduce an auditable bilingual upload export in the appropriate asset
lane; do not depend on ignored files being present in another checkout.

Final English local upload file hashes (SHA256):

| Frame | SHA256 |
|---|---|
| 01 | `6f324940e136e08a353e6e8114e0b3426802b5d132e3328ede12cc5c9a4eff07` |
| 02 centered | `74c3bb1f4242bfc6a7eddcad49f35e7946e304a01d927381f83f604bcff91267` |
| 03 | `a9df8787050a3dc4346873245b329e491d7c452e267420ed9899070f831e5232` |
| 04 | `5bb7d0dbe9df4f5ba3aef21749697e2becca77dd17ad4dc9f98146b1b84b8295` |

## Actual local checks

Existing environment: `C:/conda_envs/myenv/python.exe`, Pillow11.1.0; no installation.

```powershell
& 'C:/conda_envs/myenv/python.exe' .build/app-store-upload/iphone-medium/export_upload.py
& 'C:/conda_envs/myenv/python.exe' .build/app-store-upload/iphone-medium/center_interval.py
```

Both completed exit0. All four English copies: 1206×2622 RGB, preserved sRGB ICC,
no alpha, deterministic encoding. Uniform LANCZOS resize to 1206×2620 plus one
duplicated outer edge row top/bottom. No crop/stretch/repaint of real phone UI.
English freeze check passed before/after.

Centered native Frame2 reconstruction first matched the master pixel-for-pixel.
Pill rect `[614,596,1214,708]`; centered visible ink `[684,635,1145,668]`.
Center rounding ≤0.5px each axis. Actual changed-pixel bounds `[649,626,1143,668]`
are entirely inside the pill; every pixel outside it remains identical at master
resolution. The upload transform is then applied consistently. Codex visually
inspected the result; this is not owner acceptance or cloud review.

## Requirements for the Chinese / final-upload Codex

1. Read docs/S03_SCREENSHOT_PRODUCTION.md “Actual upload gate”. Reconfirm the
   real upload slot, not an assumed device-name tab. Current target: 1206×2622.
2. Preserve masters/raw/freeze/contact hashes. Render derivatives in a separate
   upload folder; do not run a rewriting English master renderer.
3. For Chinese interval label use its pinned font's actual textbbox at `(0,0)`.
   Center visible ink in `[614,596,1264,708]` with the documented formula, not
   English baseline values. Retain approved Chinese width and padding.
4. Export exactly four zh-Hans PNGs using the same uniform-resize/edge-padding
   rule. Pin source/output/ICC hashes and actual target dimensions in a manifest.
5. Validate RGB/sRGB/no alpha, exact dimensions, no clipping, deterministic repeat,
   preserved real phone pixels and frozen English masters/contact. Review a new
   upload-size Chinese contact sheet, including thumbnail text legibility.
6. Ensure final English upload inventory points to the **centered** Frame2, not
   the superseded size-only copy. Keep four images in the original order.
7. Separate master validation, local export validation, owner visual acceptance,
   actual ASC acceptance and head-bound CI. Never inherit an old PASS for new
   derivatives. Record unresolved items honestly before release.

## Remaining evidence

- Chinese final-size derivatives / upload contact sheet: **NOT_RUN** in this side task.
- Latest centered English variant owner visual acceptance: **NOT_OBSERVED**.
- Actual ASC acceptance of corrected English/Chinese files: **NOT_OBSERVED**.
- New head CI: **NOT_RUN** here; prior CI does not cover a future export implementation.
- No App Review submission / public release / S03-B unlock authorized by this record.
