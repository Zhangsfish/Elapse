# S02-B delivery

State: **WAITING_FOR_OWNER_TEST — 69.1 internally available**. No stage approval.
Base main: `c1480eb0021c1fc2261a54ace4576feb7c537d8d`.
Branch / draft PR: `codex/s02-b-onboarding-polish` / [#21](https://github.com/Zhangsfish/Elapse/pull/21).

## Active owner-approved revision

Owner installed 65.1 but asked for less text and Lecture Asset-style actions. Owner explicitly approved four scenes on 2026-10-06. This replaces the text-heavy sheet, not the accepted home/Today or S01 behavior.
- Choose multiple generic Apps; confirm.
- Choose reminder interval; demonstrate Start.
- Shared selected-App time adds up; example banner.
- Example Today total, hourly aggregate bars and per-App rows.

One short title/caption per scene; optional Next/Back/Skip/Get started; first visit and home-question-mark replay retained. Demo cards cannot operate real settings. No permission, picker, monitor or notification requests from teaching; sample durations stay local to the App artwork.
Three-second time-addressable SwiftUI artwork plays once, then pauses; static settled frame with Reduce Motion/VoiceOver/background. Pinned footer stacks at accessibility text sizes. S01 lifecycle/reconcile, Today aggregation, report privacy boundary, App Groups, Bundle IDs and capabilities unchanged.

Reference: Lecture Asset current main `4995c1d0d70ebdf3712416bf96ee31219fc67720`, TutorialView/TutorialArtwork. Owner direction and current Apple API links: `evidence/four-scene-direction.md`. No installs or remote media.

## Exact provenance

- Runtime code: `f05df01fa52a144664d3ca87ffd8340fddd5cf6f`.
- Ordinary/prepare-tested: `e1fba3d5ead1790b5ffef2e9118fc82d78ad58df` (marker only).
- Explicit upload SHA: `9de0a209c653769a2881e68e1586a6f34bacdff7` (upload marker only); **Everwhile 0.1.0 (69.1)**.
- Final evidence/marker-cleanup head recorded in PR metadata; no source edits after tested build without affected retesting.

## Checks

Windows: 13 Python tests, Bash syntax, whitespace PASS; no local Xcode/Swift.
[Prepare](https://github.com/Zhangsfish/Elapse/actions/runs/37353626575): 58 Swift / 0 failures, 13 Python, XcodeGen/effective entitlements, unsigned iPhone Release build/archive, actual metadata/extensions and en+zh-Hans App/Monitor/Report resources PASS. 68.1 not uploaded; Apple secrets/signing skipped.
[Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37353631696), attempt 2: PASS. 58 Swift / 13 Python, simulator build/resources/capabilities and English first-visit/replay + Chinese largest-text replay PASS. All four scenes retain Dynamic Type/text-clipping audits; ten unique clean-simulator captures inspected. Requested dark mode settled in the final Chinese scene, not all captures; exhaustive four-scene dark visual coverage remains unverified. Attempt 1 was a pre-test simulator boot timeout (NOT_RUN), not UI PASS.
[Explicit upload](https://github.com/Zhangsfish/Elapse/actions/runs/37357058165): PASS. Final signed IPA App/Monitor/Report signatures, expected IDs, Family Controls claims/profile allowance and required App Groups PASS. Exactly those audited bytes uploaded ACCEPTED; 69.1 processing VALID / INTERNAL_ONLY / IN_BETA_TESTING / existing internal-group assignment TRUE at 18:43:49Z. Safe evidence: `evidence/four-scene-release.txt`. No new account setup or owner Actions click.
[Extra exact-upload ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37357063413), job111922047054: PASS. 58 Swift / 13 Python, simulator build/resources/capabilities, English and Chinese-largest-text native UI/audits PASS at the exact upload SHA. Only markers differ from tested runtime.
Current raw safe extracts/limits: `evidence/four-scene-validation.md`.
Executed prepare/upload marker files removed; history retains the exact trigger commits.
Ordinary code/docs pushes and PR merge do not repeat this upload. No workflow change
was needed for the four-scene revision.

## Historical evidence

59.1 home OWNER_REPORTED_PASS; inline teaching CHANGES_REQUESTED. 65.1 installed OWNER_REPORTED; text-heavy teaching also requires revision. Their tests, delivery and screenshots are historical, not four-scene acceptance.
65.1 runtime2117717..., preparefdeddf4..., uploadb6ff74e... had 54 Swift / 12 Python and two native UI/audit checks PASS at prepare SHA; extra upload-SHA UI attempt BLOCKED_ENV/NOT_RUN. Final signatures PASS, ACCEPTED/VALID/IN_BETA_TESTING/internal group TRUE after read-only run37328896729.
Safe historic evidence remains first-visit-validation.md / first-visit-release.txt, owner-onboarding-revision.md and original ordinary-ci.md / prepare-only.md / internal-release.txt. Superseded62.1 real Dynamic Type failure and bounded processing PENDING remain explicitly recorded.

## Device / audit boundary

69.1 four-scene build installation and owner visual acceptance **NOT_RUN**. After update ask only a short home question-mark replay / exit observation; no reinstall, selection clearing, reboot, revocation, midnight, pulse wait or Today retest.
Human VoiceOver, physical Reduce Motion and physical notification-language display remain NOT_RUN. Source/pure/resource/native tests are labelled separately. No private screenshots or raw signing materials published.
Remain in S02-B. No self-approval/merge/S03 unlock; READY_FOR_AUDIT only after required new owner evidence.
