# ChatGPT restart handoff — Everwhile / Elapse

Updated: 2026-10-03
Repository: `Zhangsfish/Elapse`
User-facing product: **Everwhile**
Internal repo / Xcode / scheme / Bundle IDs remain **Elapse**.

This document is for a fresh ChatGPT conversation. It is a restart map, not a permanent status snapshot. **Always inspect current GitHub state before acting.**

## 1. First action in a new ChatGPT conversation

Use the GitHub connector immediately. Do not rely only on this handoff or old chat memory.

Read in this order from the current default branch:

1. `AGENTS.md`
2. `STATUS.md` — current scheduling authority
3. `docs/WORKFLOW.md`
4. `docs/EXECUTION_PLAN.md`
5. the one task that STATUS marks READY / IN_PROGRESS
6. the audit/readiness file referenced by that task
7. `docs/PRODUCT_DECISIONS.md` and `docs/PRODUCT_SPEC.md` when product behavior is relevant
8. actual Swift / workflow files touched by the current task

Also list current open PRs before giving instructions. Historical prompts, old audits and old “Next action” paragraphs are evidence only; they do not override current STATUS.

At the time this handoff was written, planning-reset PR #12 was merged as:
`b2a2e85e57d41a284d60ab5ad028662070efa203`.

The then-current active task was:
`prompts/S00_A_DEVICE_FOUNDATION.md`.

If STATUS has changed since then, follow STATUS instead.

## 2. Required collaboration model

This project now deliberately follows the working model used in `Zhangsfish/lecture-asset`.

### Owner
- makes product decisions;
- performs only genuinely necessary iPhone / private-account actions;
- can answer device observations in natural language;
- should not be asked to整理 engineering reports, manually merge PRs, or click GitHub Actions if agents/tools can do it.

### Codex
- implements the single active stage;
- runs tests / CI / signing checks;
- prepares internal TestFlight builds when needed;
- stays in the same Codex conversation and guides the owner **one small device action at a time**;
- receives the owner's observation, diagnoses, fixes, rebuilds and retests;
- writes `reports/<stage>/...`;
- stops at `READY_FOR_AUDIT`;
- does not self-approve, self-merge or unlock the next stage.

### ChatGPT cloud
- maintains scope/tasks/audits;
- reads actual code, PR diff, CI runs/logs and reports;
- does not accept a Codex summary as proof by itself;
- gives PASS / PASS_WITH_NOTES / CHANGES_REQUESTED / BLOCKED_* bound to the reviewed SHA;
- merges the approved exact SHA through GitHub when possible;
- updates STATUS / unlocks the next stage;
- does **not** run a parallel implementation/device-test workflow while Codex owns the active task, unless the owner explicitly changes this working model.

Only ask the owner to do something when the action genuinely requires the physical phone or the owner's private Apple account. Be explicit about why.

## 3. Product truth

Everwhile exists to make elapsed time perceptible.

Core principle:
**Awareness before control.**

Product role:
**只报时，不裁判。**

Current product shape:
- user grants individual Family Controls authorization;
- user selects applications with Apple's picker;
- selected apps conceptually form one usage pool;
- usage thresholds should produce quiet time-passing notifications;
- the app later shows truthful retrospective usage through DeviceActivity reporting.

Do not turn it into:
- blocking / shielding;
- digital detox policing;
- scores / streaks / gamification;
- habit coaching;
- accounts / cloud backend;
- analytics / ads;
- AI assistant.

Do not fabricate exact app-open/app-close sessions from aggregate Screen Time data.
Do not derive authoritative usage as callback count × pulse interval.

## 4. Current known technical baseline

The installed historical prototype is Everwhile `0.1.0 (19.1)`.

Historical implementation SHA for that build:
`60a15650d6791ef081f6d8aa402cfb48d3a03ff1`.

Historical upload workflow:
GitHub Actions run `37105502155`.

That run reported:
- upload accepted;
- App Store Connect processing `VALID`.

The owner later showed an Apple delivery email for the same build with:
`ITMS-90897 Missing Entitlement`,
stating the main `Elapse.app` was missing
`com.apple.developer.family-controls`
while containing both the Monitor and Report extensions.

Therefore:
- upload accepted / processing VALID = historical fact;
- final Family Controls signing correctness = **not closed**;
- do not repeat the old claim that distribution signing is fully solved.

The owner has reported that build 19.1 is installed on the physical iPhone.
No Screen Time runtime behavior should be inferred from installation alone.

Existing Apple/GitHub configuration:
- App IDs:
  - `com.zhangsfish.elapse`
  - `com.zhangsfish.elapse.monitor`
  - `com.zhangsfish.elapse.report`
- owner previously configured Family Controls Development + Distribution for all three;
- GitHub variable:
  - `APPLE_TEAM_ID`
- GitHub secrets:
  - `APP_STORE_CONNECT_KEY_ID`
  - `APP_STORE_CONNECT_ISSUER_ID`
  - `APP_STORE_CONNECT_PRIVATE_KEY`

Do not ask for the private key contents or recreate these settings without evidence that they are the blocker.
Do not register a UDID or switch to development/ad-hoc installation merely to avoid TestFlight signing issues.

## 5. What is actually implemented vs proven

At the planning reset, static source inspection found:

### Implemented in source, but not yet device-accepted
- individual Family Controls authorization;
- notification permission request;
- `FamilyActivityPicker`;
- local selection persistence;
- start/stop DeviceActivity monitoring;
- six test thresholds at 5/10/15/20/25/30 minutes;
- monitor extension requesting local notifications after threshold callbacks;
- DeviceActivityReport host and report extension;
- per-application usage aggregation and hourly aggregate rows.

### Not yet proven on the owner's iPhone
- authorization success;
- selecting multiple apps and persistence after relaunch;
- shared-pool threshold behavior;
- callback timing/reliability;
- actual threshold notification visibility;
- Today report rendering real data.

### Known limitations / findings
- current pulse plan stops at 30 minutes; it is not yet an all-day every-five-minute product;
- same-day stop/start dedup identity is unsafe because receipt identity is date + event only;
- changing selection while monitoring can leave registered monitor configuration and current UI selection inconsistent;
- extension callback diagnostics currently live mainly in OSLog, which is not a usable acceptance path for a Windows + iPhone owner;
- `includesPastActivity=false` means threshold usage since monitoring start, while Today is natural-day reporting; wording must not blur these scopes;
- selection persistence error could be overwritten by later status clearing;
- Today report still needs separate device acceptance and clear loading/empty/error semantics.

Canonical detailed review:
`audits/S00/READINESS_REVIEW_2026-10-03.md`.

## 6. Current staged execution plan

Do not skip stages just because code compiles.

### S00-A — device foundation
Current task at handoff time.

Scope:
- close final Family Controls signed-artifact risk;
- verify effective `CODE_SIGN_ENTITLEMENTS` and final distribution-signed app + extensions;
- minimal readable authorization/selection/notification state;
- selection persistence;
- clearly labeled ordinary test notification that does **not** pretend to be a Screen Time threshold notification;
- Codex then guides owner through:
  authorization → choose two apps → relaunch/persistence → ordinary notification self-test.

No five-minute app-usage test yet.
No Today acceptance yet.

### S00-B — first real pulse
Locked until S00-A cloud audit passes.

Must solve:
- shared selected-app pool;
- first real 5-minute threshold;
- practical callback/request observability;
- same-day repeat-test identity/dedup;
- selection/config consistency.

### S00-C — 10–30 minute sequence
Locked.
Validate sequential threshold behavior, switch/stop/delay/duplicate semantics.

### S00-D — real Today report
Locked.
Validate real per-app usage and hourly aggregates without false precision.

### S01 — all-day usable loop
Locked.
Implement beyond 30 minutes, configurable interval, day/restart/permission recovery.

S02/S03 are later product/release stages and remain locked unless STATUS says otherwise.

Canonical plan:
`docs/EXECUTION_PLAN.md`.

## 7. How the new ChatGPT should inspect GitHub

When the owner brings a Codex result / PR:

1. Read current `STATUS.md`.
2. Fetch PR metadata and exact head SHA.
3. Read the PR diff / changed filenames.
4. Read the complete versions of critical changed files, not just patch fragments when behavior depends on surrounding code.
5. Inspect actual GitHub Actions workflow runs for the tested SHA.
6. Inspect relevant job logs for claims such as signing, upload, processing or tests.
7. Read Codex evidence under `reports/<stage>/...`.
8. Compare reported device observations with the task's acceptance criteria.
9. Separate:
   - SOURCE
   - GENERATED
   - SIGNED_ARTIFACT
   - APPLE_PROCESSING
   - TESTER_ACCESS
   - INSTALLED
   - DEVICE_OBSERVED
10. Never promote evidence from one layer into another.

If required evidence is missing, issue a focused返工 instruction on the same PR/stage. Do not unlock the next stage.

If the exact reviewed SHA passes:
- merge it through GitHub if the connector supports the action;
- update audit/status through the repository workflow;
- then dispatch only the next stage.

Do not ask the owner to manually merge/run Actions when ChatGPT/Codex tooling can do it.

## 8. Immediate next action at handoff time

At the moment this document was authored, the owner had not yet supplied a completed S00-A Codex delivery.

Therefore a fresh ChatGPT should first determine current GitHub state:
- if no S00-A implementation PR exists, give the owner the short Codex start prompt below;
- if a S00-A PR exists, audit it instead of telling Codex to start over;
- if STATUS already advanced, follow the new stage.

Short Codex start prompt:

```text
继续 Zhangsfish/Elapse。

先同步最新 main，然后严格按仓库事实源工作：
AGENTS.md → STATUS.md → handoff/CODEX_START.md → docs/WORKFLOW.md → docs/EXECUTION_PLAN.md → STATUS 指定的当前任务。

一次只做 STATUS 当前 READY/IN_PROGRESS 的阶段。
按仓库约定：你负责实现、CI/内部 TestFlight、并在同一 Codex 对话里一次一个动作带我做 iPhone 测试；我只反馈观察；云端 ChatGPT 负责审核、合并和解锁下一阶段。

不要重跑旧的 prompts/S00_CODEX.md，不要越级，不要让我手动点 GitHub Actions/merge，不要让我提供 Apple 私钥/UDID。

如果当前仍是 S00-A，就执行 prompts/S00_A_DEVICE_FOUNDATION.md。
先修工程/签名/可测试性，再带我做授权、选两个 App、重启保留和普通测试通知；本轮不要让我刷 App 5/30 分钟，不验收 Today。

完成后给 PR、code/tested/upload SHA、version/build、CI、设备结果、reports 证据路径，停在 READY_FOR_AUDIT。
```

## 9. Important behavioral correction for the new ChatGPT

Earlier in development, cloud ChatGPT sometimes directly implemented fixes and simultaneously told the owner to run full device tests. The owner explicitly rejected that mode.

Do not repeat it.

The desired loop is:
**Codex implements + guides device test → owner reports observations → Codex fixes/reports → ChatGPT audits/merges/dispatches.**

If the owner says “Codex says …”, first inspect the actual repository/PR evidence before deciding whether it is correct.
