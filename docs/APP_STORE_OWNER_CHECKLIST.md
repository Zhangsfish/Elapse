# S03-B final owner/submission gates

2026-10-07. S03-A owner/account facts are recorded here for the release handoff.
Screenshot visual/upload review is complete. S03-B may proceed after cloud audit;
S03-C remains locked until review results.

| Gate | Current evidence / smallest later action |
|---|---|
| Family Controls Distribution | **RELEASE_PROVISIONING_GATE_CLOSED**: 92.1 exact App Store IPA has Apple Distribution + Family Controls signature/profile allowance PASS for all three bundles; ASC VALID / APP_STORE_ELIGIBLE. Assigned UI readback is **NOT_REQUIRED_FOR_RELEASE / OPTIONAL_OWNER_READBACK**, not an owner blocker. This does not assert the unread Portal UI or guarantee App Review approval |
| Public Support/Privacy | **LIVE_VERIFIED**. Codex used the existing authorized administrator session to create Pages (HTTP201), dispatch main deployment (HTTP204), and verify anonymous HTTPS200, exact bilingual source, cross-links, mailto, no remote JS/analytics/login. No owner GitHub action remains |
| App Store build | **PASS — 0.1.0 (92.1), VALID / APP_STORE_ELIGIBLE**. Exact IPA SHA256 `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade` |
| App record/SKU | Current API uniquely identifies Everwhile/com.zhangsfish.elapse; 0.1.0 in PREPARE_FOR_SUBMISSION, 92.1 associated. No duplicate record needed; SKU is not printed |
| Agreements | Owner confirms Account Holder agreements privately; no automatic acceptance |
| Privacy | Recommended ASC answer: **No / Data Not Collected; tracking No**. On-device processing and user-composed external support mail are separate; no automatic email/usage/diagnostic collection. Owner confirms/publishes the App Privacy declaration in ASC; do not mislabel a draft recommendation as published |
| Copyright | Copyright is present in ASC. Owner only confirms the legal rights-holder attestation; do not re-enter a field already present |
| Age rating | **OWNER_COMPLETED — 4+** from the actual questionnaire |
| Export compliance | Source ITSAppUsesNonExemptEncryption=false; no custom crypto code found. Owner confirms applicability of Apple's current questions; source flag is not legal approval |
| Review contact | **CURRENT_API_FIELDS_COMPLETE**; demo account not required. No need to re-enter. Only completeness booleans recorded; no names/email/phone copied into public evidence |
| Regions | Recommendation remains United States first / Free / iPhone-only / English + zh-Hans. Exact storefront list still requires owner approval before submission |
| Screenshots | **OWNER_COMPLETED — 4 English + 4 zh-Hans accepted in ASC and visually checked**. Canonical design masters remain 1320×2868; actual accepted slot used 1206×2622 derivatives. No re-upload requested |
| China mainland | **BLOCKED_UNTIL_ICP_STATUS_CONFIRMED**. Do not add it by default or infer that a local-only app is exempt |
| Release | Recommend manual release only after review and owner approval; no automatic public launch |

Live and saved/read back in both ASC locales:
Support https://zhangsfish.github.io/Elapse/;
Privacy https://zhangsfish.github.io/Elapse/privacy.html.
Evidence: `reports/S03-B/round-01/evidence/public-pages-live.json` and
`evidence/asc-current-readback.json`.

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

## Minimum final owner confirmation

Confirm exact initial storefront(s) (proposal: United States only, China excluded),
copyright/legal rights and any outstanding Account Holder agreements/export/privacy
attestations in ASC. Privacy Nutrition Label publication is not exposed by the API
used here. Review contact/build/URLs do not need repeating. After independent PR
review/merge and this package confirmation, owner performs final Submit for Review.
No public release is authorized; S03-C remains locked.
