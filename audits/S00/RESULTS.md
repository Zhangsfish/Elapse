# S00 results

Updated: 2026-10-03

## Code and CI evidence

Passing implementation evidence:

- Commit: `e69c18f13b50f766746d7bade32c06172141e86c`
- Ordinary CI: [GitHub Actions run 37028810386](https://github.com/Zhangsfish/Elapse/actions/runs/37028810386)
- Host: standard GitHub-hosted `macos-26-arm64`; macOS 26.6.2; Xcode 26.6 (17F113); iOS SDK 26.5; Swift 6.3.3.
- Project generation: XcodeGen 2.46.0 official ZIP matched SHA-256 `4d9e34b62172d645eed6457cac13fc222569974098ef4ee9c3368bedf0196806`; `xcodegen generate --spec project.yml` passed.
- Compile: `xcodebuild ... -destination 'generic/platform=iOS Simulator' ... CODE_SIGNING_ALLOWED=NO clean build` passed for the app, monitor extension, and report extension (`BUILD SUCCEEDED`).
- Tests: `swift test` passed 6/6 with 0 failures: threshold generation; event-name parsing/rejection; cumulative notification copy; duplicate receipt decision; and current-day interval boundaries.
- TestFlight prepare-only CI: [GitHub Actions run 37028811778](https://github.com/Zhangsfish/Elapse/actions/runs/37028811778) passed the Xcode 26 guard, XcodeGen generation, helper validation, safe three-target signing-settings inspection, unsigned iPhoneOS Release build, Everwhile display-name/App Icon/privacy-manifest checks, and unsigned distribution archive inspection. The upload step was skipped and no Apple setting was read.

Ordinary CI uses the Simulator SDK; TestFlight prepare-only uses an unsigned iPhoneOS build and archive. Neither path proves distribution signing, installation, or Screen Time runtime behavior. The pure tests contain no Screen Time delivery claim. Local Windows Xcode/device execution was not available and was not represented as PASS.

## Evidence state

| Item | Status | Evidence / limitation |
|---|---|---|
| Reproducible XcodeGen project definition | PASS | Generated in CI with verified XcodeGen 2.46.0. |
| App + monitor + report extension Simulator compile | PASS | Unsigned compile evidence only; Simulator does not validate Screen Time delivery. |
| Pure logic tests | PASS | 6/6 host-side Swift Package tests passed; they do not claim Screen Time runtime behavior. |
| Individual authorization on iPhone | NOT RUN | Physical iPhone and signing required. |
| Multi-app shared threshold pool | NOT RUN | Physical iPhone required. |
| Unselected/locked time exclusion | NOT RUN | Physical iPhone required. |
| 5–30 minute callback timing/duplicates | NOT RUN | Physical iPhone required. |
| Local notification request from callback | NOT RUN | Physical iPhone required. |
| Visible notification delivery | NOT RUN | Must be observed separately from request acceptance. |
| Per-app/hourly Today report | NOT RUN | Physical iPhone required for real Screen Time data. |

## Signing and entitlement state

The owner reports Family Controls Development + Distribution enabled for:

- `com.zhangsfish.elapse` — main app;
- `com.zhangsfish.elapse.monitor` — Device Activity Monitor extension;
- `com.zhangsfish.elapse.report` — Device Activity Report extension.

The TestFlight route intentionally does not use development/ad-hoc signing or device registration. The required variable and three secrets are present by name; no values were read or printed.

Direct [workflow run 37035044676](https://github.com/Zhangsfish/Elapse/actions/runs/37035044676) used merge commit `f8a9ce2a8fd094173584ff196db11c751618448d`, version `0.1.0`, build `4.1`. Its unsigned archive and three-Bundle-ID checks passed. The combined automatic-signing/export/upload step failed with exit 70 during Apple bundle asset validation; safe diagnostics reported `Invalid Bundle` and a missing bundle key, with no credential, cloud-signing, Family Controls entitlement, or provisioning category. Upload acceptance and App Store Connect processing are `NOT RUN`.

Retry-fix commit `9f6140a39de744c25a0519ba7715d2b0dca4e2c3` passed [ordinary CI 37037314442](https://github.com/Zhangsfish/Elapse/actions/runs/37037314442) and secret-free [TestFlight preparation 37037360799](https://github.com/Zhangsfish/Elapse/actions/runs/37037360799), including all icon dimensions, final `CFBundleIconName`, iPhoneOS Release build, and unsigned archive checks. Upload was intentionally skipped on the feature branch.

The merged retry [run 37038785574](https://github.com/Zhangsfish/Elapse/actions/runs/37038785574) used `b8ef96b7c60f9e47d94d6449d413a9916135184d` and produced `0.1.0 (6.1)`. Build and archive passed; Apple asset validation failed with icon, missing plist key, and orientation categories. [Read-only archive inspection 37040791775](https://github.com/Zhangsfish/Elapse/actions/runs/37040791775) found `UIDeviceFamily=[1,2]`, missing orientations, an `Assets.car` with AppIcon renditions, and iPad primary-icon metadata without files. [Fixed prepare run 37041479260](https://github.com/Zhangsfish/Elapse/actions/runs/37041479260) passed archive assertions for iPhone-only family, primary icon, asset catalog and three orientations. Distribution retry is pending merge; Gates A–D remain `NOT RUN`.

The physical-device run remains `NOT RUN` and is required for Gates A–D.
