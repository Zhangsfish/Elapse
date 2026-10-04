# S01-B round 01 — IN_PROGRESS

Base main: `07b889afe456aa408104b3643b2c8281d3cf99a1`.
Branch: `codex/s01-b-daily-lifecycle`.
PR/code/tested/upload SHA and build: **NOT RUN** until verified.

## Implementation intent

- Product schedule is daily recurring (`00:00`–`23:59:59`, `repeats=true`) with the accepted 299-event default ladder and `includesPastActivity=false`.
- App-owned desired intent, exact system registration, and actual interval lifecycle evidence are distinct. A 299/299 registration with no current `intervalDidStart` remains **unverified for current-day counting**.
- Monitor extension records idempotent per-local-cycle generation/anchor/start/end; new cycles clear only interval receipts. Callback guard rejects unanchored and physically impossible premature thresholds without notification requests. Old config and old interval-generation completion paths fail closed.
- App launch/foreground/refresh and authorization status changes reconcile desired intent with system registration. Missing/mismatched registration creates one new UUID-backed config with a safe recovery reason; failure is held without a refresh loop. Stop persists desired=OFF before removing system activities.
- No Shield/ManagedSettings, Today report changes, account/cloud/AI, or public distribution.

## Evidence status

| Layer | Status |
|---|---|
| Source and unit tests | IN_PROGRESS |
| Secret-free ordinary CI | NOT RUN |
| Prepare-only archive | NOT RUN |
| Signed IPA / internal TestFlight | NOT RUN |
| Target iPhone 299/299 + lifecycle anchor | NOT RUN |
| App reopen / one iPhone reboot / Stop no resurrection | NOT RUN |
| True midnight rollover and revoke/regrant on device | NOT_RUN_OUT_OF_SCOPE — S01-C |

The preimplementation 44.1 midnight observation is historical evidence, not an S01-B recurring-schedule result. The current Apple API distinctions are recorded in `docs/APPLE_PLATFORM_NOTES.md`.
