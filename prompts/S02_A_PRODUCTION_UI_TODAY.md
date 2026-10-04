# S02-A — production UI shell + Today redesign

Task ID: S02-A
Scheduling: valid only while STATUS marks S02-A READY / IN_PROGRESS.
Branch: `codex/s02-a-production-ui-today`

## Goal

Turn the accepted Everwhile 47.1 functional baseline from an engineering console into the first real product UI.

Read first:
1. `AGENTS.md`
2. `STATUS.md`
3. `docs/PRODUCT_DECISIONS.md`
4. `docs/PRODUCT_SPEC.md`
5. `docs/S02_UX_RESEARCH_AND_DIRECTION.md`
6. `audits/S01/S01_C_CLOSEOUT_2026-10-05.md`
7. current `App/ContentView.swift`
8. current `ReportExtension/ElapseReportExtension.swift`
9. current Today aggregation/tests
10. actual localization/project resources.

Do not restart S00/S01. Do not alter the monitoring state machine unless a real UI integration bug requires it.

## Product invariant

**Awareness before control.**

Everwhile reports time; it does not judge it.

No:
- Shield / blocking;
- scores / streaks;
- guilt / coaching;
- “culprit App” semantics;
- accounts/cloud/analytics/ads/AI;
- fake exact sessions.

## A. Main screen

Replace the current giant Form/debug console with a quiet production hierarchy.

The normal user should see, in roughly this priority:

1. Everwhile brand/title.
2. A compact monitoring state card:
   - On / Off / Needs Screen Time permission / Needs Apps;
   - configured pulse interval;
   - selected-App count;
   - one obvious Start or Stop action.
3. Simple rows/actions to change selected Apps and interval when allowed.
4. Today entry / embedded summary in a visually primary position.
5. Only the minimal status explanation needed for action.

Remove from the ordinary surface:
- `S00-A`, `S01-B`, test-stage labels;
- config UUID;
- planned/system event counts;
- interval generation/anchor;
- callback/recovery counters;
- raw test-notification section;
- long engineering explanations.

Do **not delete** useful diagnostics. Move them to a clearly secondary **Diagnostics / Advanced** screen reachable from a small settings/info affordance.

Advanced may contain:
- authorization details;
- config/event/lifecycle/recovery diagnostics;
- version;
- ordinary notification self-test;
- refresh diagnostics;
- copy diagnostic summary.

This keeps supportability without making diagnostics the product.

## B. Today report

Keep protected usage data inside the DeviceActivityReport extension.

Redesign the report hierarchy:

1. **Hero total**
   - Today selected-App total is the most prominent number.
   - last updated is secondary metadata.

2. **Hourly distribution**
   - use a compact, glanceable bar chart appropriate for hourly sums;
   - represent real hourly buckets only;
   - no fabricated session timeline;
   - sparse axis labels;
   - short caption explaining “hourly aggregate, not exact open/close times”;
   - accessibility descriptions must expose hour + duration.

3. **Per-App ranking**
   - Apple token label + duration;
   - descending duration;
   - make relative share easy to scan, but do not introduce judgmental color/status.

The current long per-hour row list should not remain the primary visualization.

Swift Charts is allowed if it works cleanly in the report extension on the current iOS 17.4+ deployment target. Prefer native low-maintenance SwiftUI over custom drawing.

## C. Duration precision

Fix the known display bug:

- exactly 0 -> `0m`;
- positive but <60 sec -> `<1m`;
- 1m..<1h -> whole-minute display;
- >=1h -> hours + minutes.

Bar heights still use actual seconds.

Add pure unit tests for formatter behavior, including:
- 0;
- 1 sec;
- 59 sec;
- 60 sec;
- 3599 sec;
- 3600 sec;
- mixed hour/minute values.

Do not let independent row rounding create a claim that displayed rounded rows must sum exactly to the rounded total; keep copy/layout clear enough that this is not misleading.

## D. Chinese + English

Add a real localization foundation for at least:
- Simplified Chinese;
- English.

Use String Catalog or equivalent project resources included by XcodeGen.

All normal production UI strings in the main App and Today report should be localized.

Diagnostics can be concise, but do not leave a half-Chinese/half-English normal product surface.

## E. Accessibility / appearance

Check:
- light mode;
- dark mode;
- Dynamic Type;
- VoiceOver labels for the chart and app-duration rows;
- status does not rely on color alone;
- no clipped core controls on a normal iPhone width.

No decorative 3D/gamified visual system.

## F. Reliability boundaries

Do not regress S01:

- Start/Stop semantics;
- desired-vs-registration separation;
- repeating registration;
- authorization recovery;
- selected Apps;
- interval 5/10/15/30/60;
- diagnostic access.

Do not move protected report data into App Group to make the home screen easier.

The residual 47.1 natural-midnight acceptance note is not an S02 blocker and is not a reason to touch lifecycle code.

## G. Tests / CI

Minimum:
- all existing tests pass;
- new duration formatting tests;
- any new pure chart/data formatting helpers get tests;
- XcodeGen + simulator build pass;
- localization resources are included in generated project/archive;
- no entitlement/capability regression.

## H. Internal build + very small owner acceptance

After implementation and CI are clean, prepare one internal TestFlight build.

Owner device testing should be short. One round is enough unless a real bug appears:

1. Open the new build and inspect the main screen.
2. Confirm monitoring state / interval / selected-App count / Start-Stop controls are understandable and no engineering console dominates.
3. Open Today with real data and inspect total + hourly chart + app list.
4. Confirm no obvious wrong numbers, clipping, `0m` for visible positive usage, or fake session language.

Do not make the owner repeat S01 lifecycle tests.
Do not wait for a pulse.
Do not wait for midnight.
Do not revoke authorization again.

Screenshots may be used in-chat for review; do not publicly commit private App identities/usage screenshots unless explicitly authorized.

## I. Deliverable

One PR only.

Reports:
```text
reports/S02-A/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
```

Before READY_FOR_AUDIT record:
- base main SHA;
- runtime/tested/upload/final PR SHAs;
- build number;
- files changed;
- tests/CI;
- localization coverage;
- device observations and their provenance.

Stop at `READY_FOR_AUDIT`.

Do not self-merge.
Do not unlock S02-B or S03.
