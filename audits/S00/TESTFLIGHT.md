# S00 TestFlight path

Updated: 2026-10-02

## Scope

This path reuses the distribution architecture already validated by `Zhangsfish/lecture-asset`:

1. generate the Xcode project and run all secret-free checks;
2. create an unsigned generic iOS archive;
3. only after an explicit manual `upload` dispatch, use App Store Connect automatic distribution signing during `xcodebuild -exportArchive`;
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

- `.github/workflows/s00-testflight.yml` runs prepare-only on branch pushes and offers `prepare-only` / `upload` choices for manual dispatch.
- `scripts/s00_testflight_release.sh` reads credentials only inside the explicit upload step, keeps raw Xcode logs private in the ephemeral runner, creates the unsigned archive, and requests automatic App Store Connect distribution signing/upload.
- `scripts/s00_testflight_diagnostics.py` emits only fixed safe failure categories.
- `scripts/s00_testflight_status.swift` queries processing for bundle ID `com.zhangsfish.elapse` and the exact generated build number.
- `scripts/s00_signing_settings.py` validates all three target names and Bundle IDs while redacting team/profile values.

## Evidence state

| Item | Status | Evidence / limitation |
|---|---|---|
| Everwhile display name with Elapse internal project/scheme | PENDING CI | `CFBundleDisplayName=Everwhile`; project, scheme, product, and Bundle IDs remain Elapse. |
| App Icon and required-reason privacy manifests | PENDING CI | Prepare workflow validates the icon and app/monitor manifests. |
| Prepare-only Release build and helper validation | PENDING CI | No Apple settings are read by this path. |
| Unsigned archive and embedded extension metadata | PENDING CI | Prepare-only creates and inspects the same unsigned archive structure without Apple credentials. |
| Automatic distribution signing and TestFlight upload | BLOCKED_OWNER | Required GitHub repository settings are not configured yet. |
| App Store Connect processing state | NOT RUN | No Everwhile build has been uploaded by this workflow. |
| S00 real-device Gates A–D | NOT RUN | TestFlight plumbing is not Screen Time behavior evidence. |

## GitHub Actions settings

Checked by name through the GitHub API on 2026-10-02; values were never read or printed.

- Variable `APPLE_TEAM_ID`: MISSING
- Secret `APP_STORE_CONNECT_KEY_ID`: MISSING
- Secret `APP_STORE_CONNECT_ISSUER_ID`: MISSING
- Secret `APP_STORE_CONNECT_PRIVATE_KEY`: MISSING

Until these four names exist, prepare-only work can pass but explicit upload remains `BLOCKED_OWNER`.
