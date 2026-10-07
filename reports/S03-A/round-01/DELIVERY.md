# S03-A / round-01 — Pass 2 bilingual freeze

2026-10-07 · **READY_FOR_AUDIT**. PR [#22](https://github.com/Zhangsfish/Elapse/pull/22)
· codex/s03-a-app-store-preflight. No self-approval, merge or S03-B unlock.

## Exact sources

- Current main synchronized: db2a12f11c2a7e5c749d1682b3ade769eca77a82.
- Owner explicitly approved English reference 7aff9a46ba14716f22d0532a29f80408c5b8c18e.
  Four English PNGs/contact/manifest/validation/renderer remain unchanged.
- Chinese capture: 86cb53710b01d7ece92875c8f93d52ebf6f2d0f2.
- Assets implementation: 7a65f4a80db86225e2f621231bed97bafa66dc9b.
- Evidence fix: 4f6b13866a0f1f49f334b579a1e8d4a896868378.
- Chinese label centering: dc38239a9078f3a5fb2ba92a6299737653835dfe.
- Chinese pill padding / tested implementation: e68dffa7795b6afe8d5fc415e530a9636364657a.
  Later report/status edits are documentation only; GitHub records exact PR head.
- Frozen functional runtime: fab87acc8f4b863451d9c91ee7605b4c33c47789, **0.1.0 (91.1)**.
  App/Shared/Monitor/Report/Localization/AppResources/project.yml stay identical.
- Existing signed/internal upload: d633b5b627933d71aac221a3bb2f6aae29fd82a2,
  [37480245045](https://github.com/Zhangsfish/Elapse/actions/runs/37480245045).
  No new TestFlight, signing, ASC write, App Review or public release.

## Final assets / provenance

Chinese review: store-assets/CONTACT_SHEET_ZH_HANS.png + four zh-Hans/*.png.
English stays en/*.png. Both sets: 1320×2868 opaque RGB/sRGB; phone
[202,803,916,1958], screen [215,815,890,1934], headline origin [104,238].
Brand/backgrounds/motif structure/order and approved +3.97% phone scale match English.
Chinese follows exact requested copy; Frame 4 naturally breaks “看看时间 / 去了哪里。”.
Subline: “总量 · 每小时 · 各 App”. Only external text adaptation: Chinese interval
label42px centered by visible ink. Owner subsequently requested a wider Chinese
pill: right edge +50px, rect[614,596,1264,708], same height/radius/left edge.
Actual ink bounds[654,632,1225,673]: side padding40/39px, center rounding≤0.5px.
This explicit Chinese-only fitting exception is in the manifest and storyboard;
English pill remains[614,596,1214,708]. Other three Chinese PNGs
and every English output stayed byte-identical. Headlines remain 94px/weight700.

Installed Noto Sans SC VF, face0, weights400/700, SHA256
763146584cf0710223441356b4395e279021b0806c196614377a7a0174ae074a.
Manifest pins font/Segoe/ICC; no font files committed. Reused Pillow11.1.0/numpy1.26.4.

| Frame | Actual Chinese Release source |
|---|---|
| Awareness | Genuine unauthorized/unconfigured fresh Home |
| Choose apps + interval | Shipped Quick Start; generic App A/B/C |
| Reminder | Shipped Quick Start reminder, not OS notification history |
| Today | Shipped Quick Start sample, not live/private usage |

Tutorial chrome remains. Uniform resize/corner mask only; **zero phone repaint**.
No owner data, real tokens or screenshot-only production mode. Codex contact-sheet
inspection found no clipped text/phone chrome; this is not cloud/owner approval.
Details: SCREENSHOT_STORYBOARD.md and manifests.
Owner subsequently replied “可以” to the final widened/centered Chinese layout
on 2026-10-07. Both language sets are visually accepted/frozen; independent cloud
audit remains pending. No output changed after acceptance at asset SHA e68dffa….

## Executed checks

- [Chinese capture37574631559](https://github.com/Zhangsfish/Elapse/actions/runs/37574631559)
  **PASS**, actual1 XCTest/0fail/0skip at 86cb537…; fresh iPhone17ProMax, Release,
  zh-Hans/zh_CN,9:41/Wi-Fi/fullbattery. Xcode26.6(17F113),SDK26.5, actual
  simulator26.2(23C54)/arm64,macOS26.6.2(25G83).
  Artifact11461939866 ZIP SHA256:
  7fc570f970f8ef2f15dffcf5547fa9dec69588bd0875b9ae539747e577b887e9.
  Raw/inventory/provenance: captures/zh-Hans/. Safe test-summary projection drops
  ephemeral simulator ID, not test results.
- English capture stays [37501370483](https://github.com/Zhangsfish/Elapse/actions/runs/37501370483)
  at 6e5a82fc60236c5bc9a408207fcd6ad102cacffa; not current-head capture evidence.
- **42/42 Python tests PASS**, none skipped: freeze/tamper, fresh locale provenance,
  count/geometry/RGB/ICC/alpha/hash, newline/content binding and glyph-centering tests.
- Independent pixel validator **PASS**: all opaque screen pixels equal resized raw;
  text/font/profile/raw hashes and exact contact tiles checked. One-pixel repaint
  rejected even after updating its output hash.
- Deterministic rerender: four Chinese PNGs + manifest/contact byte-identical.
  English four PNGs/contact exact bytes unchanged before/after; ENGLISH_FREEZE.json
  records all pre-Chinese hashes. IMAGE_VALIDATION_ZH_HANS.json binds exact outputs.
- [Preflight37576033354](https://github.com/Zhangsfish/Elapse/actions/runs/37576033354)
  **PASS** at tested4f6b138…; frozen production/bilingual assets/metadata checked.
- Latest [preflight37576805095](https://github.com/Zhangsfish/Elapse/actions/runs/37576805095)
  at dc38239…: **PASS**, all42 tests and bilingual/frozen source checks.
- Latest [preflight37577314358](https://github.com/Zhangsfish/Elapse/actions/runs/37577314358)
  at e68dffa…: **PASS**,42 tests and bilingual freeze checks.
- Latest [ordinary37577314354](https://github.com/Zhangsfish/Elapse/actions/runs/37577314354)
  at e68dffa…: **PASS**. XcodeGen/simulator/localization packaging PASS;
  60 Swift +42 Python tests,0fail; actual Release English/light and zh-Hans/dark/
  largest Dynamic Type UI each1 test PASS,0fail. No boot-timeout NOT_RUN exemption.
  Later delivery/status-only head CI is separately shown by GitHub and PR body,
  never represented as this implementation SHA's run.
- Ordinary37576033334 at4f6b138… was superseded by the owner-requested label edit;
  build/packaging/helper/Swift steps completed; UI cancelled, no full/UI PASS claimed.

Failed [preflight37575693534](https://github.com/Zhangsfish/Elapse/actions/runs/37575693534)
at7a65f4a… rejected stale evidence: WindowsCRLF vs GitLF manifest digest. Fixed
LF output + content-bound LF-normalized manifest hash; PNG hashes remain exact.
Regression accepts newline-equivalent JSON and rejects content edits. No PNG change.

Approved English-head [37573154027](https://github.com/Zhangsfish/Elapse/actions/runs/37573154027)
had successful job but **UI NOT_RUN / boot timeout**. Earlier actual bilingual UI
PASS: [37504293740](https://github.com/Zhangsfish/Elapse/actions/runs/37504293740)
atb6ba48ceaca345091056f73329840de91f878e14 (60Swift, EN/Hans each1UItest).
Neither is current-head UI PASS. Prior UI-race evidence remains
evidence/ordinary-ci-first-attempt.md.

Reproduce without rewriting English:

```powershell
& 'C:/conda_envs/myenv/python.exe' -m unittest discover -s scripts/tests
& 'C:/conda_envs/myenv/python.exe' store-assets/scripts/english_freeze.py
& 'C:/conda_envs/myenv/python.exe' store-assets/scripts/render_store_zh_hans.py
& 'C:/conda_envs/myenv/python.exe' store-assets/scripts/validate_store_zh_hans.py --self-test
& 'C:/conda_envs/myenv/python.exe' scripts/s03_preflight.py
```

Do not regenerate English or rewrite its historical draft labels. External owner
approval and independent freeze guard supersede those immutable Pass1 labels.

## Separate later release gates

- Family Controls portal Assigned: **BLOCKED_OWNER_CONFIRMATION**, distinct from
  proven three-bundle final signature/profile allowance (evidence/distribution-gate.md).
  Later minimal portal-state confirmation only, never secrets/profiles.
- Public pages **NOT_LIVE**. Source/workflow prepared; approved merge + Pages source
  setting before anonymous HTTPS. Eight local Chrome renders remain inherited
  evidence/public-pages-local-browser.json, not public-HTTPS proof.
- ASC privacy/agreements/contact/legal/rating/export/regions: later owner decisions.
  Mainland China blocked until ICP status confirmed.
- Existing91.1 **INTERNAL_ONLY**, not review-eligible. S03-B may later prepare an
  authorized eligible package; this asset pass authorizes no upload.

No new physical-phone tests. S03-B/S03-C remain **LOCKED**.
