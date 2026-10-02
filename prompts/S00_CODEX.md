# S00 Codex Task — Screen Time Feasibility Gate

Repository: `Zhangsfish/Elapse`

## Mission

Implement the smallest real iOS prototype that can answer whether Elapse is technically viable on Apple's public Screen Time APIs.

Elapse has one product thesis:

> Make elapsed time perceptible. Do not control the user.

Do **not** build a general productivity app.

## Read first

Read these files in this exact order before changing anything:

1. `AGENTS.md`
2. `STATUS.md`
3. `docs/PRODUCT_SPEC.md`
4. `docs/APPLE_PLATFORM_NOTES.md`
5. `docs/TECHNICAL_PLAN.md`
6. this file

Treat them as the product contract.

Before implementation, verify all Screen Time symbols/behavior against the current Apple SDK and current Apple Developer documentation. If repository docs and the current SDK conflict, preserve product intent but follow the current public API, and document the conflict.

## Branch

Create and work on:

`codex/s00-screen-time-feasibility`

Do not work directly on `main`.

## S00 scope

Build a minimal Swift / SwiftUI iOS application with the required Screen Time extensions.

The prototype must validate two independent paths:

### Path A — usage pulse

The user can:

1. request **individual** Family Controls authorization;
2. open Apple's `FamilyActivityPicker`;
3. select multiple applications;
4. start monitoring;
5. use the selected applications normally.

The selected applications must be configured as **one logical usage pool**.

For S00, configure cumulative usage thresholds at:

- 5 minutes
- 10 minutes
- 15 minutes
- 20 minutes
- 25 minutes
- 30 minutes

When a threshold callback is received, the monitor extension must request a local notification.

Target notification copy:

Title:
`5 minutes passed`

Body example:
`Selected apps today: 20 minutes`

However:

- Derive the cumulative minute value from the threshold/event identity.
- Never calculate authoritative usage as `callback count × 5`.
- If callback history makes “another clean 5 minutes passed” ambiguous, use safer copy such as:
  - Title: `20 minutes`
  - Body: `Selected apps have reached 20 minutes today.`

The extension must tolerate duplicate callbacks without creating misleading duplicate pulses where reasonably possible.

### Path B — truthful Today report

Add the minimum Device Activity Report integration necessary to display real data Apple provides.

The report should attempt to show:

1. per-application usage duration for the current day;
2. time-of-day distribution at the finest **truthful supported aggregate interval** practical for S00 (hourly is acceptable if that is what the public report API provides reliably).

Important:

- Do not invent exact app-open/app-close session boundaries.
- Do not label an hourly bucket as a continuous one-hour session.
- Do not bypass the report-extension privacy sandbox.
- Do not make EU-only `approvedWithDataAccess` or `activityData(filteredBy:using:)` a baseline dependency.
- Structured export is explicitly out of scope for S00.

## Required targets

Use the smallest architecture that works.

Expected conceptual targets:

1. Main iOS app
2. `DeviceActivityMonitor` app extension
3. `DeviceActivityReport` app extension

Do **not** add:
- ManagedSettings shields;
- app blocking;
- accounts;
- servers;
- analytics SDKs;
- ads;
- AI;
- Apple Watch;
- accessibility monitoring;
- VPN/network inspection;
- screen recording.

## Project reproducibility

The repository is currently documentation-only.

Create a reproducible iOS project definition suitable for a user who develops primarily through GitHub/Codex and does not rely on a local Mac.

Preferred approach:
- use a checked-in XcodeGen `project.yml`, unless the current tooling makes another reproducible text-based project definition clearly better;
- generate the Xcode project in CI rather than committing fragile user-specific Xcode state.

Choose sensible bundle identifiers under a consistent namespace such as:

- `com.zhangsfish.elapse`
- `com.zhangsfish.elapse.monitor`
- `com.zhangsfish.elapse.report`

If these identifiers conflict with actual signing requirements later, document the exact identifiers that the user must create/change. Do not stop S00 compile work solely because distribution signing is unavailable.

Do not hard-code a personal Apple Team ID or secret.

## Entitlements

Configure only the capabilities actually needed for S00.

Baseline:
- Family Controls on the main app;
- Family Controls on Screen Time API extensions where Apple requires it;
- notification permission requested by the main app.

Do **not** enable the Family Controls App and Website Usage entitlement for S00.

If App Groups are not required, do not add them merely for convenience.

If you determine an App Group is genuinely necessary, explain why before using it and use it only for Elapse-owned configuration/diagnostic state — never to exfiltrate protected report data.

## Minimal UI

Do not spend time polishing.

One main screen is enough if it exposes:

- authorization status;
- button to request authorization;
- button / row to choose apps;
- count of selected apps;
- start monitoring;
- stop monitoring;
- current S00 pulse configuration;
- Today report entry/view;
- obvious diagnostic/error text when setup is incomplete.

Keep wording neutral. No productivity score, guilt, coaching, streaks, or blocking language.

## Monitoring semantics

Use Apple's usage accounting, not a wall-clock repeating timer.

The behavior under test is:

- selected App A used 2 minutes;
- selected App B used 3 minutes;
- cumulative selected usage reaches 5 minutes;
- 5-minute event becomes eligible.

Time spent in unselected apps or with the device unused must not be intentionally counted as selected-app usage.

Configure the Device Activity schedule in the most correct public-API way for a daily usage experiment. Verify the current SDK semantics rather than copying stale snippets.

Explicitly choose and document the behavior of `includesPastActivity` (or its current equivalent). S00 should have deterministic, understandable behavior when monitoring begins partway through a day.

## Diagnostics

S00 must make failures inspectable.

At minimum, log:

- monitoring start/stop attempts;
- configured event identifiers / thresholds;
- monitor interval callbacks;
- threshold event callbacks;
- callback receipt timestamps;
- notification request success/failure;
- authorization state transitions;
- report configuration failures.

Use `Logger` / OSLog or another local first-party mechanism.

Do not log private app identities unnecessarily.

If you add an in-app diagnostic panel, keep it minimal.

## Pure-logic tests

Add unit tests for logic that does not require Screen Time runtime behavior, including at least:

- threshold generation: 5/10/15/20/25/30;
- threshold/event identifier parsing;
- notification copy for known threshold;
- duplicate-event/idempotency decision logic if implemented outside the extension callback itself;
- current-day date interval/filter helper logic.

Tests must not pretend to validate Screen Time runtime delivery.

## CI

Add a GitHub Actions workflow on a hosted macOS runner that:

1. installs/generates the project definition if needed;
2. builds the app and extensions for an iOS Simulator with signing disabled where appropriate;
3. runs feasible unit tests;
4. fails on real compile/test failures.

Do not require Apple secrets for normal CI compile/test.

If Screen Time frameworks cannot execute meaningfully on Simulator, say so; compile them but reserve behavior gates for real device.

## Real-device acceptance plan

Create:

`audits/S00/REAL_DEVICE_CHECKLIST.md`

It must be short enough for a human to actually run.

Include at least these scenarios:

### Test 1 — authorization / picker
- authorize self;
- select at least two apps;
- start monitoring.

### Test 2 — shared pool
- use selected App A for roughly 2 minutes;
- use selected App B until total selected usage crosses 5 minutes;
- record whether 5-minute callback/notification occurs.

### Test 3 — unselected time
- spend meaningful time in an unselected app or locked;
- return to selected apps;
- verify observed behavior does not look like unselected wall-clock time was counted.

### Test 4 — sequential thresholds
- continue until 10, 15, 20, 25, and 30 minute boundaries;
- record early / late / missing / duplicate callbacks separately.

### Test 5 — app switching / lock
- switch repeatedly between selected and unselected apps;
- lock/unlock;
- record behavior.

### Test 6 — restart / authorization
- stop and restart monitoring;
- relaunch the app;
- if practical, reboot device;
- revoke/regrant authorization;
- record stale/duplicate behavior.

### Test 7 — report truthfulness
- open Today report;
- compare rough observed use with per-app totals;
- inspect hourly/time-bucket view;
- confirm UI does not imply precision the API does not provide.

The checklist must explicitly distinguish:
- OS threshold callback received;
- local notification request accepted;
- visible banner/alert actually observed by the user.

## Evidence document

Create:

`audits/S00/RESULTS.md`

Initially record:
- code/CI evidence;
- what was actually run;
- what remains `NOT RUN`;
- signing/entitlement blockers;
- real-device results only if they were truly performed.

Never mark a hardware gate PASS from code inspection or Simulator.

## Apple distribution blocker

The repository user already has an Apple Developer Program membership, but that does not imply the new Elapse App ID/extensions already have Family Controls distribution approval.

Document the exact App IDs / extensions for which Family Controls distribution entitlement will need to be requested.

Do not ask for or expose private signing keys.

## Documentation updates

Before opening the PR:

1. Update `STATUS.md`.
2. Add any verified current-platform corrections to `docs/APPLE_PLATFORM_NOTES.md`.
3. Do not broaden `docs/PRODUCT_SPEC.md` beyond product decisions supported by this task.
4. Keep docs concise; do not duplicate the same explanation across many files.

## Definition of done

S00 implementation work is complete when:

- app + monitor extension + report extension exist;
- project generation is reproducible;
- simulator build succeeds in hosted CI, or an exact framework/toolchain blocker is documented with evidence;
- pure logic tests pass;
- monitoring and report code paths compile against the current SDK;
- real-device checklist exists;
- `STATUS.md` accurately distinguishes PASS / BLOCKED / NOT RUN;
- a PR is open from `codex/s00-screen-time-feasibility` to `main`.

S00 itself is **not product-PASS** until the real-device monitoring gates have been run on an iPhone.

## Working style

Do not stop for aesthetic questions or ask the user to choose architecture details that can be resolved from the product contract.

If a platform ambiguity is material:
1. check Apple's current docs and current SDK;
2. choose the smallest compliant implementation;
3. document the assumption and how the real-device test will falsify it.

If signing or entitlement approval blocks a final device run, finish every independent task and leave the user with the smallest concrete next action list.

## Final response format

Return exactly these operational facts at the end:

1. PR URL
2. Branch
3. Tested commit SHA
4. CI/build/test status
5. S00 gates that are PASS
6. S00 gates that are NOT RUN / BLOCKED
7. The exact next actions required from the user, if any
