# STATUS

## Current stage

**S00 — Screen Time feasibility gate**

Status: **READY**

No product code has been implemented yet.

## Product question

Can iOS reliably support the smallest useful Elapse loop?

> Select a group of apps → accumulate their actual foreground usage → notify at 5-minute usage increments → show a truthful daily usage report.

## S00 gates

### Gate A — Authorization and selection
- [ ] Individual Family Controls authorization succeeds on a real iPhone.
- [ ] User can select multiple apps using Apple's system picker.
- [ ] Selection persists locally without revealing unnecessary app identity.

### Gate B — Shared usage thresholds
Configure test thresholds at:
- 5 min
- 10 min
- 15 min
- 20 min
- 25 min
- 30 min

Validate:
- [ ] Two or more selected apps contribute to the same usage pool.
- [ ] Time spent outside the selected set does not count as selected-app usage.
- [ ] Threshold callbacks are logged with threshold identity and wall-clock receipt time.
- [ ] Duplicate / early / delayed callback behavior is observable rather than hidden.

### Gate C — Notification path
- [ ] Notification permission flow works.
- [ ] A threshold callback can request a local notification.
- [ ] Notification content reports the reached cumulative usage threshold truthfully.
- [ ] Delivery-request success is distinguished from “user visibly saw the banner”.

### Gate D — Report path
- [ ] Device Activity Report renders in the app.
- [ ] It can show per-app daily usage using Apple's report APIs.
- [ ] It can show honest time-distribution buckets supported by the API.
- [ ] UI does not present aggregate buckets as exact app-open/app-close sessions.

### Gate E — CI / reproducibility
- [ ] Repository contains a reproducible iOS project/build definition.
- [ ] Hosted macOS CI can build and run all feasible automated tests.
- [ ] Signing/entitlement-only blockers are documented separately from compile/test failures.

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

Execute `prompts/S00_CODEX.md`.

After Codex completes the branch/PR, perform the real-device checklist before deciding whether S00 is PASS.
