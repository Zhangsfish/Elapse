# S01-B device observations — owner round 01

Target iPhone: owner states Everwhile `0.1.0 (47.1)` installed, then reports “都没问题，实际结果见截图” in response to the complete short lifecycle checklist. Six screenshots were inspected in this chat; **the image files are not committed or publicly uploaded**. Evidence below is a safe transcription, not a claim that a screenshot proves a phone reboot or a later Stop.

| Check | Evidence | Classification |
|---|---|---|
| Initial Start / recurring registration | At phone-local 02:26, short config `2f1a4c52`, desired ON, registration interval 5m, planned/system-registered 299/299, recurring YES, registration error none. | SCREENSHOT_OBSERVED |
| Actual interval start | Current interval `active`, generation 1, anchor and last start `2026-10-05 02:25:58` phone-local; last end not received. | SCREENSHOT_OBSERVED — current interval start evidence, not usage-threshold proof |
| Reopen persistence | At 02:27 and 02:28, screenshots still show `2f1a4c52`, ON, 299/299, recurring YES; generation remains 1 in the displayed section. | SCREENSHOT_OBSERVED for state persistence; exact close/reopen action OWNER_REPORT |
| One iPhone reboot | Owner explicitly replied “对 没问题” when asked whether the whole iPhone was restarted (not only the App). Screenshots around 02:28–02:29 show same ID `2f1a4c52`, ON and 299/299; latest recovery reason none. The screenshot alone does not prove a power cycle. | PASS_OWNER_REPORT_WITH_SCREENSHOT_STATE — same-registration path |
| Stop + reopen, no auto-resurrection, 2 selected Apps retained | Owner explicitly replied “对 没问题” when asked whether Stop then reopening showed desired OFF and two selected Apps. No final OFF screenshot was supplied; the result is an owner observation, not image-derived. The prior checklist also requested interval to remain 5m. | PASS_OWNER_REPORT |

Additional safe diagnostic observations: recovery count 1 and latest recovery reason “无”; the count is cumulative across configurations, so this does **not** establish a recovery during the 47.1 test. Unanchored callback rejection count 2, premature count 0, accepted callback/request count 0 in the screenshot; the rejection counter is also cumulative, and no visible pulse was tested or claimed. No waiting for a five-minute pulse, midnight, permission revocation or Today retest was requested. This is short lifecycle evidence, not all-day callback reliability or natural-midnight rollover proof.
