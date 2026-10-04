# S01-A round 01 — WAITING_FOR_OWNER_TEST

Base main: `edbb69772478177ab58c13cc211c917d421b3da6`.
Branch: `codex/s01-a-day-range-interval`.
PR: https://github.com/Zhangsfish/Elapse/pull/18 (open; Codex does not merge).

Implementation code SHA: `bac88e961e0a1dcfbf12c4bc5285c182a72a47a8`.
Prepare marker SHA: `ca68109b2ae96dbcd142f68810c98c1cad6790d6`.
Tested/upload SHA: `514ae6958d018bf1d5861f834cbea2efab4a4a97` (same runtime code; marker-only successors). One-time markers were removed after the successful upload. Evidence-only PR head follows separately.
Internal build: Everwhile `0.1.0 (44.1)`.

## Implementation boundary

- S00 six-threshold constants remain for legacy snapshot migration/tests; product `DayPulsePlan` is separate. Supported interval values: 5 (default), 10, 15, 30, 60 minutes. The interval is stored in app-local `UserDefaults`.
- One current-day activity uses all selected opaque ApplicationTokens in every event, with `includesPastActivity=false`. The 25-hour-exclusive candidate ceiling yields: 5→299 events/max 1495m; 10→149/1490m; 15→99/1485m; 30→49/1470m; 60→24/1440m. This is a planning ceiling, **not** a DST or rollover implementation.
- Each Start creates a new UUID-backed configuration identity. Stop is required before changing interval or selected Apps. Existing receipts are cleared for a new identity; old callbacks/completions fail closed. UI/diagnostic lists only bounded recent receipts and counts, not hundreds of rows.
- Start compares `DeviceActivityCenter.events(for:)` count with the plan; mismatch fails closed. Safe registration error categories are retained. Success is still not a callback/notification guarantee.
- Pulse wording refers to this monitoring round, never Today total. Today/report extension and privacy boundary are untouched.

## Evidence status

| Layer | Status |
|---|---|
| Source model and tests | PASS — implementation SHA and both marker-only successors |
| Ordinary secret-free CI | PASS — [implementation run 37179340332](https://github.com/Zhangsfish/Elapse/actions/runs/37179340332), [upload SHA run 37179600062](https://github.com/Zhangsfish/Elapse/actions/runs/37179600062) |
| Prepare-only archive | PASS — [run 37179460432](https://github.com/Zhangsfish/Elapse/actions/runs/37179460432); upload step skipped |
| Signed IPA / TestFlight processing | PASS — [run 37179597166](https://github.com/Zhangsfish/Elapse/actions/runs/37179597166); exact IPA audit, upload accepted, processing VALID, INTERNAL_ONLY / IN_BETA_TESTING, internal group assigned |
| Target iPhone default 5m/299-event registration | NOT RUN |
| Reopen same config, 15m/99-event new config, restore 5m | NOT RUN |

Apple's public 20-activity limit is not an event-count guarantee. Official references and DST boundary are recorded in `docs/APPLE_PLATFORM_NOTES.md`. No long usage session or pulse delivery retest is requested in S01-A.

Local checks: `python -m unittest discover -s scripts/tests -v` PASS (10 tests); `git diff --check` PASS. GitHub-hosted macOS ordinary CI compiled App + Monitor + Report for Simulator and ran Swift logic tests. Prepare/upload jobs compiled unsigned iPhone Release build and inspected the final archive. Apple signing/upload status is distinct from the still-unrun target-iPhone registration gate.
