# S01-B preimplementation midnight observation — 44.1

Date boundary observed: 2026-10-04 23:59 → 2026-10-05 00:01 (owner local time, +08:00)  
Build: Everwhile `0.1.0 (44.1)`  
Source stage: accepted S01-A baseline; **not** an S01-B implementation result.

Two owner screenshots were inspected in chat and are not committed here.

## Before midnight — 23:59

Visible state:

- configured interval: 5 minutes;
- configuration generation: 8;
- configuration short ID: `f7bce817`;
- registered interval: 5 minutes;
- planned event count: 299;
- system-registered event count: 299;
- registration state: registered / waiting for real callback;
- registration error: none;
- callback count: 0.

## After midnight — 00:01

Without Stop, Start, interval change, selection change, or any other monitoring action, the owner reopened/refreshed Everwhile.

Visible state remained:

- same configuration generation: 8;
- same short ID: `f7bce817`;
- registered interval: 5 minutes;
- planned event count: 299;
- system-registered event count: 299;
- registration state still presented as registered / waiting for real callback;
- registration error: none;
- callback count: 0.

## What this proves

**DEVICE_OBSERVED:**

- crossing the midnight boundary did not remove the S01-A activity from `DeviceActivityCenter.activities` as observed by the app;
- `DeviceActivityCenter.events(for:)` still returned all 299 registered events after midnight;
- the same app-owned configuration snapshot remained readable across midnight.

## What this does NOT prove

Build 44.1 still uses a non-repeating schedule (`repeats=false`) and explicitly says it does not automatically continue across days.

Therefore this observation does **not** prove:

- a new scheduled interval actually started after midnight;
- selected-App usage on the new day is being accumulated;
- thresholds will fire on the new day;
- automatic rollover is correct.

The important engineering consequence is the opposite:

> **system registration presence / event-count readback is not sufficient evidence that the current day's monitoring interval has actually begun.**

S01-B must therefore keep separate observable states for:

1. desired monitoring intent;
2. system schedule registration presence/count;
3. current interval lifecycle generation/anchor established by `intervalDidStart` (or equivalent verified lifecycle evidence).

Do not classify `center.activities.contains(activity) && events(for:).count == plannedCount` as proof that the current interval is active.

This opportunistic observation reduces the need to infer midnight behavior from source alone, but S01-C still owns the real recurring-schedule midnight rollover acceptance for the S01-B implementation.
