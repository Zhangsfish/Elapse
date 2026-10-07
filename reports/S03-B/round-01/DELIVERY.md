# S03-B / round-01 — review-eligible RC preparation

Date: 2026-10-07
Status: **RC PASS — APP_STORE_ELIGIBLE; FINAL PORTAL GATES PENDING**

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


## Actual review RC result

Workflow: https://github.com/Zhangsfish/Elapse/actions/runs/37580987653  
Exact source checkout: `10b9e29f9d730e83a1fbd852fa49b09d83dd155a`  
Version/build: **0.1.0 (92.1)**  
Exact IPA SHA256: `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`

Actual checks:

- one-time marker validation PASS;
- frozen product tree PASS;
- 60 Swift + 42 Python tests PASS;
- unsigned archive PASS;
- distribution export PASS;
- exact signed IPA audit PASS;
- App / Monitor / Report codesign PASS;
- Apple Distribution PASS on all three bundles;
- Family Controls claim + distribution profile allowance PASS on all three;
- required App Group claim/profile PASS on App + Monitor;
- get-task-allow disabled on all three;
- App-Store-like profile checks PASS;
- exact IPA upload ACCEPTED;
- App Store Connect processing **VALID**;
- build audience **APP_STORE_ELIGIBLE**;
- usesNonExemptEncryption **FALSE**.

This is the first Everwhile build prepared for App Review selection. It has **not**
been submitted to App Review and has not been publicly released.

Remaining before owner submission approval:

1. live Support + Privacy URLs;
2. final App Privacy/account fields;
3. exact storefront approval (recommended US first);
4. private reviewer contact fields;
5. explicit final package approval for 0.1.0 (92.1).

The successful App Store distribution profiles are strong operational evidence that
Family Controls distribution provisioning is working for all three bundles. The
Developer Portal Capability Requests UI state remains a separate readback note unless
the owner confirms it directly.
