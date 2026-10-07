# S03-B / round-01 — release closeout

2026-10-07. **READY_FOR_OWNER_SUBMISSION — PR #25 awaiting independent cloud audit.**
Private declarations/storefront approval and final Submit for Review remain with
owner. No submission, public release, stage unlock or self-merge performed.

## Exact candidate — existing artifact, not rebuilt

- Everwhile **0.1.0 (92.1)**; frozen functional runtime
  `fab87acc8f4b863451d9c91ee7605b4c33c47789` (accepted product 91.1).
- RC source `10b9e29f9d730e83a1fbd852fa49b09d83dd155a`;
  [RC run](https://github.com/Zhangsfish/Elapse/actions/runs/37580987653).
- Exact IPA SHA256
  `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`.
- Historical RC: unsigned archive/export/exact signed IPA audit PASS; Apple
  Distribution + Family Controls claim/profile on all three bundles PASS;
  App/Monitor required App Group PASS; get-task-allow=false; App-Store profiles.
  Upload ACCEPTED / VALID / APP_STORE_ELIGIBLE / non-exempt encryption false.
- No new RC/archive/upload/TestFlight for this closeout; product and screenshot
  paths unchanged. Historical signature evidence is not relabelled as a new build.

## Current closeout

Branch `codex/s03-b-portal-closeout`; [PR #25](https://github.com/Zhangsfish/Elapse/pull/25).
Base main `3afd08da4408860e9a2236904fe92c543f4d37d8`; #24 already merged.
Closeout implementation/tested/API preparation SHA:
`41acc8158acea3087d9cfed4f98967f9c68cd3cc`.
Subsequent report-only commits do not change the tested helper/runtime.

- Support + Privacy **LIVE_VERIFIED**; Pages enabled using existing authorized
  GitHub admin credentials, not an owner workaround. Main
  [deployment PASS](https://github.com/Zhangsfish/Elapse/actions/runs/37583194129).
- Anonymous HTTPS200/source bytes/bilingual/cross-links/mailto/no analytics/JS/login
  verified in `evidence/public-pages-live.json`.
- [Safe ASC preparation/readback PASS](https://github.com/Zhangsfish/Elapse/actions/runs/37584709525):
  existing 92.1 associated to 0.1.0, both locale URLs saved, final review notes
  saved+matched, private contacts complete, marketing blank, MANUAL,
  PREPARE_FOR_SUBMISSION. No private field values recorded.
- Owner exact EN promo (165 characters) and actual bilingual ASC listing are
  reconciled in metadata. Limits PASS; Chinese promo not rewritten.
- App Privacy recommended **No / Data Not Collected; tracking No**. Source-based
  basis and mail/local-data distinctions in PRIVACY_DRAFT / PORTAL_CLOSEOUT.
  ASC Nutrition Label publication/legal attestation **NOT_VERIFIED**, not PASS.
- Family Controls operational distribution gate CLOSED; unread Assigned UI
  **NOT_REQUIRED_FOR_RELEASE / OPTIONAL_OWNER_READBACK**. Not App Review approval.

## Current tests (not inherited RC tests)

[Release tooling CI PASS](https://github.com/Zhangsfish/Elapse/actions/runs/37584657316)
at `41acc8158acea3087d9cfed4f98967f9c68cd3cc`:
60 Swift / 48 Python, no failures; Swift readback/status typechecks, shell static
checks and frozen product diff PASS. Local 48 Python and S03 preflight PASS.
Final PR-head CI status is checked separately in the PR handoff; pending/skipped
UI evidence must not be reported as current-head PASS.

Commands: `python -m unittest discover -s scripts/tests`,
`python scripts/s03_preflight.py`, `python scripts/s03_live_pages.py --output ...`,
`swift test`, `swiftc -typecheck scripts/s03_asc_readback.swift`,
`swiftc -typecheck scripts/s03_review_status.swift`,
`bash -n scripts/s03_review_release.sh`, `git diff --check`, protected-path
`git diff --quiet fab87acc... HEAD -- App Shared MonitorExtension ReportExtension Localization AppResources project.yml`.
Windows Python `C:/conda_envs/myenv/python.exe`; Apple compile/tests on macos-26 CI.

Remaining exact owner actions and rationale: `PORTAL_CLOSEOUT.md` and
`docs/APP_STORE_OWNER_CHECKLIST.md`. No phone retest, Pages setup, secret changes,
contact re-entry, screenshot re-upload, build selection or Actions button needed.
