# S02-B — first-use guidance + bilingual product polish

Task ID: S02-B
Scheduling: valid only while STATUS marks S02-B READY / IN_PROGRESS.
Branch: `codex/s02-b-onboarding-polish`

## Goal

Finish Everwhile's product experience without reopening the architecture.

S02-A is accepted. The core home and Today information architecture are now baseline.

S02-B is deliberately small:
- first-use guidance;
- app-selection teaching;
- user-facing notification localization/copy;
- final copy/spacing/accessibility polish;
- close the explicit S02-A runtime notes where feasible.

Do not turn this into another visual redesign.

## Read first

1. `AGENTS.md`
2. `STATUS.md`
3. `docs/PRODUCT_DECISIONS.md`
4. `docs/PRODUCT_SPEC.md`
5. `docs/S02_UX_RESEARCH_AND_DIRECTION.md`
6. `audits/S02/S02_A_AUDIT_2026-10-05.md`
7. current production home / report extension / localization files
8. current notification copy in `Shared/PulsePlan.swift`

Accepted baseline:
- merge: `c0eb65a2b1a40950b05270b400eb2f2e62e181af`
- internal build: Everwhile `0.1.0 (56.1)`

## Product invariant

**Awareness before control.**

No:
- Shield / blocking;
- scores / streaks;
- guilt / coach;
- forced reflection;
- accounts/cloud/analytics/ads/AI;
- exact-session invention.

## A. First-use flow: progressive, not a tutorial carousel

Do **not** add a mandatory multi-page onboarding.

The existing home state should itself guide setup:

1. no authorization -> one obvious Screen Time authorization action;
2. authorized + no Apps -> one obvious Choose Apps action;
3. Apps selected + monitoring off -> Start;
4. monitoring on -> quiet normal state + Stop available.

Polish wording/spacing so a new user can complete setup without reading diagnostics or a help manual.

Do not add extra taps merely to teach the product.

## B. Lightweight “Choose Apps” teaching

The owner still wants a small visual teaching cue for selecting Apps.

Implement a lightweight, non-blocking SwiftUI teaching element using generic symbols/rows only:
- shown when no Apps are selected, or reachable from the Choose Apps area;
- visually demonstrates selecting more than one App in Apple's picker and completing the selection;
- no real App identities, screenshots or private tokens;
- no fake claim that Everwhile controls those Apps;
- animation should be short/subtle and respect Reduce Motion;
- returning users with an existing selection should not be forced through it.

Prefer an inline/help cue over a modal tutorial.

Keep the actual selection action Apple's `FamilyActivityPicker`.

## C. Localize the actual pulse notification

The main App and Today are bilingual, but the pulse notification is still production-facing.

Add English + Simplified Chinese notification copy and package the localization resources for the Monitor extension too.

Copy must stay technically safe.

Do **not** say:
- “today total” when the monitoring interval cannot prove that;
- “you wasted” / “you should stop”;
- exact wall-clock elapsed time if the DeviceActivity callback may be delayed.

A safe baseline is:

English:
- title: `5 minutes`
- body: `Selected apps reached the 5-minute reminder point.`

Simplified Chinese:
- title: `5 分钟`
- body: `所选 App 已达到 5 分钟提醒点。`

Use the actual threshold number.

You may tighten wording if it remains equally factual and neutral.

Add pure tests for both languages and multiple threshold values.

## D. Copy alignment

Keep the product voice quiet and short.

Use the product direction rather than generic productivity language.

Preferred tagline family:
- English: `Feel time passing. Nothing else.`
- zh-Hans: `感受时间流逝。仅此而已。`

Do not add founder philosophy / “time is money” / discipline language to the product UI.

Tighten any remaining mechanical copy only where it is visible to normal users.

## E. Accessibility / appearance closeout

Do feasible engineering checks for:
- dark mode;
- larger Dynamic Type;
- VoiceOver labels/order;
- Reduce Motion for the teaching animation;
- English / zh-Hans resource completeness.

Do not require the owner to run a long accessibility checklist.

If simulator/source inspection finds a real clipping/readability bug, fix it.

Chart and App rows must keep accessible hour/duration or label/duration meaning.

Status cannot rely on color alone.

## F. Locale edge

`UsageDurationLanguage.forLocale` should not blindly treat every Chinese locale/script as Simplified Chinese if the app only ships zh-Hans + English.

Align duration formatting with the actual supported localization/fallback behavior and add a regression test (e.g. zh-Hans -> Simplified Chinese, en -> English, unsupported locale fallback remains coherent).

Do not add Traditional Chinese as a new supported product language in this stage unless the owner explicitly asks.

## G. Preserve accepted architecture

Do not change:
- S01 lifecycle/reconciliation;
- threshold registration semantics;
- Today aggregation meaning;
- report privacy boundary;
- App Group contents;
- Bundle IDs / capabilities.

Do not move protected report data into the main App.

Do not rework the S02-A Today chart unless a real regression is found.

## H. Verification

Minimum:
- all existing Swift tests pass;
- new notification/localization/teaching pure logic tests where applicable;
- localization-key test covers Monitor notification resources too;
- XcodeGen simulator build;
- unsigned device/archive resource checks include Monitor localization;
- existing signing/capability assertions remain green.

Prepare one internal TestFlight build after code is stable.

## I. Very small owner acceptance

One short round only.

Ask the owner to inspect:
1. first-use/Choose Apps teaching cue or final home polish;
2. one normal Today view if its code changed materially;
3. one real pulse notification only if notification localization cannot otherwise be trusted from build/resource evidence.

Do **not** repeat:
- reboot;
- revoke/regrant;
- midnight;
- long usage sessions;
- S01 lifecycle tests.

If a real bug appears, fix only that bug.

## J. Delivery

One PR:
`codex/s02-b-onboarding-polish`

Reports:
```text
reports/S02-B/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
```

Record exact base/runtime/tested/upload/final SHAs and build number.

Stop at `READY_FOR_AUDIT`.

Do not self-merge.
Do not unlock S03.
