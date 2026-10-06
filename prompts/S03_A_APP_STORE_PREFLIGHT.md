# S03-A — App Store preflight, metadata and assets

Task ID: S03-A
Branch: `codex/s03-a-app-store-preflight`

## Start

Read, in order:
1. `AGENTS.md`
2. `STATUS.md`
3. `audits/S02/S02_B_AUDIT_2026-10-06.md`
4. `docs/S03_APP_STORE_RELEASE_PLAN.md`
5. `docs/PRODUCT_DECISIONS.md`
6. `docs/PRODUCT_SPEC.md`
7. current About & Support / localization / PrivacyInfo.xcprivacy / entitlements / project.yml
8. current release workflows and 91.1 evidence

Reference main at task creation:
`8a42edc58589da0c15673acf7e83a5d045ea2818`

If GitHub moved, STATUS/current main are authoritative.

## Hard rule

**Feature freeze.**

Do not redesign the product.
Do not touch S01 lifecycle, Today semantics, tutorial, App Group or capabilities unless a concrete App Store blocker requires a separately documented minimal change.

This stage does **not** submit App Review and does not make the app public.

## A. Family Controls distribution gate

Use current signed 91.1 evidence first.

Prepare a release-gate record for these three Bundle IDs:
- `com.zhangsfish.elapse`
- `com.zhangsfish.elapse.monitor`
- `com.zhangsfish.elapse.report`

Record:
- signed IPA Family Controls claim/profile allowance evidence;
- required App Group evidence;
- what that proves;
- what still requires portal confirmation.

Apple requires Family Controls distribution permission for the app and each Screen Time API extension.

If GitHub/CI cannot prove the Developer portal Capability Requests status, stop and give the owner **one exact portal action**:
Certificates, Identifiers & Profiles -> Capability Requests -> Family Controls -> verify Assigned / provisioning support for all three App IDs.

Do not ask for Apple passwords, .p8 keys, profiles or screenshots containing secrets.

## B. Public Support + Privacy pages

Create a minimal static public-page source in the repo, suitable for GitHub Pages or another no-login static host.

Use the already approved:
- support email: `zhangs.taq@gmail.com`
- personal homepage: `https://zhang-shuo-portfolio.vercel.app/`

Privacy page should accurately state, in concise English + Simplified Chinese:
- Screen Time data is processed on the user's device through Apple's Screen Time APIs;
- Everwhile does not upload Screen Time usage data to an Everwhile backend;
- no analytics/ads SDK;
- support email is user initiated and processed by the user's/email provider;
- contact email;
- last updated date.

Support page:
- what Everwhile does in 2–3 lines;
- quick start in 3 short steps;
- email / copyable email text;
- personal homepage;
- privacy link.

Do not add cookies, analytics or remote JS frameworks.

If hosting cannot be activated automatically, create the exact files and a one-action owner deployment note. Do not invent a live URL until it actually resolves.

## C. App privacy audit

Independently scan:
- source;
- PrivacyInfo.xcprivacy;
- dependencies;
- network APIs;
- analytics/ad SDKs;
- support/email/browser behavior.

Produce:
`docs/APP_STORE_PRIVACY_DRAFT.md`

It must distinguish:
- verified app behavior;
- proposed App Store Connect answers;
- unresolved portal questions.

Do not simply copy “Data Not Collected” without source evidence.

## D. Store metadata

Create:
`docs/APP_STORE_METADATA.md`

English + zh-Hans drafts for:
- name;
- subtitle (<=30 chars);
- promotional text;
- description;
- keywords;
- Support URL placeholder until live;
- Privacy Policy URL placeholder until live;
- Marketing URL candidate;
- copyright;
- primary/secondary category recommendation.

Preferred positioning:
Everwhile makes selected-app time perceptible through neutral reminders and a local Today view.

Avoid:
- digital detox;
- addiction cure;
- productivity score;
- blocking/focus lock;
- precise real-time usage claims;
- AI.

Recommend a category with reasoning; do not silently set portal values.

## E. App Review notes

Create:
`docs/APP_REVIEW_NOTES.md`

Explain the exact reviewer path:
1. open Everwhile;
2. allow Screen Time access;
3. choose one or more apps in Apple's picker;
4. choose 5/10/15/30/60-minute interval;
5. allow notifications if requested;
6. Start monitoring;
7. Today is a local DeviceActivityReport and may populate after system usage data is available.

Explicitly say:
- no login/demo account required;
- no blocking/Shield;
- reminders are local awareness notifications;
- selected-app choices are tokenized by Apple's Family Controls UI;
- Today is hourly aggregate, not exact sessions.

Keep notes concise and reviewer-oriented.

## F. Screenshot package

Prepare an App Store screenshot source set for English + zh-Hans.

Do not use private owner app names/usage.

Use actual app UI / tutorial artwork / sanitized simulator states only.

Target a small 4-image story:
1. Home
2. Choose apps / interval
3. neutral reminder
4. Today

Create:
`store-assets/en/`
`store-assets/zh-Hans/`

Include:
- raw capture;
- final composed PNG;
- a manifest recording source commit/build, locale, dimensions and marketing caption.

Follow Apple's current accepted iPhone screenshot dimensions and no-alpha requirement.

Do not fabricate a live Today report with fake exact sessions. If the tutorial Today illustration is used, make the marketing frame clearly represent the in-app tutorial/sample rather than pretending it is private real usage.

## G. Region + account checklist

Create:
`docs/APP_STORE_OWNER_CHECKLIST.md`

Default recommendation:
- first storefront: United States;
- price: Free;
- version: 0.1.0;
- exact functional baseline: 91.1 until/unless a later release candidate is deliberately created.

Record China mainland as:
`BLOCKED_UNTIL_ICP_STATUS_CONFIRMED`
unless the owner supplies a valid filing status.

Also include owner-only fields that must be filled in the portal:
- Account Holder agreements;
- age rating questionnaire;
- App Review contact name/email/phone;
- Family Controls distribution Assigned status;
- App Store Connect app record/SKU if not already created;
- release method (recommend manual release).

Never commit private phone number, identity documents, Apple credentials or API keys.

## H. Verification

Run ordinary CI only if repo files/scripts change in ways covered by CI.

Do not create a new TestFlight build just for Markdown/store screenshots unless actual runtime/build resources change.

At completion:
- one PR;
- no App Review submission;
- no public release;
- all owner-only blockers clearly separated from completed prep.

Stop at `READY_FOR_AUDIT`.
Do not unlock S03-B.
