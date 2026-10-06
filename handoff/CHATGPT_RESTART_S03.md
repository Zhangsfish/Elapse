# ChatGPT restart handoff — S03 App Store release preparation

Updated: 2026-10-07
Purpose: start a new cloud-ChatGPT conversation without losing the Everwhile / Elapse development and release context.

> This document is a restart aid, not scheduling authority.
> Always re-read current `main` and `STATUS.md` first. If GitHub has moved, current GitHub state wins.

---

## 1. Repository

GitHub:

`Zhangsfish/Elapse`

Product name:

**Everwhile**

Original repo/project name remains Elapse in several technical identifiers.

### Main SHA when this handoff was written

Before adding this handoff, current main was:

`e63cbe8c6327ff5e1e0bed1a209800c7ef661a4a`

The commit that adds this handoff will move main again. Therefore do **not** use the SHA above as dispatch authority.

---

## 2. New-conversation read order

On restart, use the GitHub connector and read in this order:

1. current `main` SHA;
2. `AGENTS.md`;
3. `STATUS.md` — **the only scheduling authority**;
4. this file: `handoff/CHATGPT_RESTART_S03.md`;
5. `docs/WORKFLOW.md`;
6. `docs/EXECUTION_PLAN.md`;
7. `audits/S02/S02_B_AUDIT_2026-10-06.md`;
8. `docs/S03_APP_STORE_RELEASE_PLAN.md`;
9. `docs/S03_SCREENSHOT_PRODUCTION.md`;
10. `prompts/S03_A_APP_STORE_PREFLIGHT.md`;
11. current open PRs;
12. if S03-A has already started, read its actual branch, reports, CI and changed files before giving instructions.

Do not infer progress from this handoff alone.

---

## 3. Collaboration model

Keep the established workflow.

### Codex

Codex performs the currently unlocked implementation/preparation task:

- creates/updates the single active PR;
- implements scripts/docs/assets;
- runs CI;
- uses GitHub-hosted macOS/Xcode where needed;
- prepares App Store assets;
- records reports/evidence;
- stops at the task's explicit owner-review gate or `READY_FOR_AUDIT`.

Codex must not self-approve future stages.

### Owner

The owner only does things that genuinely require:

- private Apple Developer / App Store Connect account interaction;
- iPhone physical observation;
- visual judgment on final marketing screenshots;
- final release/storefront approval.

Do not make the owner manually click GitHub Actions or maintain reports.

### Cloud ChatGPT

Cloud ChatGPT:

- keeps task scope narrow;
- independently reads real code/diffs/CI/evidence;
- compares exact SHAs;
- reviews screenshot quality;
- writes/updates audit/STATUS/task docs;
- merges approved PRs unless the owner explicitly authorizes another exception;
- unlocks only the next stage.

---

## 4. Product philosophy and hard boundaries

Everwhile's invariant:

> **Awareness before control.**

It makes selected-app time perceptible.

It does **not**:

- block apps;
- use Shield;
- score productivity;
- create streaks/leaderboards;
- shame or coach;
- force reflection;
- use accounts/cloud/analytics/ads/AI.

Product UI should remain quiet and sparse.

---

## 5. Current functional baseline

The owner has frozen the product/function candidate at:

**Everwhile 0.1.0 (91.1)**

Important SHAs:

- final functional runtime:
  `fab87acc8f4b863451d9c91ee7605b4c33c47789`
- tested SHA:
  `7fa2cae8478ec0429989be4eaf78413724b7f8b2`
- signed/internal upload SHA:
  `d633b5b627933d71aac221a3bb2f6aae29fd82a2`
- PR #21 final head:
  `080da9f7a32c0b2837bf8a08092e5bfaa9f03381`
- PR #21 merge commit:
  `8a42edc58589da0c15673acf7e83a5d045ea2818`

PR #21 is merged.

### 91.1 release evidence

The accepted path includes:

- 60 Swift tests;
- 19 Python tests;
- English Release UI checks;
- zh-Hans dark / largest-text UI checks;
- unsigned iPhone Release build/archive;
- App / Monitor / Report bilingual resource packaging;
- final three-bundle codesign validation;
- Family Controls claim/profile allowance checks;
- required App Group checks;
- exact signed IPA audit;
- App Store Connect upload accepted;
- processing `VALID`;
- `INTERNAL_ONLY`;
- `IN_BETA_TESTING`;
- internal TestFlight group assigned.

Signed IPA SHA-256:

`8ebd4450b98dea08fe9fa6a9ddf0c419ef54a6a903359c627988a6413703e261`

Formal S02-B closeout:

`audits/S02/S02_B_AUDIT_2026-10-06.md`

### Product freeze

S03 is distribution work.

Do **not** casually modify:

- S01 lifecycle/reconciliation;
- DeviceActivity registration semantics;
- Today aggregation;
- tutorial;
- pulse semantics;
- App Group;
- privacy architecture;
- Bundle IDs/capabilities.

Only a concrete Apple/distribution blocker may justify a minimal runtime change.

---

## 6. S01/S02 residual notes — not release blockers by themselves

Keep these honest but do not reopen them during S03 unless a real defect appears:

- 47.1 natural-midnight `generation N -> N+1` was not deliberately re-observed;
- timezone/DST was not manually manipulated;
- all-day every-threshold callback reliability is not claimed;
- human VoiceOver and external Mail/browser actions were not separately owner-tested.

Registration/event count alone is still not equivalent to “current interval active”.

---

## 7. Current stage

At handoff time, `STATUS.md` says:

- S00 COMPLETE — PASS_WITH_NOTES
- S01 COMPLETE — PASS_WITH_NOTES
- S02 COMPLETE — PASS_WITH_NOTES
- **S03-A READY**
- S03-B LOCKED
- S03-C LOCKED

Current task:

`prompts/S03_A_APP_STORE_PREFLIGHT.md`

Release framework:

`docs/S03_APP_STORE_RELEASE_PLAN.md`

This stage does **not** submit App Review and does not make the App public.

---

## 8. S03-A overall scope

S03-A prepares:

1. Family Controls Distribution gate;
2. public Privacy Policy / Support pages;
3. App Privacy source audit + App Store Connect answer draft;
4. English + zh-Hans App Store metadata;
5. App Review notes;
6. App Store screenshot marketing assets;
7. owner/account/region checklist.

Default storefront recommendation:

**United States first**

China mainland:

`BLOCKED_UNTIL_ICP_STATUS_CONFIRMED`

Do not auto-select China mainland.

Default release method:

owner-controlled manual release.

---

## 9. Most important current design task: App Store screenshots

The owner explicitly said the App Store promotional screenshots must be done well.

This is the visual priority in S03-A.

Authoritative Everwhile screenshot production spec:

`docs/S03_SCREENSHOT_PRODUCTION.md`

Do not let Codex treat screenshots as “just capture four screens”.

### Lecture Asset reference

The owner wants Everwhile's screenshot work to reuse the production lessons from:

`Zhangsfish/lecture-asset`

Reference commit:

`4995c1d0d70ebdf3712416bf96ee31219fc67720`

The new cloud ChatGPT should understand that Lecture Asset's good result came from a complete asset pipeline, not from simple screenshots.

Required reference files are listed in `docs/S03_SCREENSHOT_PRODUCTION.md`, especially:

- English/zh-Hans screenshot CI workflows;
- real Release UI capture UITests;
- capture exporters;
- deterministic renderers;
- validators;
- storyboard;
- English/Chinese contact sheets.

### Lecture Asset pattern to preserve

- fresh simulator;
- Release configuration;
- fictional/synthetic non-private state;
- status bar fixed at 9:41 / Wi-Fi / full battery;
- raw captures saved separately;
- final marketing canvas 1320×2868;
- RGB / sRGB / no alpha;
- fixed phone geometry;
- actual phone screenshot pixels preserved;
- marketing composition outside phone;
- deterministic renderer;
- manifest with SHA/provenance;
- image validator;
- contact sheet for visual review;
- English geometry frozen before Chinese.

### Everwhile two-pass gate

This is critical.

**Pass 1: English only**

Codex must first deliver:

- `store-assets/SCREENSHOT_STORYBOARD.md`;
- four English draft App Store PNGs;
- `store-assets/CONTACT_SHEET_EN.png`;
- raw English captures;
- render manifest;
- image validation.

Then **STOP screenshot finalization** and ask the owner for visual review.

The owner judges:

- headline strength;
- visual finish;
- phone scale/crop;
- carousel rhythm/story;
- whether it looks as polished as Lecture Asset.

Do not freeze the final zh-Hans screenshot set before English direction is accepted.

Other S03-A documentation work may continue in parallel, but the S03-A PR must not become READY_FOR_AUDIT while screenshot direction is awaiting owner approval.

**Pass 2: Chinese + final freeze**

After owner acceptance:

- produce zh-Hans captures;
- reuse the same canvas/phone geometry/layout helpers;
- localize copy naturally rather than forcing literal English line breaks;
- produce `CONTACT_SHEET_ZH_HANS.png`;
- validate frozen English bytes and Chinese text bounds;
- freeze final 4+4 Store images.

### Current 4-frame story

1. Awareness
   - EN: `Feel time passing. / Nothing else.`
   - ZH: `感受时间流逝。/ 仅此而已。`

2. Choose apps + interval
   - EN: `Choose the apps. / Pick the interval.`
   - ZH candidate: `选你想留意的 App。/ 设定提醒间隔。`

3. Neutral reminder
   - EN: `A reminder. / Not a restriction.`
   - ZH: `只是提醒。/ 不是限制。`

4. Today
   - EN: `See where the time went.`
   - ZH: `看看时间去了哪里。`
   - optional subline:
     `Total · by hour · by app`
     / `总量 · 每小时 · 各 App`

Copy can be tightened after seeing the English contact sheet.

### Privacy rule for screenshots

Never use the owner's real:

- selected App names;
- Screen Time totals;
- Family Activity tokens;
- usage history;
- notification history.

If clean simulator cannot truthfully show a desired state, use the real shipped in-app tutorial/sample screen instead of adding fake screenshot-only production behavior.

Do not fabricate exact sessions.

---

## 10. Public About / Support product state

Release UI has been cleaned up.

The test-era Advanced diagnostics surface is compile-time DEBUG only and is not a public Release path.

Public home menu is intentionally minimal.

About & Support includes:

- quick usage/help;
- tutorial replay;
- support email;
- copy email;
- personal homepage;
- concise local-data privacy sentence;
- version/build.

Approved public contact:

`zhangs.taq@gmail.com`

Approved homepage:

`https://zhang-shuo-portfolio.vercel.app/`

Do not reintroduce test diagnostics into Release UI.

---

## 11. Family Controls distribution release gate

Signed 91.1 proves the shipping profiles used by CI contain Family Controls allowances.

S03-A still distinguishes this from Developer portal Capability Request state.

Relevant Bundle IDs:

- `com.zhangsfish.elapse`
- `com.zhangsfish.elapse.monitor`
- `com.zhangsfish.elapse.report`

If tooling cannot prove portal-side Assigned state, give the owner one concise Developer Portal action rather than guessing.

Do not ask for passwords, API private keys, certificates or provisioning profiles.

---

## 12. S03-A owner-only actions

Only ask the owner when unavoidable.

Possible portal/account actions include:

- verify Family Controls Distribution Assigned status;
- age-rating questionnaire;
- App Review contact information;
- final storefront list;
- App Store Connect app record/SKU if needed;
- agreements/account-holder-only confirmations;
- final submission approval.

Do not put private phone numbers/identity documents/Apple credentials in the public repo.

---

## 13. What the new cloud ChatGPT should do first

After reading GitHub state, answer only the current operational situation.

Specifically determine:

1. current main SHA;
2. current STATUS unique task;
3. whether an S03-A PR already exists;
4. whether Codex has started screenshot Pass 1;
5. whether an English contact sheet already exists;
6. the single next action.

If S03-A has **not** started, give the owner the Codex start prompt based on:

`prompts/S03_A_APP_STORE_PREFLIGHT.md`

Emphasize that Codex should work on the whole S03-A preflight but must stop screenshot finalization after the English contact sheet for owner visual review.

If S03-A **has** started, do not give a duplicate start prompt. Review the actual branch/PR and continue from its real state.

---

## 14. Things not to do on restart

Do not:

- re-explain S00/S01 history unless needed;
- ask the owner to retest lifecycle;
- re-open tutorial design;
- beautify Today again;
- create new TestFlight builds for Markdown or marketing-only screenshots;
- submit App Review during S03-A;
- automatically select all storefronts;
- automatically make the App public;
- treat a TestFlight VALID build as App Review approval;
- finalize Chinese Store screenshots before the English owner visual gate.

---

## 15. Near-term expected flow

Expected workflow:

```text
S03-A Codex starts
  -> privacy/support/metadata/review-notes/account preflight
  -> screenshot storyboard + EN raw captures + EN renderer
  -> CONTACT_SHEET_EN
  -> STOP for owner visual review
  -> owner/cloud feedback
  -> zh-Hans final set
  -> S03-A READY_FOR_AUDIT
  -> cloud independent audit
  -> S03-B unlock
  -> App Store Connect entry / exact build / regions
  -> owner approves exact submission package
  -> submit to App Review
  -> S03-C review response / owner-approved public release
```

The immediate visual checkpoint is the **English App Store contact sheet**.
