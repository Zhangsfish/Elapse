# PR #21 — cloud-requested polish revision

Authority: [cloud audit](https://github.com/Zhangsfish/Elapse/pull/21#issuecomment-6009677604), reviewed head `07fee7599cde672dd91c0094c20350d0e8bca234`, CHANGES_REQUESTED; direct owner authorization 2026-10-06. Current main remains `c1480eb0021c1fc2261a54ace4576feb7c537d8d`. Same branch/PR; S03 LOCKED.

Re-read Lecture Asset `4995c1d0d70ebdf3712416bf96ee31219fc67720`: complete TutorialView/TutorialArtwork. Reused fixed 340×390 design canvas, bounded three-second playback, smoothstep progress and damped positional snap. Content remains Everwhile-specific: generic multi-selection, interval/Start, shared reminder, illustrative Today.

Changes: 60 Hz requested schedule (not a measured device-frame-rate guarantee); continuous check stroke/hand trajectory/press-release/ON crossfade, notification slide-settle, individual growing hourly bars and staggered rows. Blue/glow/shadow drawing vocabulary; no enclosing system card around the artwork. Reduce Motion/VoiceOver/background uses settled frame. Graphics text has one localized artwork accessibility summary; surrounding copy/navigation is real Dynamic Type text. Skip top trailing (44pt minimum), dots visual/count accessibility-only, Back/Next/Get started bottom. One home menu exposes replay and diagnostics. Dead view and selectionGuide/permission/start/demo-caption keys removed; all remaining localization keys checked for missing/unused references.

Preserved: S01 code/reconcile, real Today aggregation/report extension, App Group, pulse delivery semantics, Bundle IDs/capabilities/project config. Teaching does not call permissions/selection/monitoring/report APIs or persist sample data.

Apple API references checked 2026-10-06: [animation schedule](https://developer.apple.com/documentation/swiftui/timelineschedule/animation(minimuminterval:paused:)), [Canvas accessibility boundary](https://developer.apple.com/documentation/swiftui/canvas), [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion). Current SDK compilation/native UI tests pending.

Local Windows: `C:/conda_envs/myenv/python.exe -m unittest discover -s scripts/tests -v` — 14 PASS; `git diff --check` PASS. No install. Xcode/Swift unavailable locally; macOS CI, prepare, signed upload and new owner visual acceptance initially NOT_RUN. No private owner images/raw signing data committed.
