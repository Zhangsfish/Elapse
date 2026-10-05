# S02-A delivery — sparse duration-axis revision

Base main: `c8d8b81294dceff2eaa09a3abb4643340abc3719`.
Branch / PR: `codex/s02-a-production-ui-today` / [#20](https://github.com/Zhangsfish/Elapse/pull/20) (draft, not merged).
Revised runtime code SHA: `8d7c2b09c62fd3b33734f54c04d1f8be767c5812`.
Prepare-tested SHA: `432be4d983eb90ca2f539f225e88ecc706ebdc4e`.
Tested/upload SHA: `61150f3d1e12857ebf393d8e0eb6edb31116c395` (only explicit marker additions after runtime SHA).
Version/build: **Everwhile 0.1.0 (56.1)**; processing VALID, internal group assigned.
State: **READY_FOR_AUDIT**; 56.1 duration-axis device appearance is OWNER_REPORTED_PASS. Independent cloud audit is pending.
PR head: recorded in PR metadata after documentation/trigger cleanup; no runtime changes after runtime code SHA.

## Implementation

- `App/ContentView.swift`: production home shows explicit state, interval, selected-App count and Today entry; technical details and ordinary notification test moved to Advanced. Blocked authorization still permits reauthorization and Stop. Desired intent, exact recurring registration and today's interval start are distinct in the home status.
- `ReportExtension/ElapseReportExtension.swift`: selected-App total hero, observed-hour Swift Charts bars and descending token-labelled App rows in three compact cards. The input remains filtered `ApplicationActivity.totalActivityDuration` grouped by actual hourly segment; no session claim or report-data export.
- `Shared/UsageDurationFormatter.swift`, `Shared/TodayHourlyChartPlan.swift`, `Shared/HomeMonitoringStatus.swift` plus unit tests: correct positive subminute wording, truthful bar heights, sparse duration-axis scale and status precedence.
- `Localization/{en,zh-Hans}.lproj/Localizable.strings`, `project.yml`, both CI workflows and localization-key test: two languages packaged in the app and report extension. Semantic colors, text state, combined accessibility rows and per-bar hour/duration labels support light/dark, Dynamic Type and VoiceOver at source level. Owner observed 50.1 home/Today, approved the 53.1 Today layout in light mode and confirmed the 56.1 duration-axis revision. Runtime dark/Dynamic Type/VoiceOver checks remain NOT_RUN.
- No S01 lifecycle, entitlements, Bundle IDs, App Group privacy boundary or Today scope change.

50.1 owner feedback led to distinct Stop/Start icon/style/color treatment, tighter bilingual copy, singular `1 app`, quieter Today spacing and removal of full-width app progress tracks. The system-loading explanation is a subdued footer, not an asserted loading state. The chart helper now extends only its axis to the end of the current hour so the current-hour bar fits; the report filter and bucket cutoff still end at now. A new pure regression test covers 12:53 with a positive current-hour bucket.

53.1 owner approved that layout and requested an absolute duration scale. 56.1 adds leading y-axis labels and subtle horizontal guides using native Swift Charts. A 25-minute peak uses 0/15/30-minute ticks; 44 uses 0/25/50. Peaks up to one minute use 0/1; larger low-use peaks round to even whole minutes, then to ten-minute ceilings above ten minutes, so the midpoint has an exact whole-minute label. Bar heights retain actual seconds and long buckets are not capped at 60 minutes. Three new pure tests cover examples, exact/small boundaries and a >1-hour bucket. Current SDK compiled the custom axis API; official reference: [Customizing axes in Swift Charts](https://developer.apple.com/documentation/charts/customizing-axes-in-swift-charts).

The visualization review preserved a zero-based scale, real positive hourly buckets, accessible hour/duration labels and the absence of exact-session claims. Apple API references: [Swift Charts](https://developer.apple.com/documentation/charts/creating-a-chart-using-swift-charts), [Charts HIG](https://developer.apple.com/design/human-interface-guidelines/charts), [Xcode localization](https://developer.apple.com/documentation/Xcode/localizing-and-varying-text-with-a-string-catalog).

## Verification

- Local Windows: `python -m unittest discover -s scripts/tests` — 11 passed; `git diff --check` passed. No local Xcode/Swift build.
- [Ordinary CI at prepare-tested SHA](https://github.com/Zhangsfish/Elapse/actions/runs/37269483347) — PASS: XcodeGen, simulator build, en/zh-Hans resource packaging in App + Report, Python release checks, **47 Swift tests / 0 failures**. No Apple secrets. The preceding runtime-only CI was superseded by this marker push; no runtime source changed between these SHAs.
- [Prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37269479724) — PASS on prepare-tested SHA; unsigned iPhone Release build/archive, final metadata/entitlement/configuration/resource assertions passed.
- [Ordinary CI at upload SHA](https://github.com/Zhangsfish/Elapse/actions/runs/37269746949) — PASS, including simulator build, both localization bundles and 47 Swift tests / 0 failures.
- [Documentation/trigger-cleanup CI](https://github.com/Zhangsfish/Elapse/actions/runs/37270580986) — PASS at `6df3b943fe7812cc52bfabab158e52a89c4c6217`; no runtime changes after the upload SHA. Final owner-observation documentation head and its CI are recorded in PR metadata.
- [Explicit upload](https://github.com/Zhangsfish/Elapse/actions/runs/37269743274) — PASS on upload SHA. Signed IPA SHA-256 `abbd067a5058e7a3e3fab3048c12c9f1c49cc06a90d16d1eb053dbc0365f52e3`; signed App/Monitor/Report signatures, Family Controls claims and profile allowances PASS; Apple upload accepted; processing VALID; INTERNAL_ONLY; IN_BETA_TESTING; assigned to existing internal group. Safe evidence: `evidence/duration-axis-release.txt`. Historical 53.1 evidence remains in `evidence/ui-revision-release.txt`.
- The existing marker validator authorizes only a newly added marker in a marker-only push with the explicit commit message. The revised source SHA distinguishes this duration-axis prepare/upload invocation. Both markers are removed after execution in this documentation commit; ordinary code/document pushes do not authorize uploads.

Owner 50.1 observation: **PASS_WITH_UI_NOTES**; owner 53.1 Today layout: **PASS_WITH_AXIS_REQUEST**; owner 56.1 axis revision: **OWNER_REPORTED_PASS**, from the chat reply “没问题，很好”. See `DEVICE_OBSERVATIONS.md`. No new screenshot or exact tick-value verification is claimed. No further device action is requested for this round; runtime dark mode, Dynamic Type, VoiceOver and a separate explicit revised ON/OFF-button appearance check remain NOT_RUN. Stop at READY_FOR_AUDIT; S02-B/S03 remain locked.
