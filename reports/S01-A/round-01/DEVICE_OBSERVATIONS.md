# S01-A device observations — READY_FOR_AUDIT

Owner confirms installed build `0.1.0 (44.1)`; upload SHA `514ae6958d018bf1d5861f834cbea2efab4a4a97`. Provenance: owner's natural-language report and two phone screenshots provided in the Codex chat on 2026-10-04; screenshots are **not** copied into this public repository.

Only short owner actions were in scope: confirm build; keep two selected Apps; register 5m, close/reopen, Stop, register 15m, Stop and restore 5m. No 5/15-minute wait, all-day usage, S01-B recovery, or Today retest was requested.

## Owner observations and visible evidence

- 5-minute configuration #5 short ID `9557434b`: screenshot shows configured/registered interval 5m, planned events **299**, system-registered events **299**, state “已登记，等待真实回调”, registration error “无”. No callback/request was expected or tested.
- After closing/reopening Everwhile, owner reports the configuration/registration persisted. The reopening screenshot was not supplied separately; this is owner-reported, not independent screenshot proof.
- After Stop, 15-minute configuration #6 short ID `376a708c`: screenshot shows configured/registered interval 15m, planned events **99**, system-registered events **99**, same registered state, error “无”. IDs differ as required.
- Owner stopped the 15m configuration and restored the picker to 5m. The UI temporarily still showed **99** planned/registered events from the last **registration**; after owner pressed Start, it showed **299** for the newly registered 5m configuration. This is expected because configured interval and last registration snapshot are distinct. Owner then confirmed the monitor was stopped and the selected-App count remained **2**. The final 5m registration short ID was not supplied and is not needed for this gate.

## Unexpected full-screen prompt, separately triaged

Owner reports that after upgrading, before manually starting monitoring, a full-screen time-limit prompt appeared while using an app, offering to extend/reset time. The owner checked and explicitly confirmed this was the iPhone's own Screen Time reminder, **not Everwhile**; they do not want this behavior added to the product. Repo source inspection independently found no `ManagedSettingsStore`, shield configuration/extension, or full-screen presentation path; Everwhile's monitor extension submits ordinary `UNNotificationRequest` pulses only. The system prompt is not counted as an S01-A pulse or failure. No extra usage test is requested.

## Gate interpretation

Default 5m large-ladder registration: **PASS — owner/device screenshot (299/299, no error)**.
15m alternate registration/new identity: **PASS — owner/device screenshot (99/99, new ID, no error)**.
Reopen persistence: **PASS — owner report**.
Stop and restore 5m: **PASS — owner confirms final stopped state with 5m restored**.
Selected-App count in 44.1: **PASS — owner reports two; not shown in supplied screenshots**.
5/15m callback or visible notification: **NOT_RUN_OUT_OF_SCOPE**.
