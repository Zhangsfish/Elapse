# Ordinary CI — runtime candidate

Source/tested SHA: `e1d6a5c81041d93e0f121c0ed757eb8fff391c89`.
Run: https://github.com/Zhangsfish/Elapse/actions/runs/37306828901
Job: `111752414315`. Conclusion: SUCCESS. Public runner, no Apple secrets.

- Xcode 26.6; Apple Swift 6.3.3; macos-26.
- XcodeGen 2.46.0; generated capability assertions and effective signing settings PASS.
- Simulator build and en/zh-Hans resources in App, Monitor and Report PASS.
- 53 Swift tests / 0 failures; 12 Python tests PASS.
- Native English light UI test: TEST SUCCEEDED at 12:11:44Z.
- Native zh-Hans dark/largest accessibility text UI test: TEST SUCCEEDED at 12:13:07Z.
- Automated Dynamic Type / text-clipping accessibility audit PASS in both tests.
- `S02B_UI_SMOKE_PASS light_en dark_zhHans accessibility_size automated_layout_audit`.

Earlier runtime candidate `dba9ef0acea3674379a096a2b05717f63d9a3df3` also passed
https://github.com/Zhangsfish/Elapse/actions/runs/37305680345.
Its four clean-simulator home/help screenshots were visually inspected locally:
English light/default text and zh-Hans dark/largest accessibility text wrap/scroll
without horizontal clipping. They show an actual unauthorized clean simulator,
not fabricated authorization or private usage. Final candidate differs only in
disabled-alert wording and simulator boot handling; final UI tests reran.

The first superseded run was cancelled; it is not a full CI PASS.
Artifacts contain only clean-simulator XCTest results/screenshots. No owner screenshots.
This does not prove physical Screen Time behavior, human VoiceOver, or notification delivery.
