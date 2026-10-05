# Owner-approved four-scene tutorial

2026-10-06: owner explicitly approved the proposed four-scene animation and asked
Codex to implement using Lecture Asset's experience/stack, delivering the result.
This supersedes the earlier inline preference and 65.1 text-heavy single-page sheet;
it does not add mandatory setup steps or authorize a new stage.

Reference fetched main: lecture-asset `4995c1d0d70ebdf3712416bf96ee31219fc67720`.
Read `App/TutorialView.swift`, `App/TutorialArtwork.swift` and localized titles.
Borrow bounded time-addressable native SwiftUI artwork / once-per-scene playback,
static Reduce Motion fallback / next-back-skip / first-visit and replay behavior.
No dependency installation, remote media, real identities or five-page photo flow.

1. Choose Apps: two generic rows tick, then selection confirms.
2. Interval: select five minutes, demonstrate Start changing to ON.
3. Reminder: two selected Apps contribute to one shared illustrated progress;
   example five-minute notification enters after progress reaches the endpoint.
4. Today: demonstration total, hourly aggregate bars, two per-App rows reveal.

Each scene uses one title, one short caption, plus an explicit illustration label.
VoiceOver receives localized scene meaning, not decorative elements. Its playback
and Reduce Motion mode use the settled frame; footer stacks at accessibility sizes.
Thirty-fps TimelineView stops scheduling after three seconds, while backgrounded
views show a settled frame. Scene changes/disappearance cancel the sleep. No looping,
wall-clock countdown, precise delivery claim or exact-session timeline.

Demo cards do not accept taps. Real permissions/picker/Start remain on the homepage;
tutorial paging and Get started only navigate/dismiss. Samples are local constants
inside App/TutorialArtwork.swift, never read from or written to report/group state.
S01 lifecycle, registration, Report aggregation, entitlements/groups are unchanged.

Current Apple API references (checked 2026-10-06):
- https://developer.apple.com/documentation/swiftui/timelineview
- https://developer.apple.com/documentation/swiftui/timelineschedule/animation(minimuminterval:paused:)
- https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion

Current 69.1 runtime/tested/upload SHA and actual checks: DELIVERY.md,
four-scene-validation.md and four-scene-release.txt. Internal availability confirmed.
65.1 installed OWNER_REPORTED; owner requested visual simplification, not final PASS.
New runtime owner visual acceptance NOT_RUN. No pulse/reboot/midnight/Today retest.
