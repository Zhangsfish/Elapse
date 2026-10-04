# ChatGPT restart handoff — Everwhile / Elapse — S01

Updated: 2026-10-05
Repository: `Zhangsfish/Elapse`
User-facing product: **Everwhile**
Internal repo / Xcode / scheme / Bundle IDs remain **Elapse**.

This document is for a fresh ChatGPT conversation. It is a restart map, not the scheduling authority.

**Always read current `STATUS.md` from GitHub before acting.**

At the moment before this handoff was added, main was:
`07b889afe456aa408104b3643b2c8281d3cf99a1`

The handoff commit itself moves main again. Never treat that SHA as permanent.

---

## 1. First action in a fresh ChatGPT conversation

Use the GitHub connector immediately.

Read current main in this order:

1. `AGENTS.md`
2. `STATUS.md` — only current dispatch authority
3. `handoff/CHATGPT_RESTART_S01.md`
4. `docs/WORKFLOW.md`
5. `docs/EXECUTION_PLAN.md`
6. the one prompt STATUS marks READY / IN_PROGRESS
7. the latest accepted audit for the preceding stage
8. current PR metadata / changed files if a task PR exists
9. actual Swift/workflow files touched by the current stage

Also check open PRs before giving instructions.

Old prompts, old audits, reports and old “next action” text are history/evidence only. They never override STATUS.

---

## 2. Fixed collaboration model

The project follows the working model used in `Zhangsfish/lecture-asset`.

### Owner

The owner:
- makes product decisions;
- performs only genuinely necessary iPhone/private-account actions;
- replies to device tests in natural language/screenshots;
- does not manually merge PRs;
- should not click GitHub Actions when Codex/CI can do it;
- should not整理 engineering reports or expose signing secrets.

Environment: Windows + iPhone. Do not assume Mac Console/Xcode access for extension logs.

### Codex

Codex owns implementation of the single active stage:

- sync latest main;
- inspect actual code;
- continue an existing task PR if one exists;
- implement;
- run tests/CI/signing;
- prepare internal TestFlight if needed;
- stay in the same Codex conversation;
- guide device testing one small action at a time;
- receive owner observations, diagnose/fix/retest;
- write `reports/<stage>/...`;
- stop at `READY_FOR_AUDIT`.

Codex must not self-approve, self-merge, unlock later stages, invent owner observations, or mix future-stage work into the current stage.

Codex entry point:
`handoff/CODEX_START.md`

### Cloud ChatGPT

Cloud ChatGPT owns:

- scope and task boundaries;
- independent GitHub audit;
- reading actual diff/full critical source/tests/raw Actions evidence;
- separating evidence layers;
- PASS / PASS_WITH_NOTES / CHANGES_REQUESTED / BLOCKED_* bound to an exact PR head SHA;
- merging the approved exact SHA;
- writing cloud audit;
- updating STATUS;
- unlocking only the next stage.

Do not run a parallel implementation while Codex owns the active stage unless the owner explicitly changes the workflow.

When the owner returns with “READY_FOR_AUDIT”, never accept Codex's summary alone. Audit independently.

---

## 3. Product truth

Everwhile exists to make elapsed time perceptible.

Core principle:
**Awareness before control.**

Product role:
**只报时，不裁判。**

The product should:
- use FamilyControls to select Apps;
- treat selected Apps as one usage pool for pulse thresholds;
- request quiet notifications at configured usage thresholds;
- show truthful retrospective usage through DeviceActivityReport.

Do not turn it into:
- blocking/shielding;
- Screen Time enforcement;
- scores/streaks/gamification;
- shame/coaching;
- account/cloud/analytics/ads/AI.

A native iPhone full-screen Screen Time time-limit prompt appeared during S01-A. The owner explicitly confirmed it was **system Screen Time**, not Everwhile, and does not want that behavior added.

Never add Shield/ManagedSettings blocking unless the owner explicitly changes product direction.

---

## 4. Evidence layers — never blur them

1. SOURCE — static code/semantics
2. UNIT_TEST / CI — compiled and logic tested
3. SIGNED_ARTIFACT — exact exported IPA signatures/profile allowances
4. APPLE_PROCESSING — upload accepted / VALID / internal availability
5. OWNER_REPORT / OWNER_SCREENSHOT — physical iPhone behavior
6. NOT_RUN / SYSTEM_MANAGED — unobserved or OS-managed behavior

Examples:

- `startMonitoring` success ≠ callbacks work.
- `center.activities` contains an activity ≠ today's interval is active.
- `events(for:)` returns 299 ≠ all 299 thresholds will fire.
- notification request accepted ≠ visible banner.
- callback received ≠ exact usage duration.
- callback count × interval ≠ authoritative Screen Time total.
- report page empty ≠ zero selected-App usage.
- App Store Connect VALID ≠ device runtime accepted.

If required P0/P1 evidence is missing, do not PASS.

---

## 5. Current status at handoff

At writing time STATUS says:

**S00 COMPLETE — PASS_WITH_NOTES**
**S01-A COMPLETE — PASS_WITH_NOTES**
**S01-B READY**
**S01-C / S02 / S03 LOCKED**

Current task:
`prompts/S01_B_DAILY_LIFECYCLE.md`

The owner has already been given a Codex startup prompt for S01-B.

If Codex has not started, next owner action is simply to give Codex the S01-B prompt.

If the owner returns with an S01-B PR at READY_FOR_AUDIT, audit that PR immediately instead of re-explaining S01-B.

---

## 6. Accepted history and exact landmarks

### S00-A

PR #14
Reviewed head: `bf5530e22a338150dd45408e4702651bc4711064`
Merged: `044841658fb990324c13224cb592402f0540c80a`
Accepted build: Everwhile `0.1.0 (27.1)`
Audit: `audits/S00/S00_A_AUDIT_2026-10-03.md`

Closed:
- final Family Controls distribution signing;
- individual authorization;
- 2-App selection persistence;
- ordinary notification;
- basic Start→Stop.

Verdict: PASS_WITH_NOTES.

### S00-B

PR #15
Reviewed head: `ee51be3d6e4b76246d5aecc85934c0e53fe33207`
Merged: `0386ee9d35cf3046192a4b2f14d7f2243ebab08d`
Accepted build: `0.1.0 (32.1)`
Audit: `audits/S00/S00_B_AUDIT_2026-10-03.md`

Closed:
- unique experiment identity;
- same-day repeatability;
- App Group callback/request diagnostics;
- selection freeze;
- stale/duplicate isolation;
- first real shared-pool 5-minute pulse.

### S00-C

PR #16
Reviewed head: `35f5102fa2ec98df0729e601663ecbdb2a5b01ce`
Merged: `bba53845b78eb657b0daa29019abb202a29de81a`
Accepted build: `0.1.0 (38.1)`
Real device experiment: `0cb91a51`
Audit: `audits/S00/S00_C_AUDIT_2026-10-04.md`

Closed:
- 5/10/15/20/25/30 independent diagnostics;
- real six-threshold sequence;
- App switching;
- finite Stop behavior;
- out-of-order/duplicate/stale/request-failure logic.

Stale/duplicate did not naturally occur on-device; those remain SOURCE + UNIT_TEST.

### S00-D

PR #17
Reviewed head: `ebaf1c7a23a9f93856428e4df5b6dba71020bf39`
Merged: `3771b556334a5dc1b15e42287183bc9e8f1bef95`
Accepted build: `0.1.0 (41.1)`
Audit: `audits/S00/S00_D_AUDIT_2026-10-04.md`

Closed:
- current user/current iPhone Today;
- local start-of-day→now;
- real selected-App total/per-App/hourly aggregate;
- zero/unavailable distinction in source/tests;
- privacy boundary;
- no fabricated exact sessions.

Owner says Today function/data are correct but UI is “像毛坯、太丑”.

UX debt is recorded:
`reports/S00-D/round-01/UX_FOLLOWUP.md`

Do not fix it during S01. It belongs to S02, after researching strong comparable report UIs/charts.

S00 functional acceptance is complete.

### S01-A

PR #18
Reviewed head: `e7adced2834d3a4831d9b24ff6ae7dc421df68b5`
Merged: `4fbb88be370e1481ec644a5cfbf7823680f0504e`
Accepted build: `0.1.0 (44.1)`
Runtime code: `bac88e961e0a1dcfbf12c4bc5285c182a72a47a8`
Tested/upload SHA: `514ae6958d018bf1d5861f834cbea2efab4a4a97`
Audit: `audits/S01/S01_A_AUDIT_2026-10-04.md`

Closed:
- product interval model separated from S00 six-threshold fixture;
- supported 5/10/15/30/60 minutes, default 5;
- one-activity day-range candidate using 25h-exclusive planning ceiling;
- scalable diagnostics;
- stop-first interval/App selection;
- target-iPhone event dictionary feasibility.

Target iPhone:
- 5m plan: **299 planned / 299 system-registered**
- 15m plan: **99 planned / 99 system-registered**

Reopen persistence: OWNER_REPORT.
Final stopped / interval restored to 5 / two selected Apps: OWNER_REPORT.

This proves the large event dictionary can register on the target iPhone.

It does NOT prove every threshold works all day or that midnight lifecycle is correct.

---

## 7. Critical midnight observation after S01-A

Repository record:
`reports/S01-B/PREIMPLEMENTATION_MIDNIGHT_2026-10-05.md`

Owner captured a natural midnight boundary on accepted build 44.1.

### 23:59
- config short ID `f7bce817`
- generation 8
- interval 5m
- planned 299
- system-registered 299
- state registered
- error none
- callback count 0

### 00:01

Without Stop/Start/config change:
- same config `f7bce817`
- same generation 8
- planned 299
- system-registered 299
- still displayed registered
- error none
- callback count 0

But 44.1 still used `repeats=false`.

Therefore this does NOT prove the new day's usage interval actually began.

It proves:

> registration presence + full event-count readback is not sufficient evidence that the current daily interval is active.

S01-B must keep separate:

1. desired monitoring intent;
2. system registration presence/count;
3. current scheduled interval lifecycle generation/anchor established by `intervalDidStart` or equivalent evidence.

Do not call layer 2 “today is actively measuring”.

The observation was committed on main as:
`07b889afe456aa408104b3643b2c8281d3cf99a1`

---

## 8. Current task — S01-B

Current task:
`prompts/S01_B_DAILY_LIFECYCLE.md`

Intended branch:
`codex/s01-b-daily-lifecycle`

Goal:
turn S01-A's one-day candidate into a daily recurring lifecycle that does not require manual Start each day.

Key requirements:

- product schedule uses `repeats=true`;
- implement observable `intervalDidStart` / `intervalDidEnd`;
- interval generation + anchor;
- duplicate same-cycle start is idempotent;
- new interval clears interval-local receipts/diagnostics but preserves config;
- desired monitoring state separate from actual system registration;
- launch/foreground/explicit refresh reconcile state;
- desired=true + exact registration present → keep same config;
- desired=true + registration missing/mismatch → recover with new config UUID;
- desired=false → never auto-resurrect monitoring;
- authorization blocked/reapproved state machine in SOURCE + UNIT_TEST;
- physically impossible early threshold callback fails closed and does not notify;
- old config callbacks/completions stay stale/fail-closed;
- Today/report privacy boundary unchanged.

S01-B device acceptance is short:

1. new internal build;
2. two selected Apps, interval 5;
3. Start;
4. confirm 299/299 + desired ON + recurring YES + interval generation/anchor;
5. close/reopen App — same config if registration intact;
6. reboot iPhone once;
7. after reboot:
   - registration persisted → same config + 299/299 is acceptable;
   - registration lost → automatic recovery to new config + recovery reason + 299/299 is acceptable;
8. Stop;
9. desired OFF;
10. close/reopen again; monitoring must not auto-resurrect.

S01-B explicitly does NOT require:
- waiting for pulse;
- waiting for midnight;
- revoking Screen Time permission;
- changing system time;
- all-day usage;
- Today redesign.

S01-C owns real recurring midnight rollover, real permission revoke/regrant, timezone/DST residual acceptance.

---

## 9. Reliability rule: premature callbacks

Current iOS 26 developer reports describe DeviceActivity thresholds arriving obviously too early in some cases.

A developer-forum report is not an API contract and must not be treated as proof the owner's device is affected.

Engineering rule chosen for S01-B:

If threshold N arrives physically before interval anchor + N minutes, with a small explicit tolerance, classify it as premature and fail closed:

- no notification;
- no accepted threshold;
- increment safe diagnostic counter.

This guard only rejects physically impossible early callbacks. It does not turn DeviceActivity into a perfect usage clock.

Do not replace Screen Time measurement with wall-clock timers.

---

## 10. How cloud ChatGPT should audit a Codex PR

### A. Lock project state

Read:
- current main SHA;
- current STATUS;
- PR metadata/base/head/draft/mergeability;
- exact current head SHA;
- changed filenames;
- comments/reviews.

Refuse to merge if head moves after review.

### B. Compare SHA layers

Identify:
- implementation/runtime SHA;
- tested SHA;
- TestFlight upload SHA;
- final evidence-only head.

Use Git compare to prove whether later commits changed runtime source or only reports/markers/status.

### C. Read complete critical source

For S01-B likely:
- `Shared/PulsePlan.swift`
- `Shared/PulseExperiment.swift`
- `Shared/PulseExperimentStore.swift`
- `App/ElapseModel.swift`
- `MonitorExtension/ElapseMonitorExtension.swift`
- lifecycle/recovery tests
- workflow changes
- S01-B reports.

Do not audit only patch snippets when surrounding state-machine code matters.

### D. Raw Actions

Check run metadata and exact head SHA.

Check raw logs for:
- Swift test counts / zero failures;
- Build/Archive success;
- effective entitlements;
- distribution export;
- exact signed IPA audit;
- IPA SHA-256;
- Family Controls claims/profile allowance;
- App Group claims/profile allowance;
- upload accepted;
- processing VALID;
- INTERNAL_ONLY;
- IN_BETA_TESTING;
- internal group assigned.

Prepare-only must show upload/sign skipped.

### E. Device evidence

Read:
- `reports/<stage>/DEVICE_OBSERVATIONS.md`
- `TEST_RESULTS.json`
- `DELIVERY.md`

Separate OWNER_REPORT / OWNER_SCREENSHOT / SOURCE+UNIT_TEST / NOT_RUN.

Do not require screenshots containing App identities/usage to be committed publicly.

### F. Verdict

Allowed:
- PASS
- PASS_WITH_NOTES
- CHANGES_REQUESTED
- BLOCKED_ENV
- BLOCKED_OWNER

Bind approval to exact reviewed head.

If approved:
- comment audit verdict;
- merge with expected-head guard;
- write formal audit;
- update STATUS;
- unlock only next stage;
- verify main actually moved.

---

## 11. Current signing/distribution facts

Reuse existing Apple/GitHub infrastructure.

Bundle IDs:
- `com.zhangsfish.elapse`
- `com.zhangsfish.elapse.monitor`
- `com.zhangsfish.elapse.report`

GitHub variable:
- `APPLE_TEAM_ID`

Existing secrets:
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`

Do not ask owner to paste private keys or recreate credentials without hard evidence.

Accepted distribution chain repeatedly verifies:
- Family Controls claims/profile allowances on main/Monitor/Report;
- App + Monitor App Group claim/profile allowance;
- Report App Group NOT_REQUIRED;
- exact signed IPA before upload;
- same audited IPA uploaded.

Historical 19.1 ITMS-90897 is closed by later accepted builds. Do not reopen without new regression evidence.

---

## 12. Privacy boundary

App Group may contain only app-owned:
- config/experiment UUID;
- selected-App count;
- interval/plan metadata;
- lifecycle/callback/request diagnostics;
- safe recovery/error counters.

Do not put into App Group:
- FamilyActivitySelection tokens;
- App names;
- bundle IDs;
- DeviceActivityReport usage totals;
- per-App usage;
- hourly usage;
- exact sessions.

Protected report data stays inside DeviceActivityReport extension.

---

## 13. Locked later stages

### S01-C — LOCKED
Real acceptance for:
- recurring midnight rollover on S01-B implementation;
- real permission revoke/regrant;
- timezone/DST residual behavior;
- remaining lifecycle ambiguity.

### S02 — LOCKED
Production UX:
- remove test/diagnostic-looking UI;
- simplify flow;
- Chinese/English product wording;
- research strong comparable report UIs;
- redesign Today hierarchy/charts;
- fix display precision such as positive sub-minute bucket showing `0m`.

Do not forget owner's “Today 像毛坯” feedback, but do not mix S02 into S01.

### S03 — LOCKED / OWNER_RELEASE_REQUIRED
Public distribution/App Review/region/compliance.

Internal TestFlight permission does not authorize public release.

---

## 14. Communication style

Keep technical responses direct.

After audit, tell the owner:
- verdict;
- what was actually proven;
- what remains unproven;
- exact merge/main SHA;
- next action.

The owner often wants a copy/paste-ready Codex prompt.

Do not make them read raw logs unless necessary.

Do not ask them to repeat information already in STATUS/reports.

---

## 15. Immediate next action in a fresh ChatGPT conversation

1. Read current GitHub state.
2. If STATUS still says **S01-B READY** and no S01-B PR exists:
   - do not implement in cloud;
   - tell owner repo is ready for Codex;
   - current task is `prompts/S01_B_DAILY_LIFECYCLE.md`.
3. If an S01-B PR exists:
   - if Codex is working / WAITING_FOR_OWNER_TEST, do not parallel-implement;
   - if READY_FOR_AUDIT, independently audit it.
4. If STATUS has advanced, ignore this snapshot and follow current STATUS.
