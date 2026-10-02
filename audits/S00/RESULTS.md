# S00 results

Updated: 2026-10-02

## Code and CI evidence

Passing implementation evidence:

- Commit: `b18309dfe58508540305d907f549745f5bc0cf13`
- CI: [GitHub Actions run 36991441759](https://github.com/Zhangsfish/Elapse/actions/runs/36991441759)
- Host: standard GitHub-hosted `macos-26-arm64`; macOS 26.6.2; Xcode 26.6 (17F113); iOS SDK 26.5; Swift 6.3.3.
- Project generation: XcodeGen 2.46.0 official ZIP matched SHA-256 `4d9e34b62172d645eed6457cac13fc222569974098ef4ee9c3368bedf0196806`; `xcodegen generate --spec project.yml` passed.
- Compile: `xcodebuild ... -destination 'generic/platform=iOS Simulator' ... CODE_SIGNING_ALLOWED=NO clean build` passed for the app, monitor extension, and report extension (`BUILD SUCCEEDED`).
- Tests: `swift test` passed 6/6 with 0 failures: threshold generation; event-name parsing/rejection; cumulative notification copy; duplicate receipt decision; and current-day interval boundaries.

The CI compile uses Simulator SDKs only. The pure tests contain no Screen Time delivery claim. Local Windows Xcode/device execution was not available and was not represented as PASS.

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

## Signing and entitlement blockers

Family Controls distribution approval is not established for:

- `com.zhangsfish.elapse` — main app;
- `com.zhangsfish.elapse.monitor` — Device Activity Monitor extension;
- `com.zhangsfish.elapse.report` — Device Activity Report extension.

Development signing and a physical-device run remain owner-side prerequisites. No Apple key, certificate, profile, Team ID, or App and Website Usage entitlement is stored in this repository.
