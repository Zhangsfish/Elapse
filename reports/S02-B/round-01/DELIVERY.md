# S02-B delivery

State: **WAITING_FOR_OWNER_TEST**; engineering/distribution complete, short owner UI observation NOT_RUN. No stage approval.
Base main: `c1480eb0021c1fc2261a54ace4576feb7c537d8d`.
Branch / draft PR: `codex/s02-b-onboarding-polish` / [#21](https://github.com/Zhangsfish/Elapse/pull/21).
Runtime / ordinary-CI-tested SHA: `e1d6a5c81041d93e0f121c0ed757eb8fff391c89`.
Prepare-tested SHA: `9a58c1d43c45edbe1f31172ce6ff97ddfb6e7fef`.
Upload / release-tested SHA: `764825461b913f777fae9aea84019b049f4502e5`.
Only marker additions differ between these three SHAs; no runtime edits after the tested candidate.
Internal build: **Everwhile 0.1.0 (59.1)**; processing VALID, INTERNAL_ONLY, IN_BETA_TESTING, assigned to the existing internal group.
Final evidence/marker-cleanup head SHA is recorded in PR metadata after this document commit (avoids a self-referential commit hash).

## Changes

Single-screen setup remains permission -> selection -> Start -> quiet ON/Stop. A generic, optional selection illustration shows two checkmarks and confirmation; it appears inline only with authorization, no selected apps and editable selection. Returning users can open Selection tips without clearing their choices. Reduce Motion/VoiceOver use static illustration; actual selection remains FamilyActivityPicker.

First-use source inspection exposed a UI integration gap: notification permission was only reachable in Advanced. First Start now requests the existing notification authorization method only when notDetermined, then calls the unchanged startMonitoring method. A brief normal-home note distinguishes disabled alerts from monitoring; settings access is available without forcing a new onboarding page. Existing allowed users are not re-prompted.

Pulse copy uses the Monitor bundle's en/zh-Hans resources and the actual threshold. Pure and resource-backed tests cover multiple thresholds and safe missing-resource English fallback. Tagline matches Everwhile's product direction.

Duration formatting follows the bundle's resolved localization, not every `zh` locale. Explicit Traditional Chinese scripts use English in the pure fallback resolver; no Traditional Chinese product language added. Home summary and report App rows stack at accessibility sizes; chart height scales with Dynamic Type. Aggregation, lifecycle, registration semantics, groups, capabilities and IDs are unchanged.

PRODUCT_SPEC previously contained historical `today` pulse wording inconsistent with current interval semantics; this stage updates only that copy contract to the active prompt's reminder-point wording.

## Verification boundaries

Windows has no Xcode. Use existing macos-26 CI / XcodeGen / native XCTest and internal TestFlight route. Ordinary CI uses no secrets. New packaging assertions cover App, Monitor and Report in simulator/device/archive. Native UI smoke runs on a clean simulator with English light and zh-Hans dark/accessibility text; it cannot prove Screen Time behavior or human VoiceOver quality.

Apple references verified against current official documentation: [bundle language selection](https://developer.apple.com/documentation/foundation/bundle/preferredlocalizations), [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion), [Dynamic Type](https://developer.apple.com/videos/play/wwdc2024/10074/). Current SDK compilation remains separate evidence.

## Results / evidence

- Windows: `python -m unittest discover -s scripts/tests` (12 PASS), YAML parse of project/workflows, `git diff --check`, Bash syntax PASS. No local Swift/Xcode installed or new dependencies installed.
- [Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37306828901): SUCCESS at runtime SHA; Xcode 26.6 / Swift 6.3.3 / XcodeGen 2.46.0 on macos-26. **53 Swift tests / 0 failures**, 12 Python tests, simulator build, generated/effective capabilities and App/Monitor/Report en + zh-Hans packaging PASS.
- [Ordinary CI at exact upload SHA](https://github.com/Zhangsfish/Elapse/actions/runs/37308632112): SUCCESS; 53 Swift tests / 0 failures, 12 Python tests, simulator/resource checks and both native UI/accessibility tests reran PASS. No runtime change between runtime candidate and upload SHA.
- Native simulator tests: English light/default text and zh-Hans dark/largest accessibility text PASS; automated Dynamic Type/text-clipping audit PASS. Four clean-simulator screenshots from the preceding passing runtime candidate were visually inspected. No fabricated permissions/usage, no owner screenshots. See `evidence/ordinary-ci.md` for exact provenance/limits.
- [Prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37308195208): SUCCESS at prepare SHA; unsigned Release iPhone build/archive, metadata, capabilities and en/zh-Hans pulse keys in all three archived bundles PASS. No Apple secrets read. Build 58.1 was not uploaded. See `evidence/prepare-only.md`.
- [Explicit internal upload](https://github.com/Zhangsfish/Elapse/actions/runs/37308628567): SUCCESS at upload SHA; 53 Swift / 12 Python tests, device/archive/localization checks PASS. Exact signed IPA SHA-256 `5faffbafcde3997d7b3ab8a7581f8523fc031a1a9152c55d9876097ea7aa3789`; signatures, Family Controls claims and profile allowances on App/Monitor/Report PASS. App/Monitor groups expected; Report group not required. Apple accepted upload; processing VALID; internal group assignment confirmed. Safe exact summaries in `evidence/internal-release.txt`; no raw signing logs, profile or private key published.
- Upload is a marker-only branch push with exact explicit commit message. Both newly added one-time markers are removed after execution; ordinary code/document changes cannot authorize another upload. No main push/upload policy expansion.

Source + pure tests cover existing-selection teaching suppression, Reduce Motion/VoiceOver static fallback, both language copies across 5..1495-minute thresholds, missing-resource English fallback and Hans/Hant/unsupported locale resolution. Actual system language choice is bundle-managed; no Traditional Chinese resources added.

Human VoiceOver, physical Reduce Motion and physical notification-language display remain **NOT_RUN**. Simulator audit is not a human reader test. Source/resource-backed tests + compiled Monitor resources provide notification-copy evidence, so no new pulse-wait task is needed. Authorized first-use and live report at large text are SOURCE_INSPECTED, not simulated private usage. Report data stays inside the extension; S01 lifecycle/reconcile/plan and Today aggregation are unchanged.

Remaining required step: one short existing-user home / optional Selection tips inspection on 59.1. No clearing selections, reboot, permission revocation, midnight, new long usage or S01 retest. Stay WAITING_FOR_OWNER_TEST; only after actual feedback submit READY_FOR_AUDIT for cloud review. S03 remains LOCKED; PR not approved or merged.
