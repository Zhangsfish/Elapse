# S00-A round 01 — device observations

The owner reports an update and supplied three screenshots in this Codex conversation. The images are not committed or copied to this public repository. The app's own diagnostic panel shows Everwhile `0.1.0 (27.1)`. These are owner/device observations, separate from CI and Apple API evidence.

| Step | Result | Evidence |
|---|---|---|
| New build installed and version checked | PASS | Owner report and in-app version `0.1.0 (27.1)` in screenshot |
| Individual Screen Time authorization | PASS | In-app status `已授权` in screenshot; no threshold behavior inferred |
| Two App tokens selected | HOLD — 5 selected | In-app `App 数量` and diagnostic both show 5 application tokens, categories 0, web domains 0. The planned exactly-two selection has not been exercised. App identities/tokens were not requested. |
| Selection remains after app restart | NOT_RUN | — |
| Notification permission and alert setting | PASS | In-app `已允许` / `已开启` in screenshot |
| Ordinary test notification request | PASS — request only | `LastAction=ordinary_test_notification`, `LastResult=request_accepted_delivery_unobserved`, `ErrorCode=none` in screenshot |
| Test notification visibly delivered | NOT_RUN | — |
| Stop monitoring control | PASS — owner report | Owner says the displayed status changed after tapping `Stop monitoring`; no post-stop callback behavior inferred. |
| Banner after approximately five minutes of selected-App use | OWNER_REPORTED_UNCLASSIFIED | Owner saw a top-of-screen notification. Its title/body and timing relative to Stop are not yet known, so it is not attributed to the ordinary test request or the Screen Time threshold callback. No five-minute retest requested. |

Earlier screenshot: monitoring `Running`, diagnostic `registered_not_verified`, and result `监控登记成功；尚未证明收到使用时间回调。` This confirms only monitor registration, not a Screen Time callback. The owner subsequently reports that Stop changed the displayed status. The next clarification is the banner's text and whether it appeared before or after Stop; it does not require more App use.

The owner also requested a choice between a top banner and a full-screen reminder. Apple's ordinary notification APIs do not provide an app-controlled full-screen takeover while another app is foreground; iOS notification placement is user-controlled. The request is recorded for product review, not implemented in S00-A. See [Apple notification settings](https://support.apple.com/guide/iphone/change-notification-settings-iph7c3d96bab/ios) and [Apple notification content extension](https://developer.apple.com/documentation/usernotificationsui/customizing-the-appearance-of-notifications). Do not request further five- or thirty-minute usage tests or Today report review in this stage.
