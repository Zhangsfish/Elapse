# S00-D owner iPhone observations

Status: READY_FOR_AUDIT. Build: Everwhile `0.1.0 (41.1)` per OWNER_REPORT; TestFlight upload/assignment is separate CI/Apple evidence.

The owner opened Today and said: “数值显示什么的没问题……功能没问题”. The supplied OWNER_SCREENSHOT shows a nonblank report at approximately local 11:58 with:

- “当前用户 · 当前 iPhone · 今天截至现在” scope and a system report update time;
- two selected-App rows with Apple-provided icon/label and positive durations;
- a nonzero selected-App total, per-App values of the same order, and positive hourly buckets including the local 00:00 hour and 01:00 hour, directionally consistent with the earlier post-midnight S00-C use;
- explicit copy saying hourly aggregates are not an exact App-open/App-close timeline.

Displayed whole-minute values differ by about one minute when manually summed; the UI rounds/truncates individual displayed values. The underlying total/per-App/hourly arithmetic is SOURCE + UNIT_TEST evidence, not proven to second-level precision by the screenshot. A very short positive bucket also displays `0m` with a tiny visible bar; record this as a presentation-precision note, not as zero usage or a failed data load.

The screenshot includes personal App identities and usage. Although the owner authorized reading it and asked that the observation be uploaded, the raw screenshot is retained in this chat rather than committed to the public repository; this report anonymizes its content. No App identity, token, bundle ID or raw report export is included here.

Zero-usage and unavailable states were not induced on the device: NOT_RUN / SOURCE + UNIT_TEST only. Loading completion cannot be reliably observed through the host API: SYSTEM_MANAGED_LOADING. No additional long-duration experiment was requested.
