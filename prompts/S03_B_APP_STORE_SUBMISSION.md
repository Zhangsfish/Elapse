# S03-B — App Store submission preparation and exact release candidate

Task ID: S03-B
Branch: `codex/s03-b-app-store-submission`

## Start

Read in order:

1. `AGENTS.md`
2. `STATUS.md` — the only dispatch authority
3. `audits/S03/S03_A_AUDIT_2026-10-07.md`
4. `docs/S03_APP_STORE_RELEASE_PLAN.md`
5. `docs/APP_STORE_OWNER_CHECKLIST.md`
6. `docs/APP_STORE_METADATA.md`
7. `docs/APP_STORE_PRIVACY_DRAFT.md`
8. `docs/APP_REVIEW_NOTES.md`
9. S02 signed/internal 91.1 evidence and release workflows
10. current App Store Connect / Developer portal facts supplied by the owner

Frozen product/runtime candidate remains **Everwhile 0.1.0 (91.1)** unless a
real Apple distribution blocker proves a minimal runtime change is necessary.

## Hard boundary

S03-B is release packaging and App Store Connect preparation, not product redesign.

Do not change monitoring lifecycle, Today semantics, tutorial, notification meaning,
App Group/privacy architecture, Bundle IDs or capabilities unless a concrete Apple
distribution failure requires a separately documented minimal fix.

Do not publicly release the app. Do not silently submit to App Review.

## Already completed

Do not redo these:

- English + zh-Hans screenshot design is frozen.
- Owner uploaded 4 English + 4 zh-Hans screenshots to ASC and confirmed they display correctly.
- App name: Everwhile.
- Primary language: English (US).
- Primary category: Utilities.
- Secondary category: none.
- Age rating questionnaire completed: 4+.
- 91.1 functional/runtime acceptance is frozen.
- China mainland remains blocked until ICP status is confirmed.

## A. Close account gates

Before release-candidate upload, distinguish inherited signed evidence from portal state.

### Family Controls Distribution

Verify or obtain owner confirmation that Family Controls Distribution is Assigned /
provisioning-supported for all three identifiers:

- `com.zhangsfish.elapse`
- `com.zhangsfish.elapse.monitor`
- `com.zhangsfish.elapse.report`

Existing 91.1 signatures/profile allowances are strong distribution evidence but are
not a substitute for an explicit portal-state record.

If tooling cannot read Capability Requests, ask the owner for exactly one portal action
and record only Assigned / not Assigned / unclear. Never request profiles or secrets.

### Public Support / Privacy

The repo contains static Support and Privacy sources. Make the public pages live using
the existing approved deployment path if automation can do so. Otherwise give the owner
the smallest exact GitHub Pages action required.

Before entering either URL into ASC, verify anonymously:

- HTTPS 200;
- correct Everwhile content;
- Privacy and Support cross-links;
- support email;
- no login;
- no remote JS/analytics/tracking added by the project.

Expected candidates after successful deployment:

- Support: `https://zhangsfish.github.io/Elapse/`
- Privacy: `https://zhangsfish.github.io/Elapse/privacy.html`

Never claim them live until actually verified.

## B. Final App Privacy / metadata / review fields

Use the source-audited drafts, plus owner portal facts, to prepare the exact ASC package.

Keep these separate:

- verified app behavior;
- recommended portal answer;
- owner/legal/account confirmation.

Do not overclaim Screen Time precision, exact notification delivery, health treatment,
blocking, AI, analytics or server-side usage processing.

Review notes must preserve the actual reviewer path and explain no login/demo account.

Private reviewer contact name/phone stays only in ASC; do not commit it.

## C. Distribution-eligible RC

Current 91.1 upload is INTERNAL_ONLY and cannot be used for App Review.

Prepare one **App-Store-review-eligible** distribution RC from the frozen accepted
runtime. Reuse existing signing/account infrastructure; do not create new certificates,
profiles or devices without a proven need.

Requirements:

- version remains `0.1.0`;
- use a new unique build number;
- runtime/product source must remain identical to the frozen accepted runtime except
  release-only tooling/metadata that does not alter behavior;
- omit the internal-TestFlight-only export restriction for the review RC;
- exact signed App / Monitor / Report signatures and identifiers verified;
- Family Controls entitlement/profile allowance verified on all required bundles;
- required App Group verified;
- privacy manifests/resources/localizations verified;
- `get-task-allow=false`;
- distribution certificate/profile type verified;
- exact IPA hash recorded;
- upload the exact audited IPA bytes once;
- verify ASC processing status and that the build is eligible/selectable for App Review.

A VALID upload is not itself review approval.

Do not create an additional internal preview unless a concrete release-only change needs
owner inspection.

## D. Storefront and release method

Default recommendation remains:

- price: Free;
- initial storefront: United States;
- iPhone-only;
- English + zh-Hans localization;
- manual owner-controlled release;
- China mainland excluded until ICP status is confirmed.

Do not silently change storefronts. Before submission, obtain owner approval of the
exact storefront list and exact RC build.

## E. Submission gate

Prepare the exact final submission package and stop for owner approval before the first
actual `Submit for Review` action.

Return:

- version/build;
- exact RC source SHA;
- exact IPA SHA256;
- ASC build processing/eligibility state;
- Support + Privacy live URLs;
- Family Controls portal states;
- privacy/age/category/metadata/screenshot completion state;
- exact storefronts proposed;
- remaining owner-only private fields;
- explicit statement: App Review NOT YET SUBMITTED.

Only after the owner approves the exact package and storefronts may S03-B perform the
single App Review submission action.

Public release remains manual and belongs to S03-C after review approval.

## Evidence

Use one S03-B PR. Record exact SHAs, workflow runs, safe signing assertions and owner
portal observations under `reports/S03-B/`.

Never commit Apple credentials, profiles, private signing material, reviewer phone,
identity documents or raw sensitive ASC responses.
