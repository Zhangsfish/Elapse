# S00-B round 01 — delivery

Status: IN_PROGRESS. Base main: `00160c625b35dfc36f43b868137500ba3da35066`. Branch: `codex/s00-b-first-real-pulse`. Draft [PR #15](https://github.com/Zhangsfish/Elapse/pull/15). Source commit: `8b1672c5718292b6723fbff9d8afc7f577601d30`; attempted-upload commit: `3f8f23154a054957b725412b94984c86f9527dcb`.

Static source findings before changes:

- Six threshold events use the same `selection.applicationTokens` set: SOURCE, not real-device shared-pool proof.
- Receipt key was calendar date + event, so same-day stop/start could suppress a new 5-minute notification: SOURCE risk.
- Picker remained editable while monitoring, leaving the registered set unchanged: SOURCE mismatch risk.
- Extension callback and notification-request results existed only in OSLog, inaccessible to the owner on Windows + TestFlight: SOURCE observability gap.
- With `includesPastActivity=false`, `minutes today` was not a truthful description of the monitoring-start threshold: SOURCE copy error.

Implementation: unique activity/experiment IDs, cross-process app-owned diagnostics in an App Group, frozen selection while registered, and neutral monitoring-start copy. The App Group stores no tokens, app names or DeviceActivityReport data. [Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37127372760) PASS at source commit and [ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37127543030) PASS at attempted-upload commit. Local Python logic checks: 10 PASS.

[Explicit upload run](https://github.com/Zhangsfish/Elapse/actions/runs/37127540352) at `3f8f231...` produced unsigned build/archive and verified their App Group declarations, then failed during distribution export (exit 70). Safe categories: `API_AUTHORIZATION`, `NO_MATCHING_PROFILE`; no signed IPA or TestFlight upload, so version `0.1.0 (30.1)` is **not available**. This does not prove that the final distribution signature or profile grants the App Group. Next: read-only App Store Connect capability probe for the main and Monitor App IDs; the API cannot by itself verify registration or association of the particular group. No S00-B device gate is PASS yet.

The first [read-only probe run](https://github.com/Zhangsfish/Elapse/actions/runs/37128145747) failed before loading credentials because shallow checkout omitted the marker's parent commit. The checkout depth is corrected for the retry.

The second [probe run](https://github.com/Zhangsfish/Elapse/actions/runs/37128255415) passed marker validation but the API's filtered bundle-ID list did not find the main App ID. It did not disclose whether the App ID truly is absent or the filter/API-key view is restricted; an unfiltered-list cross-check will resolve that distinction without logging other identifiers.

The [cross-check](https://github.com/Zhangsfish/Elapse/actions/runs/37128404114) found both exact App IDs and confirmed that each lacked `APP_GROUPS`. Using the existing signed-in Apple Developer Portal session, the App Group was registered and associated with the main App and Monitor (not Report). See [capability evidence](evidence/APP_GROUP_CAPABILITY.md). This is portal configuration, **not** signed artifact proof. The temporary probe workflow/script/marker were removed after diagnosis; the next explicit upload must still verify final signature and embedded profile.

Apple references: [combined event and includesPastActivity](https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/init%28applications%3Acategories%3Awebdomains%3Athreshold%3Aincludespastactivity%3A%29), [App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups), [App Groups entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.application-groups).
