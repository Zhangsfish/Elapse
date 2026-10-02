# STATUS

## Current stage

**S00 — Screen Time feasibility gate**

Status: **CODE / CI PASS — TESTFLIGHT ARCHIVE METADATA FIX PENDING MERGE; REAL-DEVICE GATES NOT RUN**

The S00 implementation is on `main` at `b8ef96b7c60f9e47d94d6449d413a9916135184d`.

[TestFlight upload run 37038785574](https://github.com/Zhangsfish/Elapse/actions/runs/37038785574) built `0.1.0 (6.1)` and passed unsigned build/archive plus credential gates, then failed Apple asset validation (exit 70: icon, Info.plist key, orientations). Upload acceptance and processing remain `NOT RUN`.

[Baseline archive inspection run 37040791775](https://github.com/Zhangsfish/Elapse/actions/runs/37040791775) found the root cause: the compiled main app had `UIDeviceFamily=[1,2]` despite the top-level project setting `1`; its iPad icon metadata had no primary icon files, and supported orientations were absent. `Assets.car` existed and contained AppIcon renditions. [Fixed prepare run 37041479260](https://github.com/Zhangsfish/Elapse/actions/runs/37041479260) confirms the final archive has `UIDeviceFamily=[1]`, valid primary AppIcon metadata, `Assets.car` with AppIcon renditions, and portrait plus both landscape orientations.

The fix is on `codex/s00-testflight-archive-metadata`. Its new path-scoped marker triggers one upload after merge to `main`; ordinary pushes do not match that path.

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

Status: **ARCHIVE METADATA PASS — APPLE RETRY PENDING MERGE**

- [x] User-visible app name is `Everwhile`; repository, project, scheme, product, and three Bundle IDs remain `Elapse`-based.
- [x] Secret-free prepare-only CI builds and archives the app plus both extensions without development signing or device registration.
- [x] Only an explicit `workflow_dispatch` upload or the unique one-time main-branch marker can enter the upload step that reads the four existing Apple settings.
- [x] Repository variable and all three App Store Connect secrets are present by name; values were not read or printed. The upload script passed its non-secret format gates.
- [x] The repaired final archive passes device-family, icon, asset-catalog and orientation assertions in secret-free CI.
- [ ] Automatic distribution export/upload: run 37038785574 failed Apple bundle validation before upload acceptance. The repaired archive has not been uploaded.
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

Review and merge the archive-metadata fix PR. Its unique marker automatically performs one retry from `main`. If that retry reaches `VALID`, install Everwhile through TestFlight and run `audits/S00/REAL_DEVICE_CHECKLIST.md`. Gates A–D remain `NOT RUN` until physical-iPhone evidence exists.
