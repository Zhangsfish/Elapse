# S00 TestFlight path

Updated: 2026-10-03

## Scope

This path reuses the distribution architecture already validated by `Zhangsfish/lecture-asset`:

1. generate the Xcode project and run all secret-free checks;
2. create an unsigned generic iOS archive;
3. only after an explicit `upload` dispatch or the audited one-time retry marker enters `main`, use App Store Connect automatic distribution signing during `xcodebuild -exportArchive`;
4. query only the exact uploaded build until App Store Connect reports `VALID`, `FAILED`, `INVALID`, or the bounded check remains pending.

It intentionally does not register a device or use development/ad-hoc signing.

## Owner-reported Apple state

- User-visible App Store Connect name: `Everwhile`.
- Main App ID: `com.zhangsfish.elapse`.
- Monitor extension App ID: `com.zhangsfish.elapse.monitor`.
- Report extension App ID: `com.zhangsfish.elapse.report`.
- Family Controls Development + Distribution capability is enabled for all three App IDs.
- The main App Store Connect record exists.
- The existing Admin Team API key is the intended credential.

These account facts are owner-provided. The repository contains no Apple private key, certificate, profile, Team ID, or provisioning secret.

## Repository implementation

- `.github/workflows/s00-testflight.yml` offers `prepare-only` / `upload` choices for manual dispatch; the retry branch adds one path-scoped marker event that cannot fire on ordinary main pushes.
- `scripts/s00_testflight_release.sh` reads credentials only inside the explicit upload step, keeps raw Xcode logs private in the ephemeral runner, creates the unsigned archive, and requests automatic App Store Connect distribution signing/upload.
- `scripts/s00_testflight_diagnostics.py` emits only fixed safe failure categories.
- `scripts/s00_testflight_status.swift` queries processing for bundle ID `com.zhangsfish.elapse` and the exact generated build number.
- `scripts/s00_signing_settings.py` validates all three target names and Bundle IDs while redacting team/profile values.

## Evidence state

Secret-free implementation commit: `e69c18f13b50f766746d7bade32c06172141e86c`.

- Ordinary CI: [run 37028810386](https://github.com/Zhangsfish/Elapse/actions/runs/37028810386) — PASS.
- TestFlight prepare-only CI: [run 37028811778](https://github.com/Zhangsfish/Elapse/actions/runs/37028811778) — PASS; explicit upload step skipped.

| Item | Status | Evidence / limitation |
|---|---|---|
| Everwhile display name with Elapse internal project/scheme | PASS | Built app has `CFBundleDisplayName=Everwhile`; project, scheme, product, and Bundle IDs remain Elapse. |
| Source App Icon and required-reason privacy manifests | PASS | Prepare workflow validated the opaque 1024×1024 source and app/monitor manifests; attempt 01 exposed missing distribution icon metadata/renditions. |
| Prepare-only Release build and helper validation | PASS | Run 37028811778 passed without reading Apple settings. |
| Unsigned archive and embedded extension metadata | PASS | Prepare-only created the unsigned archive and verified all three Bundle IDs plus synchronized build numbers. |
| Automatic distribution signing and TestFlight upload | FAILED | Run 37035044676 passed archive checks, then failed Apple bundle asset validation before upload acceptance. |
| App Store Connect processing state | NOT RUN | No Everwhile build has been uploaded by this workflow. |
| S00 real-device Gates A–D | NOT RUN | TestFlight plumbing is not Screen Time behavior evidence. |

## GitHub Actions settings

Checked by name through the GitHub API on 2026-10-03; only presence is reported here and no values were printed.

- Variable `APPLE_TEAM_ID`: PRESENT (value not printed)
- Secret `APP_STORE_CONNECT_KEY_ID`: PRESENT (value inaccessible and not printed)
- Secret `APP_STORE_CONNECT_ISSUER_ID`: PRESENT (value inaccessible and not printed)
- Secret `APP_STORE_CONNECT_PRIVATE_KEY`: PRESENT (value inaccessible and not printed)

The direct upload script passed all four non-secret presence/format gates. This does not reveal or independently validate credential contents.

The default explicit upload ref is `main`. The recovery marker is separately restricted to its first path change on `main`.

## Upload attempt 01 — bundle asset validation failure

- Dispatch: direct API dispatch from `main` succeeded; no owner click was required.
- Run: [37035044676](https://github.com/Zhangsfish/Elapse/actions/runs/37035044676).
- Source: `f8a9ce2a8fd094173584ff196db11c751618448d`.
- Version/build: `0.1.0 (4.1)`.
- Unsigned archive and embedded extension metadata: PASS.
- Automatic signing/export/upload: FAILED, exit 70. The safe log reported `Invalid Bundle` and a missing bundle key during Apple asset validation; no missing-setting, credential-format, cloud-signing-permission, Family Controls entitlement, or provisioning category appeared.
- Upload accepted: NO.
- Processing: NOT RUN.

The retry fix adds explicit iPhone icon renditions and `CFBundleIconName=AppIcon`, asserts the final built/archive plist value, and expands the fixed safe diagnostic categories. A unique path-scoped marker triggers exactly one upload when the fix PR first enters `main`; later ordinary commits do not match that path and cannot upload.

Secret-free retry validation: [ordinary CI 37037314442](https://github.com/Zhangsfish/Elapse/actions/runs/37037314442) and [prepare-only run 37037360799](https://github.com/Zhangsfish/Elapse/actions/runs/37037360799) both PASS for commit `9f6140a39de744c25a0519ba7715d2b0dca4e2c3`. The upload step was skipped.

## Upload attempt 02 and archive proof

- [Run 37038785574](https://github.com/Zhangsfish/Elapse/actions/runs/37038785574): `0.1.0 (6.1)` built and archived; Apple asset validation failed with missing icon, missing plist key, and no supported orientations. No upload acceptance or processing.
- [Baseline prepare run 37040791775](https://github.com/Zhangsfish/Elapse/actions/runs/37040791775): final archive had `UIDeviceFamily=[1,2]`, no supported-orientation array, and no primary iPad icon files. The main app did contain `Assets.car` with 13 AppIcon entries and a valid primary AppIcon name; the missing icon was therefore not explained by an absent source PNG.
- Lecture Asset's successful Xcode 26 distribution uses a single universal 1024×1024 icon and target-level `TARGETED_DEVICE_FAMILY=1`. Everwhile now uses those same packaging settings and explicitly declares portrait plus landscape left/right in the main app plist.
- [Fixed prepare run 37041479260](https://github.com/Zhangsfish/Elapse/actions/runs/37041479260): final archive asserts `UIDeviceFamily=[1]`, primary `CFBundleIcons`/`CFBundleIconName=AppIcon`, `Assets.car` AppIcon renditions, and all three orientations. Upload step skipped.
- The old marker was consumed and removed. The new marker path is the only push path accepted by the TestFlight workflow; merging it triggers one retry from `main` without making ordinary commits upload.

## Upload attempt 03 — generated extension metadata

- [Run 37100010225](https://github.com/Zhangsfish/Elapse/actions/runs/37100010225): `main` at `a66c5b4c45028d8ec7c4ba9d322838fa6e6eec24`; unsigned build/archive and app icon/orientation checks passed; Apple validation failed, exit 70, safe category `MISSING_PLIST_KEY` (`NSExtension`, `NSExtensionPointIdentifier`). Upload not accepted.
- [Baseline prepare run 37100507160](https://github.com/Zhangsfish/Elapse/actions/runs/37100507160): final `PlugIns/ElapseMonitor.appex/Info.plist` and `PlugIns/ElapseReport.appex/Info.plist` both existed but neither contained `NSExtension`. This is generated archive evidence, not a guess from source files.
- Root cause: XcodeGen 2.46.0 `info.path` generates and writes an Info.plist from `info.properties`; the extension dictionaries existed only in tracked source plists, so generation discarded them. PR #5 places the monitor declaration in generated properties. The `@main` report uses ExtensionKit type, `Extensions/` embedding, and `EXAppExtensionAttributes`, avoiding a report `NSExtensionPrincipalClass` that can prevent installation.
- The new archive inspector asserts both final extension manifests and locations before any upload. The prior marker was consumed; a new path-scoped marker permits only the next merge to retry automatically.
- [Ordinary CI 37100843564](https://github.com/Zhangsfish/Elapse/actions/runs/37100843564) passed app/extension Simulator compile and pure tests. [Prepare-only run 37100820822](https://github.com/Zhangsfish/Elapse/actions/runs/37100820822) passed the unsigned iPhone build/archive and exact final metadata checks: Monitor in `PlugIns/` has the expected `NSExtension` point and `ElapseMonitor.ElapseMonitorExtension` principal class; Report in `Extensions/` has the expected `EXExtensionPointIdentifier`, no legacy `NSExtension` or principal class, and no duplicate `PlugIns/` copy. Upload was skipped.


## Final upload — PASS

- Main commit: `60a15650d6791ef081f6d8aa402cfb48d3a03ff1`.
- Workflow: [37105502155](https://github.com/Zhangsfish/Elapse/actions/runs/37105502155).
- Version/build: `0.1.0 (19.1)`.
- `S00_TF_XCODEGEN_FAMILY_CONTROLS_ENTITLEMENTS_PASS`: PASS.
- Unsigned archive: PASS.
- App/extension metadata assertions: PASS.
- Automatic App Store Connect export/upload: PASS.
- Processing result: `S00_TF_PROCESSING_STATUS_VALID build=19.1`.

The decisive fix was declaring `com.apple.developer.family-controls: true` in XcodeGen `entitlements.properties` for all three targets. Merely keeping the key in the tracked entitlement plist was insufficient because XcodeGen owns and rewrites those files when generating the project.

Distribution plumbing is now complete. The next gate is physical-device acceptance using `audits/S00/REAL_DEVICE_CHECKLIST.md`.
