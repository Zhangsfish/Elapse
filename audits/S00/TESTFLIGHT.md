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
