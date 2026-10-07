# S03-A / round-01 — English detail polish 2

2026-10-07 · **WAITING_FOR_OWNER_VISUAL_REVIEW**, not READY_FOR_AUDIT.
PR [#22](https://github.com/Zhangsfish/Elapse/pull/22) · `codex/s03-a-app-store-preflight`.

## Exact source and evidence

- Base main: `e63cbe8c6327ff5e1e0bed1a209800c7ef661a4a`.
- Frozen functional runtime: `fab87acc8f4b863451d9c91ee7605b4c33c47789`, **0.1.0 (91.1)**.
- Fresh Release capture source: `6e5a82fc60236c5bc9a408207fcd6ad102cacffa`;
  [capture CI](https://github.com/Zhangsfish/Elapse/actions/runs/37501370483) **PASS**.
- Current main synchronized: `db2a12f11c2a7e5c749d1682b3ade769eca77a82`
  (handoff-only update merged into the task branch; no PR/main merge).
- Screenshot-polish implementation tested locally: `8a7911366ecf3b2f3de2bb2b89b84298e8774b3c`.
  Later delivery/STATUS changes are documentation only. PR head is recorded by GitHub.
- Existing signed/internal upload: `d633b5b627933d71aac221a3bb2f6aae29fd82a2`;
  [upload](https://github.com/Zhangsfish/Elapse/actions/runs/37480245045).
  No new upload; see `evidence/distribution-gate.md`.

Production trees App/Shared/Monitor/Report/Localization/AppResources/project.yml are
byte-equivalent Git trees to frozen runtime. No fake-data mode, runtime resource,
entitlement, capability, Bundle ID, tutorial or Today change.

## Owner review package

English detail-polish revision 2 is ready for owner visual review. The owner
requested preserving the four-frame design/copy/background/order, not final approval.
Phones uniformly enlarged 3.97%, brand/icon mildly stronger, Frame 2 interval
text now 44px bold (12px at 360px thumbnail). Frame 3 modifies only external
accumulation → bell art; Frame 4 outside bars are paler/half-height.
Frame 1 remains genuine unconfigured Home: source inspection found no fuller
genuine state available in the existing clean capture set. No fake state or new
authorization attempt. See `store-assets/SCREENSHOT_STORYBOARD.md`.

`store-assets/CONTACT_SHEET_EN.png` plus `store-assets/en/01-awareness.png`,
`02-choose-interval.png`, `03-reminder.png`, `04-today.png`.
All four are **1320×2868 RGB/sRGB PNG, no alpha**. Fixed headline/phone/screen
geometry, restrained blue/off-white motifs and shadows. Phone bottom is visible.

| Frame | Actual source / limitation |
|---|---|
| Awareness | Real fresh Release Home, unauthorized/unconfigured, no invented ON state |
| Choose apps + interval | Real shipped Quick Start selection example, generic App A/B/C; external interval illustration |
| Reminder | Real shipped Quick Start reminder scene, not fabricated OS notification history |
| Today | Real shipped Quick Start Today example, not live/private report usage |

Frames 2–4 retain tutorial chrome. No owner's app names, times or screenshots used.
Raw captures + source hashes: `store-assets/captures/en/`; complete render manifest
and independent proof: `RENDER_MANIFEST_EN.json`, `IMAGE_VALIDATION_EN.json`.
Fresh iPhone 17 Pro Max simulator, English, Release, Xcode 26.6 / iOS SDK 26.5.
Capture artifact 11429474159 ZIP SHA256:
`530395046efe549ff652feab42557dab9f4302225ba8d207c515d8d14028ec32`.
Lecture Asset reference `4995c1d0d70ebdf3712416bf96ee31219fc67720`: both language
pipelines/exporters/renderers/validators/contact sheets read, not just colors.

Only after owner accepts English composition: freeze English bytes, capture and
render zh-Hans at identical geometry. Chinese final images are **NOT_RUN**.

## Executed checks

- Python **31/31 PASS**: existing 19 + twelve S03 tests, missing/duplicate/path-traversal/
  wrong-size/skipped/failing capture rejection, UTF-8 metadata limits, static pages,
  source privacy/bundle boundary and frozen production tree/hashes. Two new
  standard-library tests pin unchanged copy, common geometry/brand, 3–5% scale,
  interval thumbnail font size and renderer/manifest constant consistency.
- Real capture XCTest **1/1 PASS**, 0 skipped/failed; generated effective entitlements PASS.
- Four output images: dimensions/mode/profile/hash/text bounds/fixed geometry PASS;
  every opaque phone pixel equals uniformly resized raw capture (**zero repainted**).
- Deterministic rerender: four PNGs + manifest + contact sheet byte-identical.
  Tamper test: changed one temporary pixel and updated hash; independent validator rejected it.
- Static Support/Privacy Chrome 154 check: eight 320/960px × light/dark page renders;
  no horizontal overflow, visible keyboard focus, correct mailto, local CSS, bilingual
  content, privacy navigation, no external resource requests. Local files only,
  **not public HTTPS proof**. `evidence/public-pages-local-browser.json` + two previews.
- Ordinary macOS CI [37501399700](https://github.com/Zhangsfish/Elapse/actions/runs/37501399700)
  **FAILED** existing English smoke at S02PolishUITests.swift:89; generated project,
  simulator/localization/helper and **60 Swift tests PASS**; Hans dark/large-text UI PASS.
  The failure immediately checked tutorial-skip existence after seeing the underlying
  About sheet's Done button. A dismissal race is suspected; no product regression
  is excluded merely from that suspicion. Test-only change adds Apple's bounded
  `waitForNonExistence(timeout: 5)` and retains the negative assertion. No runtime
  edit, failure suppression or fixed sleep. Rerun
  [37504293740](https://github.com/Zhangsfish/Elapse/actions/runs/37504293740)
  **PASS** on `b6ba48ceaca345091056f73329840de91f878e14`: actual English and
  zh-Hans dark/large Release XCTest each executed 1 test, 0 failures; 60 Swift
  and 29 Python tests PASS. No simulator-boot NOT_RUN exemption used.
  This is inherited runtime/UI evidence, not new-polish-head CI evidence.
  See `evidence/ordinary-ci-first-attempt.md`.
- New `S03 secret-free store preflight` workflow repeats the 31 tests and static/
  hash checks on the PR; no Apple credentials. Capture and preflight workflows
  never export/upload a signed app. Existing ordinary CI remains secret-free.
  Its initial [28-test run](https://github.com/Zhangsfish/Elapse/actions/runs/37503916636)
  passed on `912bfacc40fe48fbc79010cb60226f02fba1fe6a`;
  [37504293779](https://github.com/Zhangsfish/Elapse/actions/runs/37504293779)
  also passed 29 tests on `b6ba48ceaca345091056f73329840de91f878e14`.
  Latest polish-head CI starts after push; until recorded, it remains PENDING.

Reproduce with installed tools, no dependency install:

```powershell
& 'C:/conda_envs/myenv/python.exe' -m unittest discover -s scripts/tests
& 'C:/conda_envs/myenv/python.exe' scripts/s03_preflight.py
& 'C:/conda_envs/myenv/python.exe' store-assets/scripts/render_store.py
& 'C:/conda_envs/myenv/python.exe' store-assets/scripts/validate_store.py --self-test
$env:PLAYWRIGHT_MODULE = 'C:/Users/Zhang S/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright'
node store-assets/scripts/check_public_pages.cjs
```

Renderer uses installed Pillow 11.1.0/numpy 1.26.4, Windows Segoe UI/sRGB ICC;
manifest pins font/profile/icon hashes. Playwright CLI was not installed; existing
bundled Playwright/system Chrome were reused without downloading either tool.
Full temporary browser renders regenerate under `.build/output/playwright/s03/`.

## Other S03-A preparation / separate gates

- Source audit + bilingual metadata + review notes + static public pages **DRAFT_READY**.
  `docs/APP_STORE_PRIVACY_DRAFT.md`, `APP_STORE_METADATA.md`, `APP_REVIEW_NOTES.md`,
  `APP_STORE_OWNER_CHECKLIST.md`. Metadata character and keyword-byte limits PASS.
- Existing three-bundle Family Controls signature/profile allowance PASS, required
  App Groups PASS. Portal **Assigned** remains **BLOCKED_OWNER_CONFIRMATION**.
  One later action: Developer portal → Certificates, Identifiers & Profiles →
  Capability Requests → Family Controls; confirm Assigned/provisioning support for
  main, Monitor and Report. Reply only states, never profiles/secrets.
- Public pages **NOT_LIVE**. Main-only GitHub Pages workflow prepared; repository
  `has_pages=false`. After approved merge, owner sets Settings → Pages → Source:
  GitHub Actions once; Codex then retries if needed and verifies anonymous HTTPS.
- ASC privacy/support handling, agreements, legal copyright, rating, export answers,
  review-contact private fields and exact regions need later owner confirmation.
  United States first / Free / iPhone-only / manual release are recommendations only.
  Mainland China **BLOCKED_UNTIL_ICP_STATUS_CONFIRMED**.
- 91.1 is **INTERNAL_ONLY**, not App-Review-eligible. A later authorized S03-B
  package may preserve the frozen runtime but must be eligible for public review.
  This is not a credential/signing failure and does not authorize an S03-A upload.
- Current screenshot-size draft follows owner-requested large Dynamic Island size;
  verify required ASC size slots/scaling at data-entry stage, not presumed complete now.

No new phone functional tests, merge, App Review, public app release, self-approval
or S03-B unlock. Current next owner action is English visual review only.
