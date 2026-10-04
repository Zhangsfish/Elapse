# S02-A delivery — in progress

Base main: `c8d8b81294dceff2eaa09a3abb4643340abc3719` (2026-10-05 fetch).
Branch: `codex/s02-a-production-ui-today`.
Code/tested/upload/final PR SHA: pending.
Version/build: 0.1.0 / pending internal build.
PR and CI URLs: pending.

Scope: production home hierarchy, secondary Advanced diagnostics, native Today hourly aggregate chart, precise subminute duration wording, en/zh-Hans resources. Monitoring state machine and DeviceActivityReport privacy boundary unchanged. Chart bars come only from filtered `ApplicationActivity.totalActivityDuration` grouped by real hourly segment starts; they are not sessions. Home only receives selected-App count, never private usage data.

Automated checks, signing/processing, and one short owner UI observation are pending. S01 natural-midnight note remains residual and is not retested in S02-A.
