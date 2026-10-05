# First-visit revision validation

Runtime candidate: `c9501d1efc79066da3eb4120d9c56bc05f6ce566`.
Prepare SHA: `b0f859394e21e76d87108a324568fb4c9c242e20`; only a marker differs.

## Ordinary CI

Initial run [37319601048](https://github.com/Zhangsfish/Elapse/actions/runs/37319601048), attempt 1: simulator build, 54 Swift tests / 0 failures, 12 Python tests and localization packaging PASS. UI checks **BLOCKED_ENV / NOT_RUN** because simulator bootstatus exceeded 360 seconds. Green job is not UI PASS. Attempt 2 was superseded/cancelled by the marker's ordinary-CI run; it adds no UI evidence.

Replacement ordinary run [37321308582](https://github.com/Zhangsfish/Elapse/actions/runs/37321308582) at prepare SHA: build, 54 Swift / 12 Python tests, localization/capabilities PASS; UI again **BLOCKED_ENV / NOT_RUN**, with bootstatus stuck in `com.apple.locationd.migrator` before any test. No runtime change from candidate. No Apple secrets used. These are infrastructure timeouts, not assertion failures or UI PASS. Exact-upload ordinary CI runs the UI check again independently.

## Prepare-only

[37321300215](https://github.com/Zhangsfish/Elapse/actions/runs/37321300215): PASS. XcodeGen/effective entitlements, 54 Swift tests / 0 failures, 12 Python tests, unsigned iPhone Release build/archive, distribution metadata and en/zh-Hans resources in App/Monitor/Report PASS. Build 61.1 is not uploaded. Secrets/signing/upload skipped.

Diagnostic READ_ERROR/FAIL lines emitted by unit-test fixtures are not real unsigned-archive failures. Real prepare checks occur after fixture tests; an unsigned archive is never final distribution-signature evidence.

## Superseded 62.1 / concrete UI regression

Exact-upload ordinary run [37322850738](https://github.com/Zhangsfish/Elapse/actions/runs/37322850738) ran the English first-visit/replay test. Presentation, Skip and replay reached the intended views. The automated Dynamic Type audit then **FAILED** at the native navigation-bar Skip button; its diagnostic attachment isolates that button. Chinese large-text test did not run after the failure. This is a real audit failure, not BLOCKED_ENV.

Clean-simulator artifact `11351247791` was downloaded to ignored `.build/` and its full tutorial and cropped failing-Skip PNGs were visually inspected. No private owner data. The fix moves both exits to an unconstrained pinned footer, horizontal normally and stacked at accessibility sizes. It keeps the same test assertions/audit; no issue handler suppresses the failure. 62.1 must not be presented as the final acceptable UI candidate, regardless of Apple processing.

New code, CI/prepare, signed/internal build and physical replay must be recorded separately. One-time 61/62 markers removed before adding a replacement explicit marker. No repeat upload from ordinary code/docs pushes.
