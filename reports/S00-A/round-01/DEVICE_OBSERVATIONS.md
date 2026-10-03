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

Additional observation: the screen displays monitoring `Running`, diagnostic `registered_not_verified`, and result `监控登记成功；尚未证明收到使用时间回调。` This confirms only monitor registration, not a Screen Time callback. The next guided phone action is to tap the visible `Stop monitoring` button so this S00-A check does not drift into a usage-threshold test.

Do not perform five- or thirty-minute usage tests or Today report review in this stage.
