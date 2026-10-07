# S03-B portal closeout — 2026-10-07

PR #25: `codex/s03-b-portal-closeout`; base main
`3afd08da4408860e9a2236904fe92c543f4d37d8`. PR #24 is already merged.
No product/runtime/screenshot changes, new RC, new TestFlight, submission or release.

## Public URLs — LIVE_VERIFIED

Support: https://zhangsfish.github.io/Elapse/  
Privacy: https://zhangsfish.github.io/Elapse/privacy.html

The main Pages run `37582321752` failed: automatic site creation was denied to
GITHUB_TOKEN. Existing authorized repository-admin credentials enabled the Pages
workflow site through the GitHub API; main deployment `37583194129` then passed.
Anonymous HTTPS GETs verified 200, exact source bytes, English/zh-Hans, cross-links,
mailto, no remote JS/analytics/login. See `evidence/public-pages-live.json`.
Owner has no remaining GitHub Pages/Actions operation.

## Family Controls — operational gate CLOSED; Portal UI OPTIONAL

Exact existing RC: 0.1.0 (92.1), source
`10b9e29f9d730e83a1fbd852fa49b09d83dd155a`, run `37580987653`.
IPA SHA256 `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`.
Re-read actual RC audit logs: all three bundles have Apple Distribution, valid
codesign, Family Controls signature claim and distribution-profile allowance,
get-task-allow=false, App-Store-like profiles; App/Monitor required App Group passes.
Upload ACCEPTED; processing VALID; audience APP_STORE_ELIGIBLE.

Apple requires distribution entitlement approval/provisioning, not a separately
archived screenshot of Capability Requests. The exact distributed artifact and
ASC eligibility substantiate the operational gate. Assigned UI is
**NOT_REQUIRED_FOR_RELEASE / OPTIONAL_OWNER_READBACK**, not an owner blocker.
This does not assert that the unread UI was observed or that App Review approved
the app. Basis: [Apple Family Controls distribution documentation](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement)
and `audits/S03/S03_B_RC_AUDIT_2026-10-07.md`.

## Current ASC package — safe readback, not submission

`evidence/asc-current-readback.json` records safe allowlisted output and exact
query/preparation source/run separately from the historical signed RC.
Existing 92.1 is associated with 0.1.0; both live Support/Privacy URLs are saved.
Version PREPARE_FOR_SUBMISSION; release MANUAL; marketing URL empty.
Private review contacts are already complete, demo account not required.
The explicit preparation operation only saves known public URLs, associates
existing 92.1, and saves the repository's concise English review notes. It never
changes owner listing copy, contacts, territories, pricing, privacy attestations,
release mode or submission. Default operation remains read-only.

Owner's final English promo is exact (165 characters). Both public localizations
are reconciled to actual ASC readback; metadata limits pass. Public listing text is
safe evidence; private contact values and API IDs are not recorded.

## App Privacy — exact recommended answer

**Does this app collect data? No — Data Not Collected. Tracking: No.**

- A: no automatic off-device collection/network SDK/analytics in production.
- B: selected tokens, configuration and diagnostics remain local. Identity,
  per-App duration and hourly usage remain inside DeviceActivityReport extension,
  not copied through App Group or uploaded by Everwhile.
- C: a user-initiated `mailto:` opens the user's separate mail client; no automatic
  attachment/private prefill. Any voluntarily sent mail is external support
  correspondence, not automatic app collection of Email Address. Do not claim
  support mail never leaves the device. Reassess if this behavior changes.

Verified source, PrivacyInfo.xcprivacy, dependencies, report boundary and public
policy. [Apple's definition](https://developer.apple.com/app-store/app-privacy-details/)
excludes on-device-only processing from collection. Nutrition-label publication
and legal attestation have NOT been verified through this API readback.

## Minimal owner gates

After independent cloud review of PR #25: approve the exact initial storefront
(recommend United States only; China mainland excluded); confirm rights-holder/
account legal declarations and App Privacy `Data Not Collected` publication;
then personally authorize/click final Submit for Review for existing 92.1.
Any already-completed declaration need only be confirmed, not repeated.
Review contact, build selection, URLs, screenshots, credentials and Pages do not
require re-entry. Manual release remains in place. S03-C remains LOCKED.

Engineering package can be READY_FOR_OWNER_SUBMISSION without pretending private
attestations or Apple submission have already passed. PR remains subject to cloud
audit; no self-approval/merge.
