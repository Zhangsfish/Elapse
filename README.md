# Elapse

**Feel time passing. Nothing else.**

Elapse is a deliberately small iPhone utility for people who do not want another productivity system.

The core idea is simple:

1. The user selects a small group of apps.
2. Elapse treats their usage as one shared pool of attention.
3. Every N minutes of actual foreground usage, Elapse gives a quiet reminder.
4. At the end of the day, the user can see where that time went.

Elapse does **not** shame, score, block, gamify, or coach the user.

## Product thesis

Many distracting apps reduce the subjective feeling of time passing. The first intervention should therefore be awareness, not control.

Elapse does not prescribe what time is for. It simply makes elapsed time perceptible and leaves the next choice to the user.

A notification such as:

> 5 minutes passed  
> Selected apps used today: 120 minutes

may be enough to restore that awareness while leaving the decision to continue entirely with the user.

The deeper product philosophy and brand foundation live in `docs/PRODUCT_DECISIONS.md`.

## Locked product scope

### Core

- User selects multiple apps with Apple's system picker.
- Selected apps share one usage pool.
- Default pulse interval: 5 minutes.
- Notify at cumulative usage thresholds: 5, 10, 15, 20… minutes.
- No blocking or shielding.
- A Today view shows per-app usage and time distribution using only data Apple officially exposes.
- Local-first. No account, cloud service, analytics SDK, AI API, or ads.

### Important data boundary

The standard Screen Time / Device Activity APIs can support private, token-based monitoring and in-app reports, but they do **not** automatically give the main app an unrestricted event log containing every exact app-open/app-close session.

Therefore:

- Never fabricate exact session boundaries from hourly aggregates.
- Never treat “callback count × interval” as authoritative total usage.
- Detailed export is **not** a baseline feature.
- EU-only / additional-entitlement APIs such as `approvedWithDataAccess` are optional future work, not an S00 dependency.

See `docs/APPLE_PLATFORM_NOTES.md`.

## Non-goals

Elapse is not:

- an app blocker;
- a parental-control product;
- a Pomodoro timer;
- a to-do list;
- a productivity score;
- a streak or habit app;
- a social product;
- an AI assistant;
- a background screen recorder.

If a proposed feature does not help the user **feel elapsed time** or inspect that elapsed time later, it probably does not belong here.

## Repository map

- `AGENTS.md` — rules for AI coding agents.
- `STATUS.md` — current stage, gates, blockers, and next action.
- `docs/PRODUCT_DECISIONS.md` — product philosophy and brand foundation.
- `docs/PRODUCT_SPEC.md` — product contract.
- `docs/APPLE_PLATFORM_NOTES.md` — verified Apple API boundaries and links.
- `docs/TECHNICAL_PLAN.md` — architecture and staged implementation.
- `prompts/S00_CODEX.md` — executable first-stage task for Codex.
- `project.yml` — reproducible app, monitor-extension, report-extension, and test targets.
- `audits/S00/REAL_DEVICE_CHECKLIST.md` — the physical-iPhone acceptance procedure.

## Current stage

**S00 — Screen Time feasibility gate**

The S00 app, monitor extension, report extension, tests, and CI are implemented. Reproducible build and pure-logic evidence pass; the physical-iPhone behavior gates remain `NOT RUN`. See `STATUS.md` and `audits/S00/REAL_DEVICE_CHECKLIST.md`.

Before polishing UI or building a complete app, prove on a real iPhone that:

1. several selected apps can contribute to one cumulative usage threshold;
2. 5/10/15/20/25/30 minute thresholds behave reliably enough for the product;
3. notifications can be requested from the monitor flow;
4. an in-app Device Activity report can show truthful per-app usage and time-distribution data;
5. limitations, duplicate callbacks, delayed callbacks, and missing data are surfaced rather than hidden.

See `STATUS.md` and `prompts/S00_CODEX.md`.

## License

No license decision yet. Do not add one without an explicit product decision.
