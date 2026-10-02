# STATUS

## Current stage

**S00 — Screen Time feasibility gate**

Status: **CODE / CI / TESTFLIGHT PREPARE PASS — UPLOAD BLOCKED_OWNER; REAL-DEVICE GATES NOT RUN**

The minimal app, Device Activity Monitor extension, Device Activity Report extension, pure-logic tests, reproducible XcodeGen definition, ordinary CI, TestFlight prepare/upload workflow, and physical-iPhone checklist are implemented on `codex/s00-screen-time-feasibility`.

Passing implementation evidence: commit `e69c18f13b50f766746d7bade32c06172141e86c`; [ordinary CI run 37028810386](https://github.com/Zhangsfish/Elapse/actions/runs/37028810386) and secret-free [TestFlight prepare run 37028811778](https://github.com/Zhangsfish/Elapse/actions/runs/37028811778).

The prepare run passed the Xcode 26 guard, helper validation, App Icon and privacy-manifest checks, unsigned generic-iPhone Release build, and unsigned distribution archive inspection. The upload step was correctly skipped. No App Store Connect signing or TestFlight upload has run because the four required GitHub settings are not configured.

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

Status: **PREPARE PASS — EXPLICIT UPLOAD BLOCKED_OWNER**

- [x] User-visible app name is `Everwhile`; repository, project, scheme, product, and three Bundle IDs remain `Elapse`-based.
- [x] Secret-free prepare-only CI builds and archives the app plus both extensions without development signing or device registration.
- [x] Manual `upload` is the only path that reads `APPLE_TEAM_ID`, `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, and `APP_STORE_CONNECT_PRIVATE_KEY`.
- [ ] Automatic App Store Connect distribution signing and TestFlight upload: `BLOCKED_OWNER` until those four GitHub settings exist.
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

After this PR is reviewed and merged, configure the four documented GitHub repository settings, manually dispatch `S00 TestFlight preparation and explicit upload` on `main` with `operation=upload`, install the resulting build through TestFlight, and run `audits/S00/REAL_DEVICE_CHECKLIST.md`. Do not register a device or switch to development/ad-hoc signing. Keep Gates A–D `NOT RUN` until physical-iPhone evidence exists.
