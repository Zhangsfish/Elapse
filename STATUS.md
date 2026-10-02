# STATUS

## Current stage

**S00 — Screen Time feasibility gate**

Status: **CODE / CI PASS — REAL-DEVICE GATES NOT RUN**

The minimal app, Device Activity Monitor extension, Device Activity Report extension, pure-logic tests, reproducible XcodeGen definition, CI, and physical-iPhone checklist are implemented on `codex/s00-screen-time-feasibility`.

Passing code evidence: commit `b18309dfe58508540305d907f549745f5bc0cf13`, [GitHub Actions run 36991441759](https://github.com/Zhangsfish/Elapse/actions/runs/36991441759).

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

Configure development signing and Family Controls capability for the three documented bundle IDs, install on a physical iPhone, and run `audits/S00/REAL_DEVICE_CHECKLIST.md`. Keep Gates A–D `NOT RUN` until that evidence exists.
