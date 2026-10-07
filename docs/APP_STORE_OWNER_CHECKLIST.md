# S03-A remaining account/release gates

2026-10-07. S03-A owner/account facts are recorded here for the release handoff.
Screenshot visual/upload review is complete. S03-B may proceed after cloud audit;
S03-C remains locked until review results.

| Gate | Current evidence / smallest later action |
|---|---|
| Family Controls Distribution | 91.1 final App/Monitor/Report signatures and profile allowances PASS; portal Assigned NOT_VERIFIED. In Certificates, Identifiers & Profiles → Capability Requests → Family Controls, confirm Assigned/provisioning support for all three IDs (com.zhangsfish.elapse, .monitor, .report). Reply only the three states; no profiles/secrets |
| Public Support/Privacy | Automatic enablement was attempted after merge but GitHub returned `Resource not accessible by integration`. **One owner GitHub action is required:** Settings → Pages → Build and deployment → Source = GitHub Actions. Then rerun/verify the existing deployment workflow and anonymous HTTPS |
| App Store build | **PASS — 0.1.0 (92.1), VALID / APP_STORE_ELIGIBLE**. Exact IPA SHA256 `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade` |
| App record/SKU | Owner previously confirmed record Everwhile exists for com.zhangsfish.elapse. Current portal record/SKU readback NOT_RUN; do not create duplicate record |
| Agreements | Owner confirms Account Holder agreements privately; no automatic acceptance |
| Privacy | Source audit supports no automatic app-data collection/tracking. Final ASC privacy answer and optional support-mail treatment still require owner/account confirmation |
| Copyright | Confirm legal rights-holder name in metadata draft |
| Age rating | **OWNER_COMPLETED — 4+** from the actual questionnaire |
| Export compliance | Source ITSAppUsesNonExemptEncryption=false; no custom crypto code found. Owner confirms applicability of Apple's current questions; source flag is not legal approval |
| Review contact | Owner privately enters name/email/phone in ASC, never Git/chat public evidence |
| Regions | Recommendation remains United States first / Free / iPhone-only / English + zh-Hans. Exact storefront list still requires owner approval before submission |
| Screenshots | **OWNER_COMPLETED — 4 English + 4 zh-Hans accepted in ASC and visually checked**. Canonical design masters remain 1320×2868; actual accepted slot used 1206×2622 derivatives. No re-upload requested |
| China mainland | **BLOCKED_UNTIL_ICP_STATUS_CONFIRMED**. Do not add it by default or infer that a local-only app is exempt |
| Release | Recommend manual release only after review and owner approval; no automatic public launch |

Hosting candidates, **NOT_LIVE / NOT ASC values**: repository Pages root would be
https://zhangsfish.github.io/Elapse/ and privacy.html. Verify HTTPS 200 and visible
contact/policy after deployment before promoting these to metadata.

Apple references checked 2026-10-07:
[Family Controls distribution](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement),
[internal-only builds](https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers),
[China mainland information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information),
[manual release and metadata](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information).


## Owner-completed App Store facts — 2026-10-07

- App name: Everwhile.
- Primary language: English (US).
- Primary category: Utilities.
- Secondary category: none.
- Age rating questionnaire: completed, calculated 4+.
- Store screenshots: 4 English + 4 zh-Hans uploaded to ASC and owner-approved in place.
- Content-rights declaration shown by owner: no third-party content requiring a rights declaration.

These are owner-observed portal facts. They are not evidence of App Review approval.


## S03-B release progress

- PR #24 prepares the review-eligible RC tooling; production product tree remains frozen.
- Secret-free RC tooling verification passed before the upload marker.
- Review RC 0.1.0 (92.1) completed successfully: upload ACCEPTED, processing VALID, APP_STORE_ELIGIBLE.
- App Review submission remains NOT AUTHORIZED until the exact RC and remaining portal fields are presented to the owner.
