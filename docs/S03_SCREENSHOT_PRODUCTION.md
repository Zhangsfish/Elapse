# S03 screenshot production — Everwhile App Store carousel

Updated: 2026-10-07
Status: S03-A production direction.

## Reference implementation

Use Lecture Asset's final App Store screenshot pipeline as the execution model, not merely as visual inspiration.

Read these exact files from `Zhangsfish/lecture-asset@4995c1d0d70ebdf3712416bf96ee31219fc67720` before implementing:

- `.github/workflows/s05-store-screenshots.yml`
- `.github/workflows/s05-store-screenshots-zh-hans.yml`
- `UITests/S05StoreScreenshotsUITests.swift`
- `UITests/S05ChineseStoreScreenshotsUITests.swift`
- `reports/S05/store-screenshots-01/SCREENSHOT_STORYBOARD.md`
- `reports/S05/store-screenshots-01/scripts/export_captures.py`
- `reports/S05/store-screenshots-01/scripts/export_captures_zh_hans.py`
- `reports/S05/store-screenshots-01/scripts/render_store.py`
- `reports/S05/store-screenshots-01/scripts/render_store_zh_hans.py`
- `reports/S05/store-screenshots-01/scripts/validate_store.py`
- `reports/S05/store-screenshots-01/scripts/validate_store_zh_hans.py`
- `reports/S05/store-screenshots-01/CONTACT_SHEET.png`
- `reports/S05/store-screenshots-01/CONTACT_SHEET_ZH_HANS.png`

The useful pattern to reproduce:

1. capture real Release UI on a fresh simulator;
2. use synthetic/non-private state;
3. preserve raw captures separately;
4. compose Store marketing frames deterministically;
5. keep a fixed visual system and phone geometry;
6. freeze English geometry before Chinese;
7. render a contact sheet;
8. validate dimensions/color/profile/text bounds/provenance;
9. explicitly distinguish real UI from illustrative marketing layers.

## Everwhile visual direction

Do not make plain screenshots with captions.

Each final frame is a designed App Store poster:
- design master canvas: 1320 × 2868, RGB, sRGB, no alpha;
- subtle cool off-white / blue-tinted background;
- small Everwhile app-icon + name brand line near top;
- large 1–2 line headline;
- optional single short subline only when it adds meaning;
- one consistent iPhone frame position/scale across the carousel;
- real app capture inside the phone must not be recolored or repainted;
- outside-phone illustrations may use Everwhile's existing blue visual language and tutorial artwork vocabulary;
- restrained shadow/glow; no launch-event/presentation aesthetic;
- no tiny paragraphs.

The carousel should read coherently when viewed as a 4-up strip.

## Storyboard — first draft

The exact copy can be tightened after seeing the first contact sheet.

### Frame 1 — awareness, not control

English headline:
**Feel time passing.**
**Nothing else.**

Chinese:
**感受时间流逝。**
**仅此而已。**

Visual:
- real Everwhile home screen or the cleanest truthful Release state available;
- product state should look calm, not like setup/debug UI;
- if the simulator cannot truthfully reproduce a configured live state, do not fake tokens/usage inside the App UI. Use a truthful home state plus outside-phone brand composition.

### Frame 2 — choose what matters

English:
**Choose the apps.**
**Pick the interval.**

Chinese:
**选你想留意的 App。**
**设定提醒间隔。**

Visual:
- use actual in-app Quick Start scene / real FamilyActivityPicker only if it can be captured truthfully on simulator;
- otherwise use the real in-app tutorial scene as the phone capture, not a fake picker screenshot;
- outside-phone decorative shapes may reinforce “many apps → one shared pool”.

### Frame 3 — neutral reminder

English:
**A reminder.**
**Not a restriction.**

Chinese:
**只是提醒。**
**不是限制。**

Visual:
- real in-app reminder tutorial scene is acceptable and preferable to fabricating an iOS notification;
- if an illustrative notification appears, it must be clearly derived from the app's real tutorial/example and must not imply blocking;
- no Shield, lock, red warning, productivity score or guilt language.

### Frame 4 — Today

English:
**See where the time went.**

Chinese:
**看看时间去了哪里。**

Optional subline:
English: **Total · by hour · by app**
Chinese: **总量 · 每小时 · 各 App**

Visual:
- prefer a truthful sanitized Today capture if one can be generated without private app identities/usage;
- otherwise use the real in-app tutorial Today scene and make that provenance explicit in the manifest;
- never fabricate exact sessions;
- never publish the owner's real App names or usage.

## Capture policy

### Fresh simulator

Match Lecture Asset:
- create/use a clean iPhone 17 Pro Max simulator;
- Release configuration;
- fixed language/locale;
- fixed status bar time 9:41;
- Wi-Fi active, full battery;
- deterministic first-visit state.

English:
- AppleLanguages = en
- AppleLocale = en_US

Chinese:
- AppleLanguages = zh-Hans
- AppleLocale = zh_CN

### No private state

Do not use:
- owner screenshots containing app identities;
- owner Screen Time totals;
- real Family Activity tokens;
- real notification history.

If a state cannot be truthfully produced in a clean simulator, choose a truthful tutorial/sample state instead of injecting fake data into the production app.

### Raw capture integrity

Save raw captures separately under:
- `store-assets/captures/en/`
- `store-assets/captures/zh-Hans/`

Final renderer may uniformly resize/mask the raw capture to fit the phone frame.

It may **not**:
- repaint text inside the real app capture;
- substitute fake app names inside the real UI;
- alter charts/numbers;
- recolor only parts of the real screen.

Any illustrative system/marketing layer must be separately documented and preferably placed outside the phone.

## Two-pass owner gate

Do not create the final bilingual set in one blind pass.

### Pass 1 — storyboard + English

Deliver:
- `store-assets/SCREENSHOT_STORYBOARD.md`;
- 4 English final draft PNGs;
- `store-assets/CONTACT_SHEET_EN.png`;
- raw captures;
- render manifest;
- validation report.

Then stop for owner visual review.

The owner judges:
- headline strength;
- overall visual finish;
- phone scale/crop;
- whether the four frames tell one story;
- whether it feels as polished as Lecture Asset.

Do **not** freeze Chinese before this review.

### Pass 2 — zh-Hans + final freeze

Only after English direction is accepted:
- create Chinese captures;
- preserve the exact same canvas, phone rect, headline origin, visual helper functions and carousel sequence;
- adapt copy naturally for Chinese; do not force literal line breaks from English;
- create `CONTACT_SHEET_ZH_HANS.png`;
- rerun validators;
- freeze English bytes except for explicitly owner-approved changes.

## Deterministic renderer

Use a local deterministic renderer (Python + Pillow/numpy is acceptable, matching Lecture Asset).

Create something equivalent to:
- `store-assets/scripts/render_store.py`
- `store-assets/scripts/render_store_zh_hans.py`
- `store-assets/scripts/validate_store.py`
- `store-assets/scripts/validate_store_zh_hans.py`

Record:
- source commit;
- raw capture SHA256;
- final PNG SHA256;
- canvas size;
- phone rect;
- screen rect;
- headline text/style/origin;
- locale;
- whether any layer is illustrative.

Generate a 4-frame contact sheet as a review artifact, not an App Store asset.

## Validation gates

Automated validation should fail if:
- count is not exactly 4 per locale;
- design master PNG is not 1320×2868 RGB (upload derivatives have their own exact-size gate below);
- alpha exists;
- sRGB/ICC is missing;
- headline/subtitle leaves the canvas;
- phone geometry differs across frames;
- Chinese geometry differs from frozen English geometry without explicit exception;
- raw capture hash does not match capture inventory;
- renderer modifies pixels inside a real capture outside an explicitly declared illustrative overlay;
- English frozen output changes during Chinese-only work;
- private/real app identifiers appear in public fixtures/manifests.

## Actual upload gate — owner correction on 2026-10-07

**A validated design master is not yet an upload-compatible deliverable.**
The owner attempted to upload `01-awareness.png` at 1320×2868 and App Store
Connect rejected it as an invalid file size. The actual visible slot was
“带灵动岛的 iPhone（中等显示屏）”; its displayed portrait sizes were 1179×2556
and 1206×2622. The suggested large-display option was not available to the owner.
Lecture Asset also used 1320×2868; that historical size is not proof this slot accepts it.

For this owner's current upload lane, **deliver exactly 1206×2622** for both
English and zh-Hans. Recheck the actual destination slot before a future upload;
do not promise that an unseen large-display tab exists. Keep the approved
1320×2868 masters, raw captures, frozen hashes and contact sheets unchanged.
Make separately named/upload-folder derivatives, not replacements for the masters.

### Frame 2 interval-label alignment

The owner explicitly requested the English `5 · 10 · 15 · 30 · 60 min` be centered
both horizontally and vertically inside its existing pill. Apply the same requirement
to Chinese `5 · 10 · 15 · 30 · 60 分钟` using that locale's actual font metrics.
Do not copy English baseline offsets or change the entire visual system.

For glyph bounds `(gl, gt, gr, gb)` measured at `(0, 0)` and pill bounds
`(left, top, right, bottom)`, place the text at:

```text
x = round((left + right - gl - gr) / 2)
y = round((top + bottom - gt - gb) / 2)
```

Verify visible-ink center error ≤0.5 design pixel in each direction, adequate
side padding, no clipping and acceptable thumbnail readability. Keep headline,
brand, phone geometry and real capture pixels unchanged. The Chinese master
already has an owner-approved wider pill `[614,596,1264,708]`; retain it and do
not force the English width `[614,596,1214,708]` onto Chinese.

### Upload derivative validation

The local export used uniform LANCZOS resize from 1320×2868 to 1206×2620,
then duplicated one outer edge row at the top and bottom for exact 1206×2622.
This avoids anisotropic stretching/cropping; it is an export transform, not a
phone repaint. Use the same transform across all four frames and both locales.

Validate each locale's four upload PNGs separately: exact dimensions, RGB,
sRGB ICC, no alpha, deterministic rerender, source/output SHA256, unchanged
master/freeze/contact hashes and preserved phone content. Generate an
upload-size contact sheet for visual review. Record the target slot and export
transform in the upload manifest; do not relabel master validators as upload proof.
Actual App Store Connect acceptance remains **NOT_OBSERVED** until confirmed.

Exact local results and follow-up instructions:
[`UPLOAD_COMPATIBILITY_HANDOFF.md`](../reports/S03-A/round-01/UPLOAD_COMPATIBILITY_HANDOFF.md).

## Evidence folder

Suggested structure:

```text
store-assets/
  SCREENSHOT_STORYBOARD.md
  CONTACT_SHEET_EN.png
  CONTACT_SHEET_ZH_HANS.png
  captures/
    en/
    zh-Hans/
  en/
    01-awareness.png
    02-choose-interval.png
    03-reminder.png
    04-today.png
  zh-Hans/
    01-awareness.png
    02-choose-interval.png
    03-reminder.png
    04-today.png
  scripts/
  RENDER_MANIFEST_EN.json
  RENDER_MANIFEST_ZH_HANS.json
  IMAGE_VALIDATION_EN.json
  IMAGE_VALIDATION_ZH_HANS.json
```

## Product freeze

Screenshot work must not become an excuse to add screenshot-only behavior to production.

No product runtime changes solely to make a prettier Store screenshot unless separately approved.

If a truthful capture is impossible without a runtime change, document the limitation and use an already-shipped tutorial/sample screen instead.
