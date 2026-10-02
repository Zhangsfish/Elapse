# STATUS

## Current stage

**S00 — Screen Time feasibility gate**

Status: **CODE / CI PASS — TESTFLIGHT RETRY FIX PENDING MERGE; REAL-DEVICE GATES NOT RUN**

The S00 implementation and TestFlight workflow are merged to `main` at `f8a9ce2a8fd094173584ff196db11c751618448d`.

Direct dispatch succeeded for [TestFlight run 37035044676](https://github.com/Zhangsfish/Elapse/actions/runs/37035044676), version `0.1.0`, build `4.1`. The unsigned archive and metadata checks passed. App Store Connect then rejected the bundle during asset validation (`Invalid Bundle` plus a missing bundle key), before upload acceptance or processing. No missing setting, credential-format, cloud-signing-permission, Family Controls entitlement, or provisioning-profile category was reported.

The retry fix is on `codex/s00-testflight-appicon-fix`: explicit iPhone icon slots, `CFBundleIconName=AppIcon`, archive assertions, improved safe diagnostics, and a path-scoped one-time upload marker. Merging that marker to `main` triggers one retry without making ordinary main pushes upload builds.

This is not a product feasibility PASS. No Screen Time runtime behavior has been tested on a physical iPhone.

## Product question

Can iOS reliably support the smallest useful Elapse loop?

> Select a group of apps → accumulate their actual foreground usage → notify at 5-minute usage increments → show a truthful daily usage report.

## S00 gates

### Gate A — Authorization and selection: NOT RUN

- [ ] Individual Family Controls authorization succeeds on a real iPhone.
- [ ] User can select multiple apps using Apple's system picker.
- [ ] Selection persists locally without revealing unnecessary app identity.

### Gate B — Shared usage thresholds: NOT RUN

The code registers one selected-application pool at 5/10/15/20/25/30 minutes with `includesPastActivity=false`, but these behavior claims require a physical iPhone:

- [ ] Two or more selected apps contribute to the same usage pool.
- [ ] Time spent outside the selected set does not count as selected-app usage.
- [ ] Threshold callbacks are logged with threshold identity and wall-clock receipt time.
- [ ] Duplicate / early / delayed callback behavior is observable rather than hidden.

### Gate C — Notification path: NOT RUN

- [ ] Notification permission flow works on a physical iPhone.
- [ ] A threshold callback can request a local notification.
- [ ] Notification content reports the named cumulative threshold truthfully.
- [ ] Request acceptance and a visibly observed banner are recorded separately.

### Gate D — Report path: NOT RUN

- [ ] Device Activity Report renders real data in the app.
- [ ] It shows per-app daily usage using Apple's opaque labels.
- [ ] It shows truthful hourly selected-app aggregates.
- [ ] Physical-device inspection confirms the UI does not imply exact sessions.

### Gate E — CI / reproducibility: PASS

- [x] Repository contains a reproducible XcodeGen project definition.
- [x] Standard hosted `macos-26` CI generates the project, builds the app and both extensions for iOS Simulator with signing disabled, and runs all six pure-logic tests.
- [x] Signing, entitlement approval, and real-device blockers are documented separately from compile/test results.

## TestFlight delivery path

Status: **ARCHIVE PASS — APP STORE BUNDLE VALIDATION FAILED; RETRY FIX PENDING MERGE**

- [x] User-visible app name is `Everwhile`; repository, project, scheme, product, and three Bundle IDs remain `Elapse`-based.
- [x] Secret-free prepare-only CI builds and archives the app plus both extensions without development signing or device registration.
- [x] Only an explicit `workflow_dispatch` upload or the unique one-time main-branch marker can enter the step that reads `APPLE_TEAM_ID`, `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, and `APP_STORE_CONNECT_PRIVATE_KEY`.
- [x] Repository variable and all three App Store Connect secrets are present by name; values were not read or printed. The upload script passed its non-secret format gates.
- [ ] Automatic distribution export/upload: run 37035044676 reached Apple bundle validation but failed before upload acceptance. No signing/entitlement/provisioning failure category appeared.
- [ ] App Store Connect processing reaches `VALID`: `NOT RUN`.

The owner reports Family Controls Development + Distribution enabled for all three App IDs and the Everwhile App Store Connect record created. A successful export/upload is still required to validate that account-side configuration.

## Explicitly out of scope for S00

- polished UI;
- App Store submission;
- blocking/shielding apps;
- exact per-session start/end export;
- CSV/JSON export of protected Screen Time report data;
- EU-only app-and-website usage data access;
- Apple Watch;
- cloud sync;
- accounts;
- AI;
- subscriptions;
- analytics;
- gamification.

## Next action

Merge the App Icon validation-fix PR. Its unique marker automatically performs one retry from `main`; do not manually run Actions. If that retry reaches `VALID`, install Everwhile through TestFlight and run `audits/S00/REAL_DEVICE_CHECKLIST.md`. Do not register a device or switch to development/ad-hoc signing. Keep Gates A–D `NOT RUN` until physical-iPhone evidence exists.
