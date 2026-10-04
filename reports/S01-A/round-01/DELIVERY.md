# S01-A round 01 — in progress

Base main: `edbb69772478177ab58c13cc211c917d421b3da6`.
Branch: `codex/s01-a-day-range-interval`.
Code/tested/upload SHA, PR, CI runs and TestFlight build: **NOT RUN** until produced below.

## Implementation boundary

- S00 six-threshold constants remain for legacy snapshot migration/tests; product `DayPulsePlan` is separate. Supported interval values: 5 (default), 10, 15, 30, 60 minutes. The interval is stored in app-local `UserDefaults`.
- One current-day activity uses all selected opaque ApplicationTokens in every event, with `includesPastActivity=false`. The 25-hour-exclusive candidate ceiling yields: 5→299 events/max 1495m; 10→149/1490m; 15→99/1485m; 30→49/1470m; 60→24/1440m. This is a planning ceiling, **not** a DST or rollover implementation.
- Each Start creates a new UUID-backed configuration identity. Stop is required before changing interval or selected Apps. Existing receipts are cleared for a new identity; old callbacks/completions fail closed. UI/diagnostic lists only bounded recent receipts and counts, not hundreds of rows.
- Start compares `DeviceActivityCenter.events(for:)` count with the plan; mismatch fails closed. Safe registration error categories are retained. Success is still not a callback/notification guarantee.
- Pulse wording refers to this monitoring round, never Today total. Today/report extension and privacy boundary are untouched.

## Evidence status

| Layer | Status |
|---|---|
| Source model and tests | IN_PROGRESS |
| Ordinary secret-free CI | NOT RUN |
| Prepare-only archive | NOT RUN |
| Signed IPA / TestFlight processing | NOT RUN |
| Target iPhone default 5m/299-event registration | NOT RUN |
| Reopen same config, 15m/99-event new config, restore 5m | NOT RUN |

Apple's public 20-activity limit is not an event-count guarantee. Official references and DST boundary are recorded in `docs/APPLE_PLATFORM_NOTES.md`. No long usage session or pulse delivery retest is requested in S01-A.
