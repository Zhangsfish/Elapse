# S00-B round 01 — delivery

Status: IN_PROGRESS. Base main: `00160c625b35dfc36f43b868137500ba3da35066`. Branch: `codex/s00-b-first-real-pulse`. Code/tested/upload SHA, PR head, new version/build and CI URLs: NOT_RUN / not yet assigned.

Static source findings before changes:

- Six threshold events use the same `selection.applicationTokens` set: SOURCE, not real-device shared-pool proof.
- Receipt key was calendar date + event, so same-day stop/start could suppress a new 5-minute notification: SOURCE risk.
- Picker remained editable while monitoring, leaving the registered set unchanged: SOURCE mismatch risk.
- Extension callback and notification-request results existed only in OSLog, inaccessible to the owner on Windows + TestFlight: SOURCE observability gap.
- With `includesPastActivity=false`, `minutes today` was not a truthful description of the monitoring-start threshold: SOURCE copy error.

Implementation in progress: unique activity/experiment IDs, cross-process app-owned diagnostics in an App Group, frozen selection while registered, and neutral monitoring-start copy. The App Group stores no tokens, app names or DeviceActivityReport data. Apple capability/provisioning and signed-artifact checks are pending. No S00-B device gate is PASS yet.

Apple references: [combined event and includesPastActivity](https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/init%28applications%3Acategories%3Awebdomains%3Athreshold%3Aincludespastactivity%3A%29), [App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups), [App Groups entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.application-groups).
