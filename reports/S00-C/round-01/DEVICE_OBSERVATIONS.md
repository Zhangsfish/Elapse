# S00-C device observations — round 01

Status: WAITING_FOR_OWNER_TEST for two verbal confirmations. Owner reports Everwhile `0.1.0 (38.1)` on iPhone, experiment `4:0cb91a51`, exactly two selected Apps, zero selected categories/web domains, Screen Time authorized, notification authorization/alerts enabled, and shared diagnostic store ready. The pasted diagnostic was copied **before Stop** (`ExperimentPhase=registered`); the owner subsequently reported stopping successfully. Two attached screenshots were inspected in this conversation but were **not** copied into the public repository. No selected-App identity or other private notification content is recorded here.

| Threshold | Current-experiment callback (UTC; local +08:00) | Request | Visible pulse | Delay evidence |
|---|---|---|---|---|
| 5 min | `2026-10-03T16:10:58Z` (Oct 4 00:10:58) | accepted, same logged second; no error | PASS — owner report + notification-center screenshot | NOT_MEASURABLE from supplied usage timings |
| 10 min | `2026-10-03T16:16:00Z` (Oct 4 00:16:00) | accepted, same logged second; no error | PASS — owner report + screenshot | NOT_MEASURABLE |
| 15 min | `2026-10-03T16:21:00Z` (Oct 4 00:21:00) | accepted, same logged second; no error | PASS — owner report + screenshot | NOT_MEASURABLE |
| 20 min | `2026-10-03T16:29:52Z` (Oct 4 00:29:52) | accepted, same logged second; no error | PASS — owner report + screenshot | NOT_MEASURABLE |
| 25 min | `2026-10-03T16:42:11Z` (Oct 4 00:42:11) | accepted, same logged second; no error | PASS — owner report + screenshot | NOT_MEASURABLE |
| 30 min | `2026-10-03T16:47:21Z` (Oct 4 00:47:21) | accepted, same logged second; no error | PASS — owner report + screenshot | NOT_MEASURABLE |

Provenance: the owner pasted all six `received_current_experiment` callback fields and six `accepted` request fields; the notification-center screenshot visibly contains the six neutral Everwhile pulse messages. The in-App screenshot shows all six rows and the corrected registration copy “已登记，已收到真实回调”. The owner states “通知都收到了” and “已停止，没问题”. The pasted diagnostic precedes Stop, so it cannot itself prove a `stopped` phase or selection unlock.

The owner has not yet explicitly confirmed A → B → A (or another two switches between the two selected Apps) in this experiment, nor that “选择 App” became enabled after Stop. Request **only verbal clarification**; no further 30-minute run is requested. Selection freeze is SOURCE + UNIT_TEST and an accepted S00-B observation, but no explicit S00-C owner observation was provided. The six callback arrival intervals are not Screen Time usage durations or per-threshold delivery delays; pauses, unselected activity and OS delivery latency cannot be disentangled from the supplied timestamps. No exact punctuality claim is made.

`StaleCallbacksRejected=0`, `DuplicateCallbacksRejected=0`, `StaleCompletionsRejected=0`, `InvalidCallbacksRejected=0`, all threshold error codes `none`. No stale/duplicate/late completion naturally occurred on device. Their rejection semantics remain SOURCE + UNIT_TEST only; do not deliberately induce them or adjust the system clock.
