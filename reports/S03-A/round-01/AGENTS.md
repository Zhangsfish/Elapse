# S03-A preflight memory

Base main: e63cbe8c6327ff5e1e0bed1a209800c7ef661a4a.
Scope: store screenshots and release-preparation documents; frozen 91.1 runtime.

`DELIVERY.md` and `TEST_RESULTS.json` track executed checks and separate owner
legal/portal gates. `DEVICE_OBSERVATIONS.md` holds only actual owner observations;
no new functional phone test is required. `evidence/` contains safe source/signing
summaries, not private provisioning material. Store sources/assets live in
`store-assets/`; public-page source lives in `public-pages/`.

English screenshot visual gate precedes Chinese production and READY_FOR_AUDIT.
No self-approval, merge, upload, App Review submission or next-stage unlock.

2026-10-07 detail polish 2: existing four-frame design retained; reports record
actual 31 Python/pixel/determinism checks and prior successful macOS UI rerun.
Canonical review image is `store-assets/CONTACT_SHEET_EN.png` revision 2.
English final approval is explicit at 7aff9a46ba14716f22d0532a29f80408c5b8c18e.

2026-10-07 Pass2: canonical Chinese review is store-assets/CONTACT_SHEET_ZH_HANS.png.
Fresh Release capture source86cb53710b01d7ece92875c8f93d52ebf6f2d0f2; CI37574631559 passed.
Manifests/independent pixel proof/freeze guard live under store-assets/. English
outputs/renderer are immutable. Reports separate capture source, tested code,
documentation-only head and current CI. No new runtime/upload/device evidence.

2026-10-07 side-conversation correction: UPLOAD_COMPATIBILITY_HANDOFF.md records
actual owner ASC size rejection, local English 1206x2622 derivatives and Frame2
ink centering. This supplements (does not rewrite) the prior master freeze/CI.
Chinese upload-size exports and actual upload acceptance are still NOT_RUN /
NOT_OBSERVED. Follow the updated screenshot production spec before release.
