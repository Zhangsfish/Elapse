# S00-C round 01 — delivery

Status: IN_PROGRESS. Base main: `3fcaa287217399449b3dd2b10e6adba8280ebf2e`. Branch: `codex/s00-c-continuous-pulses`. Code/tested/upload SHA, PR, version/build and run URLs: NOT_RUN / pending implementation and CI.

Source baseline: six DeviceActivity threshold events (5/10/15/20/25/30) already use the same selected application-token set and the Monitor can request a notification for any valid event. The 32.1 shared snapshot recorded callback/request details only for 5 minutes. An accepted notification request does not establish visible delivery. No 10–30-minute owner experiment has been performed for this branch yet.

Implementation in progress: independent per-threshold callback/request timestamps, request status and safe error code; migration of the 32.1 five-minute snapshot; fail-closed one-request-per-threshold receipt even after a request error; out-of-order arrival recorded by actual callback time; status UI corrected after a callback. Existing authorization, selection freeze, App Group boundary and notification copy remain in scope only for non-regression.

Apple API references checked for this change: [DeviceActivity threshold callback](https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/threshold), [includesPastActivity](https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/includespastactivity), [local notification add completion](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/add%28_%3Awithcompletionhandler%3A%29). The completion reports request scheduling success/error, not proof the user saw a banner.
