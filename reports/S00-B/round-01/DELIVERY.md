# S00-B round 01 — delivery

Status: READY_FOR_AUDIT (not self-approved). Base main: `00160c625b35dfc36f43b868137500ba3da35066`. Branch: `codex/s00-b-first-real-pulse`. Draft [PR #15](https://github.com/Zhangsfish/Elapse/pull/15). Code implementation SHA: `8b1672c5718292b6723fbff9d8afc7f577601d30`; tested/upload SHA: `383142aa62b0029f99380f7235908533d51eb10d`.

Static source findings before changes:

- Six threshold events use the same `selection.applicationTokens` set: SOURCE, not real-device shared-pool proof.
- Receipt key was calendar date + event, so same-day stop/start could suppress a new 5-minute notification: SOURCE risk.
- Picker remained editable while monitoring, leaving the registered set unchanged: SOURCE mismatch risk.
- Extension callback and notification-request results existed only in OSLog, inaccessible to the owner on Windows + TestFlight: SOURCE observability gap.
- With `includesPastActivity=false`, `minutes today` was not a truthful description of the monitoring-start threshold: SOURCE copy error.

Implementation: unique activity/experiment IDs, cross-process app-owned diagnostics in an App Group, frozen selection while registered, and neutral monitoring-start copy. The App Group stores no tokens, app names or DeviceActivityReport data. Local Python logic checks: 10 PASS.

[First upload attempt](https://github.com/Zhangsfish/Elapse/actions/runs/37127540352) could not export due to missing App Group capability/profile. A [read-only capability probe](https://github.com/Zhangsfish/Elapse/actions/runs/37128404114) confirmed both App IDs lacked `APP_GROUPS`. The group was then registered and assigned through the existing Apple Developer session to the main App and Monitor only. See [capability evidence](evidence/APP_GROUP_CAPABILITY.md). Temporary probe and one-time upload triggers were removed after use.

[Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37128998592) PASS. [Explicit upload run](https://github.com/Zhangsfish/Elapse/actions/runs/37128996204) PASS for `0.1.0 (32.1)`: unsigned archive, automatic distribution export, exact signed IPA audit, upload accepted, Apple processing `VALID`, audience `INTERNAL_ONLY`, state `IN_BETA_TESTING`, assigned to internal group. The final IPA's main App and Monitor App Group signature claims and embedded profile allowances all matched `group.com.zhangsfish.elapse`; Report had no App Group requirement. Upload/processing success was kept separate from the subsequently reported device result.

Device observations are now recorded in [DEVICE_OBSERVATIONS.md](DEVICE_OBSERVATIONS.md): first measured experiment `5c520eb7` accumulated about 2m18s + 1m44s + 1m across the two selected Apps before a visible pulse; app-owned current-experiment callback and accepted request were observed. Same-day fresh experiment `722d1c70` independently received a callback/request and visible pulse after approximately five minutes. Selection was locked while running, unlocked after Stop; app relaunch preserved an earlier experiment identity. These are OWNER_REPORT/OWNER_SCREENSHOT observations, not OS-derived exact usage duration. No stale callback happened on device; rejection semantics have SOURCE/UNIT_TEST evidence. Notification wording was not captured. The registration row's stale “等待真实回调” text after callback receipt is a minor UI wording note. S00-C and Today remain NOT_RUN/LOCKED.

Apple references: [combined event and includesPastActivity](https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/init%28applications%3Acategories%3Awebdomains%3Athreshold%3Aincludespastactivity%3A%29), [App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups), [App Groups entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.application-groups).
