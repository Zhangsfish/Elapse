# S01-B round 01 — READY_FOR_AUDIT

Base main: `07b889afe456aa408104b3643b2c8281d3cf99a1`.
Branch: `codex/s01-b-daily-lifecycle`.
PR: https://github.com/Zhangsfish/Elapse/pull/19 (open; Codex does not merge).

- Implementation code SHA: `2479f48efa62d26ca0d2972aaa56af7b96540766`.
- Prepare-only marker SHA: `73483187917768535cfd25bd702ae9deaaf77828`.
- Tested/upload SHA: `34f95996c1c89667a40612edf41620ef5604d57e` (marker-only successors, identical runtime code).
- Internal build: Everwhile `0.1.0 (47.1)`.
- The two one-time marker files were removed after upload; subsequent document commits cannot re-trigger an upload.

## Implementation intent

- Product schedule is daily recurring (`00:00`–`23:59:59`, `repeats=true`) with the accepted 299-event default ladder and `includesPastActivity=false`.
- App-owned desired intent, exact system registration, and actual interval lifecycle evidence are distinct. A 299/299 registration with no current `intervalDidStart` remains **unverified for current-day counting**.
- Monitor extension records idempotent per-local-cycle generation/anchor/start/end; new cycles clear only interval receipts. Callback guard rejects unanchored and physically impossible premature thresholds without notification requests. Old config and old interval-generation completion paths fail closed.
- App launch/foreground/refresh and authorization status changes reconcile desired intent with system registration. Missing/mismatched registration creates one new UUID-backed config with a safe recovery reason; failure is held without a refresh loop. Stop persists desired=OFF before removing system activities.
- No Shield/ManagedSettings, Today report changes, account/cloud/AI, or public distribution.

## Evidence status

| Layer | Status |
|---|---|
| Source and unit tests | PASS — 10 local Python tests, macOS Swift tests and simulator build on code + marker SHAs |
| Secret-free ordinary CI | PASS — [code run 37220713643](https://github.com/Zhangsfish/Elapse/actions/runs/37220713643), [prepare marker run 37220901488](https://github.com/Zhangsfish/Elapse/actions/runs/37220901488), [upload SHA run 37221128832](https://github.com/Zhangsfish/Elapse/actions/runs/37221128832) |
| Prepare-only archive | PASS — [run 37220897989](https://github.com/Zhangsfish/Elapse/actions/runs/37220897989); upload step skipped |
| Signed IPA / internal TestFlight | PASS — [run 37221126361](https://github.com/Zhangsfish/Elapse/actions/runs/37221126361); signed app+extensions claims/profile allowance valid, upload accepted, processing VALID, internal-only group assigned |
| Target iPhone 299/299 + lifecycle anchor | PASS — owner-supplied screenshots, config `2f1a4c52`, recurring YES, active generation 1 / 02:25:58 local anchor, no registration error |
| App reopen | PASS_OWNER_REPORT_WITH_SCREENSHOT_STATE — same config and generation visible at 02:27–02:28 |
| One iPhone reboot | PASS_OWNER_REPORT_WITH_SCREENSHOT_STATE — owner explicitly confirms whole-device restart; later screenshots still show same config `2f1a4c52` and 299/299, with no new recovery reason |
| Stop / reopen no resurrection | PASS_OWNER_REPORT — owner explicitly confirms desired OFF and two selected Apps after Stop and reopen; final OFF is not screenshot-proven |
| True midnight rollover and revoke/regrant on device | NOT_RUN_OUT_OF_SCOPE — S01-C |

The preimplementation 44.1 midnight observation is historical evidence, not an S01-B recurring-schedule result. The current Apple API distinctions are recorded in `docs/APPLE_PLATFORM_NOTES.md`.

The target iPhone has established a 47.1 interval start/anchor, distinct from mere 299/299 registration. The owner explicitly confirmed the whole-device reboot and Stop/reopen OFF state; these actions are owner-report evidence, while the image captures only the ON/registered state. The displayed unanchored rejection count (2) and recovery count (1) are cumulative safety diagnostics, not proven events of the pictured configuration. No pulse, midnight rollover, permission revoke/regrant or Today retest is claimed. No owner action remains for S01-B; cloud audit and merge approval remain external to Codex.
