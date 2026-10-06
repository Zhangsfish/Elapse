# Prepare-only evidence

Exact prepare SHA: `9a58c1d43c45edbe1f31172ce6ff97ddfb6e7fef`.
Only change since tested runtime candidate: newly added one-time prepare marker.
Run: https://github.com/Zhangsfish/Elapse/actions/runs/37308195208
Job: `111756883489`; conclusion SUCCESS; no Apple credentials read.

- Swift 53 tests / 0 failures; Python 12 tests PASS.
- Effective/generated Family Controls entitlements on all three shipped targets PASS.
- App/Monitor App Group expected; Report App Group not required (unchanged).
- iPhone Release build: BUILD SUCCEEDED at 12:16:40Z.
- All three built bundles contain en + zh-Hans Localizable.strings and pulse title/body.
- Unsigned distribution archive: ARCHIVE SUCCEEDED at 12:17:12Z.
- All three archived bundles contain en + zh-Hans Localizable.strings and pulse title/body.
- Archive metadata, iPhone-only family [1], icon/assets, orientations and extension declarations PASS.
- Signing/upload step SKIPPED by prepare-only gate.

Archive build 58.1 is not uploaded. It is not an installed-device or distribution-signature PASS.
Runtime candidate is `e1d6a5c81041d93e0f121c0ed757eb8fff391c89`.
