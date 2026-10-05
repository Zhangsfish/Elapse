# Owner-requested tutorial revision

59.1 installation: OWNER_REPORTED, confirmed as current version in this chat.
59.1 home: OWNER_REPORTED_PASS (owner: “第一部分没问题”).
59.1 teaching placement: CHANGES_REQUESTED, not a functional or whole-stage PASS.
Owner wants teaching at the beginning with replay, not an expandable block within Choose Apps.

This direct product direction supersedes the active prompt's preferred inline/help
presentation. It does not authorize a forced multi-page flow, new stage, monitoring
changes, public release, or self-approval.

## Reference inspected

Repository: https://github.com/Zhangsfish/lecture-asset
Current fetched main: `a04fe9b073dbe06d264ac7fa62c707e4f594a617`.
Read current `App/TutorialView.swift`, its ContentView presentation/replay integration,
`Tests/S05TutorialTests.swift`, `UITests/S05TutorialUITests.swift` and historical onboarding notes.
Current source has five teaching scenes; older ONBOARDING.md mentions four. Source is
the reference, not the older scene count. No source edits made to Lecture Asset;
its unrelated untracked owner folder was preserved.

Borrowed behavior, not its photo-processing content: optional first-visit presentation,
immediate Skip, replay from a secondary entry, pinned footer at large text, static
Reduce Motion fallback, teaching does not mutate live product state.

## Bounded Everwhile implementation

- One short, scrollable native sheet on first visit; Skip and Continue close it.
- Both exits stay in a pinned footer, horizontal normally / vertical at accessibility sizes; this fixes the new navigation-bar Skip Dynamic Type audit failure without suppressing the check.
- Generic selection illustration reused; no private identities, permission requests,
  picker actions or monitoring actions in the tutorial.
- Home right-hand question-mark button replays the same sheet from the beginning.
- Existing saved selection/interval suppresses automatic upgrade presentation;
  neither is decoded, changed or cleared by the tutorial store.
- App-container UserDefaults holds only an app-owned seen-v1 flag. Existing CA92.1
  privacy declaration already covers App-owned defaults; no new reason category,
  group data, entitlement or privacy boundary introduced.
- English / zh-Hans localized; short selection animation remains static with
  Reduce Motion or VoiceOver. No Today or S01 runtime edits.

59.1 is the historical build, not this revision's tested/installed version.
Revised CI, archive, signed/internal upload and short owner replay evidence must be
recorded separately. Do not require reinstall, permission revocation or pulse waiting.
