# S03-A remaining account/release gates

2026-10-07. These are a preflight map, not a request to submit or release now.
S03-B/C remain LOCKED. English screenshot visual review is the current owner gate.

| Gate | Current evidence / smallest later action |
|---|---|
| Family Controls Distribution | 91.1 final App/Monitor/Report signatures and profile allowances PASS; portal Assigned NOT_VERIFIED. In Certificates, Identifiers & Profiles → Capability Requests → Family Controls, confirm Assigned/provisioning support for all three IDs (com.zhangsfish.elapse, .monitor, .report). Reply only the three states; no profiles/secrets |
| Public Support/Privacy | Pure static source and main-only Pages workflow prepared. GitHub public repo metadata has_pages=false on 2026-10-07; no Pages-setting tool in current connector. After approved merge, set repository Settings → Pages → Source: GitHub Actions once; Codex can retry the workflow if needed. Then anonymously GET both live URLs; no fake URL now |
| App Store build | 91.1 is INTERNAL_ONLY, not App-Review-eligible. **DEFERRED_S03_B**, not an owner credentials error. Codex later creates a new eligible distribution package with frozen runtime, under explicit submission-stage authority. No upload in S03-A |
| App record/SKU | Owner previously confirmed record Everwhile exists for com.zhangsfish.elapse. Current portal record/SKU readback NOT_RUN; do not create duplicate record |
| Agreements | Owner confirms Account Holder agreements privately; no automatic acceptance |
| Privacy | Confirm actual optional support-mail handling/retention and approve ASC answers; draft is not a legal attestation |
| Copyright | Confirm legal rights-holder name in metadata draft |
| Age rating | Complete current questionnaire from actual app features; do not invent a resulting age label |
| Export compliance | Source ITSAppUsesNonExemptEncryption=false; no custom crypto code found. Owner confirms applicability of Apple's current questions; source flag is not legal approval |
| Review contact | Owner privately enters name/email/phone in ASC, never Git/chat public evidence |
| Regions | Recommendation: United States first / Free / iPhone-only / English + zh-Hans. Exact storefront list requires approval |
| Screenshot size slots | English draft uses the requested large Dynamic Island 1320×2868 size. In S03-B verify ASC's current required medium Dynamic Island slot; use Apple's scaling where supported or prepare an approved size derivative. Do not assume this four-file draft alone satisfies every future slot |
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
