# S03-B portal closeout cloud audit — 2026-10-07

PR: #25  
Audited head: `abd947117479c34f15985948595afca7d483903b`  
Merge: `2bce5c0a5d3ab0f0e3c5219c7120e7d8ea4a03ab`  
Verdict: **PASS — READY_FOR_OWNER_SUBMISSION**

## Independent scope check

Compared PR #25 against its main base `3afd08da4408860e9a2236904fe92c543f4d37d8`.

Frozen runtime paths are unchanged:

- App/
- Shared/
- MonitorExtension/
- ReportExtension/
- Localization/
- AppResources/
- project.yml

No new RC, TestFlight build, App Review submission or public release was created by
the closeout PR.

## Release candidate

Existing exact App Review candidate remains:

- Everwhile **0.1.0 (92.1)**
- source checkout: `10b9e29f9d730e83a1fbd852fa49b09d83dd155a`
- exact IPA SHA256:
  `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`
- ASC processing: **VALID**
- build audience: **APP_STORE_ELIGIBLE**
- non-exempt encryption: **FALSE**
- build associated with store version 0.1.0
- release type: **MANUAL**
- version state: **PREPARE_FOR_SUBMISSION**

Existing signed-artifact evidence proves Apple Distribution, Family Controls
distribution claim/profile allowance and get-task-allow=false on App / Monitor /
Report; required App Group passes on App / Monitor.

## Public pages

Support and Privacy deployment evidence records anonymous HTTPS 200, exact static-source
match, bilingual content, valid cross-links, mailto support and no remote JS/analytics:

- https://zhangsfish.github.io/Elapse/
- https://zhangsfish.github.io/Elapse/privacy.html

Both URLs were also saved to / read back from the relevant ASC localizations.

## Metadata / review package

Current ASC safe readback matches repository evidence for:

- English + zh-Hans listing copy;
- owner-final English Promotional Text, 165 characters;
- metadata length limits;
- screenshots already uploaded by owner;
- review notes;
- existing review contact completeness;
- build 92.1 association;
- empty optional Marketing URL;
- manual release.

The owner-final English Promotional Text is:

`Choose the apps you want to notice and set a 5-minute interval. Everwhile sends reminders based on cumulative use and shows total, hourly, and per-app time in Today.`

## App Privacy recommendation

Source audit supports:

- Tracking: **No**
- Data collection question: **No**
- Resulting nutrition label: **Data Not Collected**

The app has no automatic off-device analytics/ads/identifier/location/usage upload.
Screen Time processing remains on-device. A user-initiated external mail client is
voluntary support correspondence and is not treated here as automatic app collection.

This is a source/release recommendation, not a claim that the owner has already
published the ASC privacy attestation.

## Family Controls portal readback

The unread Capability Requests UI state is **not a release blocker** for this package.
The exact accepted App Store distribution artifact and ASC eligibility are stronger
operational evidence that distribution provisioning is functioning.

Portal Assigned UI remains optional owner readback only; this audit does not claim it
was visually observed.

## CI

At audited head:

- S03 secret-free store preflight: **PASS**
- S03 review-eligible App Store RC tooling verification: **PASS**
- 60 Swift + 48 Python tests: **PASS**
- ordinary S00 build/tests had passed while repeated simulator UI smoke was still
  running at audit time.

The still-running ordinary UI smoke is non-blocking for this closeout because PR #25
contains no product/runtime changes; the accepted runtime and review RC already have
their own completed functional/signing evidence.

## Remaining owner-only gates

Engineering and repository work are complete for submission preparation.

Before Submit for Review, owner must only confirm the account/legal items that cannot be
attested by repository automation:

1. exact initial storefront — recommendation: **United States only**, China mainland excluded;
2. legal rights-holder/copyright declaration;
3. App Privacy publication/attestation using **Data Not Collected / Tracking No**;
4. any other ASC account agreements presented to the Account Holder;
5. final explicit authorization to submit existing **0.1.0 (92.1)**.

Private review contacts are already complete. Screenshots, build association, Support
URL, Privacy URL and review notes do not require re-entry.

## Decision

**S03-B engineering package PASS — READY_FOR_OWNER_SUBMISSION.**

This does not submit the app and does not unlock public release. S03-C remains locked
until App Review returns a result.
