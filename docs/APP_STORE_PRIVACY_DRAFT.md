# App Privacy final recommendation — independently source-audited

2026-10-07 · frozen runtime fab87acc8f4b863451d9c91ee7605b4c33c47789,
unchanged in review RC 0.1.0 (92.1). This recommendation is not an ASC publication attestation.

## Verified source behavior

| Surface | Evidence and boundary |
|---|---|
| Selection/settings | App/ElapseModel.swift stores opaque FamilyActivitySelection and interval locally in UserDefaults; no app-name extraction |
| Configuration/receipts | Shared/PulseExperimentStore.swift uses a locked, protected local App Group JSON file; app-owned configuration/lifecycle/receipt diagnostics, not report usage |
| Today | ReportExtension/ElapseReportExtension.swift aggregates filtered ApplicationActivity.totalActivityDuration only inside the extension; token Labels and hourly bars stay there; no App Group entitlement on Report |
| Notifications | MonitorExtension/ElapseMonitorExtension.swift requests local UserNotifications; neutral threshold copy, no push service |
| Logs | OSLog safe states/counts/error codes, no raw token or app name; no logger-upload service |
| Contact | AboutSupportView.swift opens mailto: only on user tap; email copy copies the fixed support address, not usage/diagnostics |
| Browser | User-initiated personal homepage openURL, no embedded webview or automatic request |
| Dependencies | Package.swift has no external package dependencies; project.yml has only local targets and Apple framework imports; ManagedSettings import is used for token Labels, not a shield |
| Network/SDK scan | No URLSession, URLRequest, NWConnection, embedded webview, analytics/ad/crash-upload SDK in runtime source. URL strings only explicit support/homepage/settings links |
| Privacy manifest | AppResources/PrivacyInfo.xcprivacy: tracking=false, no tracking domains, no collected data declarations; UserDefaults CA92.1. App/Monitor package it; Report has no UserDefaults access and no new manifest requirement inferred |

These are static source observations, reinforced by the accepted packaging evidence;
not packet-capture evidence or a guarantee about Apple's OS services.

`CA92.1` matches app-private UserDefaults in ElapseModel and TutorialVisitStore.
The App Group state store uses a local JSON file, not a shared UserDefaults suite;
its existence alone does not require the shared-defaults reason `1C8F.1`.
See [Apple's reason definitions](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons).

## Exact recommended App Store Connect answers

- Tracking: **No**.
- “Do you or your third-party partners collect data from this app?”: **No**.
- Resulting label: **Data Not Collected**; no automatic data categories to add.
- Local Screen Time/token/configuration usage is not off-device collection. Apple
  explicitly distinguishes on-device-only processing from data collection.
- No automatic analytics, identifiers, ads, location, contacts or usage upload.
- Support messages are **not** described as never leaving the device. Mail is
  voluntary, external to the app, and may include email address/name/user content.
  The app has no support submission form, mail composer integration, attachments,
  prefilled diagnostic body or sending service: it opens an external `mailto:`
  containing the fixed support destination only. A user independently composing
  mail in their mail client does not make this binary automatically collect Email
  Address or Customer Support. Do not claim that the mailbox receives no personal
  information. Apple's optional-support exception has multiple conditions; if a
  future in-app collection form or marketing reuse is introduced, reassess it
  rather than assuming all support collection is exempt.
- Privacy URL: https://zhangsfish.github.io/Elapse/privacy.html — **LIVE_VERIFIED**,
  saved/read back in both ASC languages. English/zh-Hans public policy accurately
  separates local app processing, voluntary mail and web-host-provider requests.

## Independent release gates

Family Controls Assigned UI status is not proved by this privacy audit; exact 92.1
distribution provisioning closes the release path independently (optional UI readback).
App privacy declarations, required-reason manifest, final signatures and capability
approval are separate. No Privacy Nutrition Label answer was saved by this closeout;
owner should confirm/publish the recommended answer in ASC. Public privacy URL was saved.

Official guidance checked 2026-10-07:
[App Privacy details](https://developer.apple.com/app-store/app-privacy-details/)
(on-device processing and optional customer support),
[required-reason API declarations](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
