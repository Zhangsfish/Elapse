# S02-A delivery — waiting for owner UI review

Base main: `c8d8b81294dceff2eaa09a3abb4643340abc3719`.
Branch / PR: `codex/s02-a-production-ui-today` / [#20](https://github.com/Zhangsfish/Elapse/pull/20) (draft, not merged).
Runtime code SHA: `a5329c1887ae63fafb5fdd4ef2ab0dd28fd29bee`.
Tested/upload SHA: `0edc5f39a4fa6a5c7436d28d3ea2a33c07b3d1cf` (only one-time marker added after runtime SHA).
Version/build: **Everwhile 0.1.0 (50.1)**.
Final PR head: pending owner observations and report update.

## Implementation

- `App/ContentView.swift`: production home shows explicit state, interval, selected-App count and Today entry; technical details and ordinary notification test moved to Advanced. Blocked authorization still permits reauthorization and Stop. Desired intent, exact recurring registration and today's interval start are distinct in the home status.
- `ReportExtension/ElapseReportExtension.swift`: selected-App total hero, observed-hour Swift Charts bars, descending token-labelled App rows and proportional scan bars. The input remains filtered `ApplicationActivity.totalActivityDuration` grouped by actual hourly segment; no session claim or report-data export.
- `Shared/UsageDurationFormatter.swift`, `Shared/TodayHourlyChartPlan.swift`, `Shared/HomeMonitoringStatus.swift` plus unit tests: correct positive subminute wording, truthful bar heights and status precedence.
- `Localization/{en,zh-Hans}.lproj/Localizable.strings`, `project.yml`, both CI workflows and localization-key test: two languages packaged in the app and report extension. Semantic colors, text state, combined accessibility rows and per-bar hour/duration labels support light/dark, Dynamic Type and VoiceOver at source level; runtime appearance/accessibility inspection remains NOT_RUN until a device or simulator visual review.
- No S01 lifecycle, entitlements, Bundle IDs, App Group privacy boundary or Today scope change.

The chart follows a zero-based scale and uses only observed positive hourly buckets. It does not manufacture missing-hour observations or exact app-open/close sessions. Apple API references: [Swift Charts](https://developer.apple.com/documentation/charts/creating-a-chart-using-swift-charts), [Xcode localization](https://developer.apple.com/documentation/Xcode/localizing-and-varying-text-with-a-string-catalog).

## Verification

- Local Windows: `python -m unittest discover -s scripts/tests` — 11 passed; `git diff --check` passed. No local Xcode/Swift build.
- [Ordinary CI at runtime SHA](https://github.com/Zhangsfish/Elapse/actions/runs/37229178469) — PASS: XcodeGen, simulator build, en/zh-Hans resource packaging in App + Report, Python release checks, **43 Swift tests / 0 failures**. No Apple secrets.
- [Prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37229098457) — PASS on preceding source commit `35de397`, before the final blocked-authorization Stop UI adjustment; unsigned iPhone Release build/archive and resource checks passed. The later upload run repeated these checks on the final runtime code.
- [Explicit upload](https://github.com/Zhangsfish/Elapse/actions/runs/37229402515) — PASS on tested/upload SHA. Unsigned archive; App Store Connect automatic distribution export; exact signed IPA SHA-256 `5cfdcf4fb7c60bb9e69aa6ec1be21b2758bea9b69b1331a40c6151e1d488af17`; signed App/Monitor/Report code signatures, Family Controls claims and profile allowances PASS; Apple upload accepted; processing `VALID`; audience `INTERNAL_ONLY`; internal beta state `IN_BETA_TESTING`; assigned to internal group.
- One-time prepare/upload marker files were deleted after execution. Ordinary branch commits cannot trigger another upload. No public release.

Owner visual/interaction check: **NOT_RUN**. No pulse, reboot, midnight or permission-revocation test is requested in S02-A.
