# S03 App Store release plan

Updated: 2026-10-06
Status: S03-A READY; S03-B LOCKED.

Functional candidate: **Everwhile 0.1.0 (91.1)**
Merged main: `8a42edc58589da0c15673acf7e83a5d045ea2818`

## Objective

S03 is distribution work, not product development.

Do not change monitoring, Today, tutorial, privacy architecture, App Groups or capabilities unless a concrete App Store/distribution requirement forces a minimal reviewed change.

## Current Apple gates to respect

### Family Controls distribution capability

Apple requires Account Holder permission for the Family Controls entitlement before App Store distribution. The same request is required for Screen Time API extensions such as Device Activity Monitor and Device Activity Report.

The 91.1 signed TestFlight IPA proves the distribution profiles used by the current pipeline contain Family Controls allowances. S03-A must still record a portal-level check that Family Controls (Distribution) is Assigned for:
- `com.zhangsfish.elapse`
- `com.zhangsfish.elapse.monitor`
- `com.zhangsfish.elapse.report`

If the portal check is unavailable to automation, make it one explicit owner-only action. Do not infer “Assigned” solely from development configuration.

Reference:
https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement

### Public URLs

App Store Connect requires an iOS Privacy Policy URL. The app version also requires a Support URL.

Prepare public, no-login pages:
- Everwhile Privacy
- Everwhile Support

They may reuse the same approved public email/homepage already shown in-app.

Keep pages short and truthful. No analytics/trackers should be added merely to host them.

### App privacy

Current product architecture indicates a candidate “Data Not Collected” privacy label:
- no account/backend;
- no analytics/ads;
- Screen Time data remains in Apple report/monitor environments on device;
- no automatic upload of App identities/usage;
- support email is explicitly user initiated through the system.

S03-A must audit source/dependencies/network paths before drafting final App Store Connect privacy answers. Do not submit the label from assumptions alone.

### Screenshots

Current Apple requirement: provide at least one iPhone screenshot in an accepted required iPhone size; up to 10 screenshots per device size are allowed.

Prepare a small bilingual set, not a catalog.

Recommended 4-frame story:
1. Home — “Feel time passing.”
2. Choose apps + interval — “Choose what you want to notice.”
3. Quiet reminder / tutorial scene — “A reminder, not a restriction.”
4. Today — “See total, by hour, and by app.”

zh-Hans equivalents should be native copy, not literal awkward translation.

No private owner App identities or real usage data in public assets. Prefer sanitized simulator/tutorial artwork or an explicitly approved anonymized capture.

Reference:
https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications

### Metadata

Prepare English + Simplified Chinese:
- App name: Everwhile
- subtitle candidate;
- description;
- keywords;
- promotional text candidate;
- Support URL;
- Privacy Policy URL;
- Marketing URL optional;
- copyright;
- primary/secondary category recommendation;
- review notes.

Do not overclaim exact Screen Time timing, all-day reliability, blocking, coaching or productivity outcomes.

### Review notes

Reviewer should be told:
- no account/login;
- Everwhile uses Family Controls / DeviceActivity for individual owner-authorized Screen Time awareness;
- selected apps form one shared reminder pool;
- reminders are local and neutral;
- no Shield/blocking;
- Today is an Apple DeviceActivityReport hourly aggregate, not an exact session log;
- basic test path: authorize Screen Time -> choose apps -> select interval -> start;
- system Screen Time data may take time to populate.

### Storefronts

Default S03 recommendation: **United States first**.

Reason: China mainland distribution can require a valid ICP Filing Number and matching metadata; Apple surfaces “ICP Filing Number Missing/Invalid” as a China-mainland availability blocker.

Do not select China mainland unless the owner confirms the applicable filing is available and matches the App Store metadata.

English and zh-Hans localization can still ship with a US-first release.

References:
https://developer.apple.com/help/app-store-connect/reference/app-information/app-and-submission-statuses
https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-for-your-app-on-the-app-store/

## S03 stages

| Stage | Status | Scope |
|---|---|---|
| S03-A | **READY** | entitlement/account preflight, public pages, store copy, screenshot assets, privacy/review drafts |
| S03-B | LOCKED | App Store Connect data entry, exact build selection, owner region approval, submit to App Review |
| S03-C | LOCKED | review response / rejection fixes / owner-approved public release |

S03-A must not submit App Review.
S03-B must not automatically release publicly; use owner-controlled manual release unless the owner explicitly chooses otherwise.
