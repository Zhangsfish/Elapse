# S01-A device observations — registration observed; final stopped baseline pending

Owner confirms installed build `0.1.0 (44.1)`; upload SHA `514ae6958d018bf1d5861f834cbea2efab4a4a97`. Provenance: owner's natural-language report and two phone screenshots provided in the Codex chat on 2026-10-04; screenshots are **not** copied into this public repository.

Only short owner actions are in scope: confirm build; keep two selected Apps; default 5m Start and inspect configuration ID, planned/observed count, registered state and error; close/reopen and inspect same ID; Stop; choose 15m and Start with a new ID/99 events; Stop and restore 5m. Codex will request **one action at a time** after the build is ready. No 5/15-minute wait, all-day usage, S01-B recovery, or Today retest.

## Owner observations and visible evidence

- 5-minute configuration #5 short ID `9557434b`: screenshot shows configured/registered interval 5m, planned events **299**, system-registered events **299**, state “已登记，等待真实回调”, registration error “无”. No callback/request was expected or tested.
- After closing/reopening Everwhile, owner reports the configuration/registration persisted. The reopening screenshot was not supplied separately; this is owner-reported, not independent screenshot proof.
- After Stop, 15-minute configuration #6 short ID `376a708c`: screenshot shows configured/registered interval 15m, planned events **99**, system-registered events **99**, same registered state, error “无”. IDs differ as required.
- Owner stopped the 15m configuration and restored the picker to 5m. The UI temporarily still showed **99** planned/registered events from the last **registration**; after owner pressed Start, it showed **299** for the newly registered 5m configuration. This is expected because configured interval and last registration snapshot are distinct. The final 5m registration short ID and final stopped state were not supplied.

## Unexpected full-screen prompt, separately triaged

Owner reports that after upgrading, before manually starting monitoring, a full-screen time-limit prompt appeared while using an app, offering to extend/reset time. No screenshot or exact wording of that prompt was supplied. Repo source inspection found no `ManagedSettingsStore`, shield configuration/extension, or full-screen presentation path; Everwhile's monitor extension submits ordinary `UNNotificationRequest` pulses only. Apple's own Screen Time App Limits/Downtime can show limit screens and additional-time choices. Therefore this prompt is **not attributed to Everwhile** on current evidence; its exact source is UNKNOWN and it is not counted as an S01-A pulse or failure. No extra usage test is requested.

## Gate interpretation

Default 5m large-ladder registration: **PASS — owner/device screenshot (299/299, no error)**.
15m alternate registration/new identity: **PASS — owner/device screenshot (99/99, new ID, no error)**.
Reopen persistence: **PASS — owner report**.
Stop and restore 5m: **PARTIAL — restored and re-started; final stopped baseline to confirm**.
Selected-App count in 44.1: **NOT independently captured in supplied screenshots** (accepted prior S00 baseline was two).
5/15m callback or visible notification: **NOT_RUN_OUT_OF_SCOPE**.
