# S02-A delivery — 50.1 feedback revision

Base main: `c8d8b81294dceff2eaa09a3abb4643340abc3719`.
Branch / PR: `codex/s02-a-production-ui-today` / [#20](https://github.com/Zhangsfish/Elapse/pull/20) (draft, not merged).
Revised runtime code SHA: `145c41dbf34aa5840884a06e1b5a2946ce84df43`.
Prepare-tested SHA: `fe6abf9da977e90861e1de67ac9d29a366a64387`.
Upload SHA: `ea51beccd0c1ee83792c996dc2aed10b443bf827` (only explicit marker additions after runtime SHA).
Version/build: **Everwhile 0.1.0 (53.1)**; processing VALID, internal group assigned.
State: **WAITING_FOR_OWNER_TEST**; revised-build appearance remains NOT_RUN.
PR head: recorded in PR metadata after documentation/trigger cleanup; no runtime changes after runtime code SHA.

## Implementation

- `App/ContentView.swift`: production home shows explicit state, interval, selected-App count and Today entry; technical details and ordinary notification test moved to Advanced. Blocked authorization still permits reauthorization and Stop. Desired intent, exact recurring registration and today's interval start are distinct in the home status.
- `ReportExtension/ElapseReportExtension.swift`: selected-App total hero, observed-hour Swift Charts bars and descending token-labelled App rows in three compact cards. The input remains filtered `ApplicationActivity.totalActivityDuration` grouped by actual hourly segment; no session claim or report-data export.
- `Shared/UsageDurationFormatter.swift`, `Shared/TodayHourlyChartPlan.swift`, `Shared/HomeMonitoringStatus.swift` plus unit tests: correct positive subminute wording, truthful bar heights and status precedence.
- `Localization/{en,zh-Hans}.lproj/Localizable.strings`, `project.yml`, both CI workflows and localization-key test: two languages packaged in the app and report extension. Semantic colors, text state, combined accessibility rows and per-bar hour/duration labels support light/dark, Dynamic Type and VoiceOver at source level. 50.1 light-mode home/Today rendered on the owner's iPhone; revised rendering and runtime dark/Dynamic Type/VoiceOver checks remain NOT_RUN.
- No S01 lifecycle, entitlements, Bundle IDs, App Group privacy boundary or Today scope change.

50.1 owner feedback led to distinct Stop/Start icon/style/color treatment, tighter bilingual copy, singular `1 app`, quieter Today spacing and removal of full-width app progress tracks. The system-loading explanation is a subdued footer, not an asserted loading state. The chart helper now extends only its axis to the end of the current hour so the current-hour bar fits; the report filter and bucket cutoff still end at now. A new pure regression test covers 12:53 with a positive current-hour bucket.

The visualization review preserved a zero-based scale, real positive hourly buckets, accessible hour/duration labels and the absence of exact-session claims. Apple API references: [Swift Charts](https://developer.apple.com/documentation/charts/creating-a-chart-using-swift-charts), [Charts HIG](https://developer.apple.com/design/human-interface-guidelines/charts), [Xcode localization](https://developer.apple.com/documentation/Xcode/localizing-and-varying-text-with-a-string-catalog).

## Verification

- Local Windows: `python -m unittest discover -s scripts/tests` — 11 passed; `git diff --check` passed. No local Xcode/Swift build.
- [Ordinary CI at revised runtime SHA](https://github.com/Zhangsfish/Elapse/actions/runs/37266173236) — PASS: XcodeGen, simulator build, en/zh-Hans resource packaging in App + Report, Python release checks, **44 Swift tests / 0 failures**. No Apple secrets.
- [Prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37266364892) — PASS on prepare-tested SHA; unsigned iPhone Release build/archive, final metadata/entitlement/configuration/resource assertions passed.
- [Ordinary CI at upload SHA](https://github.com/Zhangsfish/Elapse/actions/runs/37266709568) — PASS, including simulator build, both localization bundles and 44 Swift tests / 0 failures.
- [Explicit upload](https://github.com/Zhangsfish/Elapse/actions/runs/37266706335) — PASS on upload SHA. Signed IPA SHA-256 `f6db2dd7e31cfb46909fc44b965148a19690a7efa7ca2201a7b0cade384a2df1`; signed App/Monitor/Report signatures, Family Controls claims and profile allowances PASS; Apple upload accepted; processing VALID; INTERNAL_ONLY; IN_BETA_TESTING; assigned to existing internal group. Safe evidence: `evidence/ui-revision-release.txt`.
- The existing marker validator authorizes only a newly added marker in a marker-only push with the explicit commit message. The revised source SHA distinguishes this second prepare/upload invocation. Both markers are removed after execution in this documentation commit; ordinary code/document pushes do not authorize uploads.

Owner 50.1 observation: **PASS_WITH_UI_NOTES**; see `DEVICE_OBSERVATIONS.md`. Revised-build UI observation: **NOT_RUN**. No pulse, reboot, midnight or permission-revocation test is requested in S02-A.
