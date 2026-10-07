# S03-B / round-01 — review-eligible RC preparation

Date: 2026-10-07
Status: **PREPARED_FOR_RC_UPLOAD — CI/AUDIT PENDING**

Frozen product candidate: Everwhile 0.1.0 (91.1)
Frozen functional runtime: `fab87acc8f4b863451d9c91ee7605b4c33c47789`

This branch adds release-only tooling for one App-Store-review-eligible RC. It does not
change App/Shared/Monitor/Report/Localization/AppResources/project.yml.

## Release tooling

- `.github/workflows/s03-review-rc.yml`
- `scripts/s03_review_release.sh`
- `scripts/s03_review_ipa_audit.py`
- `scripts/s03_review_status.swift`

The RC export intentionally omits `testFlightInternalTestingOnly`.

The exact exported IPA must pass:
- bundle IDs/version/build;
- strict codesign;
- Apple Distribution authority;
- Family Controls signature claim and profile allowance on App/Monitor/Report;
- App Group claim/profile on App/Monitor;
- get-task-allow disabled;
- App-Store-like distribution profiles;
- exact IPA SHA256.

After upload, ASC must report:
- processingState VALID;
- buildAudienceType APP_STORE_ELIGIBLE.

No App Review submission or public release is performed by this workflow.

## One-time upload gate

The upload workflow only runs when a new exact marker is added at:
`reports/S03-B/round-01/evidence/s03b-review-rc-upload-once.json`

The marker commit must contain no other file changes and binds the upload to the
immediately preceding source/tooling SHA.

Expected first RC build: **0.1.0 (92.1)**.

## Separate owner/account gates

Still pending independently:
- GitHub Pages enablement/live Support + Privacy URLs;
- explicit Developer Portal Family Controls Distribution Assigned readback;
- final App Privacy/account declarations;
- exact US storefront/release package approval before Submit for Review;
- private reviewer contact fields.

China mainland remains excluded pending ICP status.

No product retest is requested solely for release-tooling changes.
