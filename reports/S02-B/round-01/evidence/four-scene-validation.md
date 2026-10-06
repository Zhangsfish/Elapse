# Four-scene revision validation

Base main: c1480eb0021c1fc2261a54ace4576feb7c537d8d.
Runtime: f05df01fa52a144664d3ca87ffd8340fddd5cf6f.
Prepare-tested: e1fba3d5ead1790b5ffef2e9118fc82d78ad58df (marker only).

Windows: 13 Python tests PASS; Bash syntax and git diff --check PASS.
No local Swift/Xcode; no new dependencies installed.

Prepare run: https://github.com/Zhangsfish/Elapse/actions/runs/37353626575
Job: 111910379078; macos-26 / Xcode 26.6 / Swift 6.3.3 / XcodeGen 2.46.0.
58 Swift tests / 0 failures; 13 Python tests PASS.
Unsigned iPhone Release build/archive PASS; actual archive metadata/extensions,
effective entitlements and App/Monitor/Report en + zh-Hans resources PASS.
Prepare 68.1 was not uploaded; no Apple secrets used.
Negative test-fixture READ_ERROR/FAIL lines are expected tests, not archive failures.

Safe actual result lines:

```text
2026-10-05T18:08:59.5008110Z 	 Executed 58 tests, with 0 failures (0 unexpected) in 0.119 (0.130) seconds
2026-10-05T18:08:59.5552220Z 	 Executed 58 tests, with 0 failures (0 unexpected) in 0.119 (0.134) seconds
2026-10-05T18:09:00.2578240Z Ran 13 tests in 0.171s
2026-10-05T18:09:01.2748970Z S00_TF_XCODEGEN_FAMILY_CONTROLS_ENTITLEMENTS_PASS
2026-10-05T18:09:01.2757830Z S00B_TF_XCODEGEN_APP_GROUP_ENTITLEMENTS_PASS
2026-10-05T18:09:18.9343490Z S00_TF_EFFECTIVE_ENTITLEMENTS_PASS
2026-10-05T18:09:57.2926770Z ** BUILD SUCCEEDED **
2026-10-05T18:09:57.5291190Z S02_LOCALIZATION_DEVICE_BUILD_PASS
2026-10-05T18:10:32.7937360Z ** ARCHIVE SUCCEEDED **
2026-10-05T18:10:33.0396160Z S02_LOCALIZATION_ARCHIVE_PASS
2026-10-05T18:10:36.3587380Z S00_ARCHIVE_EXTENSIONS={"ElapseMonitor.appex": {"EXAppExtensionAttributes": false, "Info.plist": true, "NSExtension": true, "NSExtensionPointIdentifier": "com.apple.deviceactivity.monitor-extension", "NSExtensionPrincipalClass": "ElapseMonitor.ElapseMonitorExtension", "folder": "PlugIns"}, "ElapseReport.appex": {"EXAppExtensionAttributes": true, "EXExtensionPointIdentifier": "com.apple.deviceactivityui.report-extension", "Info.plist": true, "NSExtension": false, "NSExtensionPrincipalClass": "ABSENT", "folder": "Extensions"}, "ElapseReport.appex in PlugIns": false}
2026-10-05T18:10:36.3592170Z S00_ARCHIVE_DISTRIBUTION_METADATA_PASS
```

Ordinary CI: https://github.com/Zhangsfish/Elapse/actions/runs/37353631696
Attempt 1: simulator build/resources/capabilities, 58 Swift / 13 Python PASS.
2026-10-05T18:17:29Z: S02B_UI_SMOKE_BLOCKED_ENV_BOOT_TIMEOUT; UI tests NOT_RUN.
The clean simulator did not finish bootstatus within 360 seconds, before any UI assertion.
Attempt 2, same SHA, job 111914841588: simulator build/resources/capabilities,
58 Swift / 13 Python and both native UI tests PASS. English first-visit/Skip/replay
passed at 18:31:13Z; Chinese largest-accessibility replay at 18:32:53Z.
18:32:54Z: S02B_UI_SMOKE_PASS light_en dark_zhHans accessibility_size automated_layout_audit.
Each of four scenes retained the Dynamic Type/text-clipping audit, without suppressing
failures. Back/Next/Skip, final exit, replay reset and no automatic repeat were checked.

Artifact 11364871507 (sha256:447a33116da92c72882b93988cf963b434a372a013ccdef2f787dfcb50affe24)
downloaded to ignored .build/s02b-four-scene-ui/. Ten unique clean-simulator PNGs
(four scenes + home in each language) were visually inspected. English normal-size
artwork/content/footer is readable; largest Chinese content naturally scrolls while
footer controls remain available. Requested dark appearance did not settle in all
Chinese captures; the fourth scene is dark. Do not claim exhaustive four-scene dark
visual coverage or human VoiceOver. Generic samples only, not physical usage proof.

Explicit upload SHA: 9de0a209c653769a2881e68e1586a6f34bacdff7 (upload marker only).
Upload run: https://github.com/Zhangsfish/Elapse/actions/runs/37357058165.
Extra exact-upload ordinary CI: https://github.com/Zhangsfish/Elapse/actions/runs/37357063413.
Final signature / processing / existing internal group results recorded separately.
Exact-upload ordinary job111922047054 PASS: 58 Swift / 13 Python; English test
passed18:44:27Z, Chinese largest-text test18:46:42Z;18:46:44Z S02B_UI_SMOKE_PASS.
No runtime source changed after the passing prepare/native checks.
