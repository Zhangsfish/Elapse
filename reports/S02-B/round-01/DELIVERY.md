# S02-B delivery

State: **IN_PROGRESS — revised internal upload**. No stage approval.
Base main: `c1480eb0021c1fc2261a54ace4576feb7c537d8d`.
Branch / draft PR: `codex/s02-b-onboarding-polish` / [#21](https://github.com/Zhangsfish/Elapse/pull/21).

## Active first-visit revision

- Runtime code: `c9501d1efc79066da3eb4120d9c56bc05f6ce566`.
- Ordinary/prepare-tested: `b0f859394e21e76d87108a324568fb4c9c242e20`.
- Upload candidate: `eb882a25ab29f7a10565204378a575d1fac9fcbc`.
- Only explicit markers differ between these SHAs; no runtime edits after candidate.
- Candidate: **Everwhile 0.1.0 (62.1)**; final signed/internal result pending.
- Final documentation/marker-cleanup head is recorded in PR metadata after commit.

Owner accepted 59.1 home but rejected the inline teaching placement. Direct owner direction supersedes the prompt's inline/help preference, without adding mandatory multi-page onboarding. Inspected current [Lecture Asset tutorial](https://github.com/Zhangsfish/lecture-asset/blob/a04fe9b073dbe06d264ac7fa62c707e4f594a617/App/TutorialView.swift): borrow optional first visit, immediate Skip, replay and pinned footer, not its five-page photo workflow.

Everwhile now has one short, scrollable native teaching sheet, shown on first visit and replayable from the home question mark. Skip, Continue or swipe closes it. Existing saved selection/interval suppresses automatic upgrade presentation; neither is decoded/changed/cleared by the tutorial. Seen state is one App-owned standard UserDefaults flag covered by existing CA92.1. Teaching does not request permission, open the picker, Start/Stop monitoring, or read private report data. Illustration uses generic symbols only; Reduce Motion/VoiceOver is static.

Files: ContentView presentation/replay; new QuickStartTutorialView and TutorialVisitStore; existing generic teaching policy; en/zh-Hans tutorial strings; pure/XCTest UI/resource checks; reports/STATUS. No S01 model/lifecycle/registration or Today aggregation changes in this revision. Apple APIs remain native sheet/dismiss/safeAreaInset; current SDK build passed.

## Active checks and limits

Windows: 12 Python tests, Bash syntax and whitespace PASS; no local Xcode/Swift and no new dependency installation.
[Prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37321300215): 54 Swift tests / 0 failures, 12 Python tests, effective capabilities, unsigned iPhone build/archive, metadata and en/zh-Hans App/Monitor/Report resources PASS. 61.1 not uploaded; no Apple secrets.
[Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37321308582): simulator build, 54 Swift / 12 Python tests, localization/capabilities PASS. UI **BLOCKED_ENV / NOT_RUN**, simulator stuck in locationd migration before testing. Initial candidate UI also hit the bounded boot timeout; a superseded attempt was cancelled. No failed assertion disguised as an environment issue.
[Exact-upload ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37322850738): pending; UI check reruns independently.
[Explicit internal upload](https://github.com/Zhangsfish/Elapse/actions/runs/37322839283): pending. Final signatures/profile allowances, accepted upload, VALID processing and existing internal-group availability must be separately recorded.

Exact revision provenance/limits: `evidence/first-visit-validation.md`; owner direction/reference: `evidence/owner-onboarding-revision.md`. No raw signing logs, profiles, tokens or private screenshots published.

## Retained S02-B work / historical 59.1

Before this revision, S02-B added bilingual actual-threshold Monitor notifications, the Everwhile tagline, supported-locale fallback, first-Start notification-permission entry and accessibility-sized layout polish. These remain unchanged. PRODUCT_SPEC copy was aligned with the factual reminder-point contract. The existing Home state resolver still distinguishes desired intent, registration and active current interval. Report usage stays inside the extension; groups, Bundle IDs/capabilities and accepted product boundaries are unchanged.

Historical 59.1 runtime `e1d6a5c81041d93e0f121c0ed757eb8fff391c89`, prepare `9a58c1d43c45edbe1f31172ce6ff97ddfb6e7fef`, upload `764825461b913f777fae9aea84019b049f4502e5`. Old 53 Swift / 12 Python + two native simulator tests PASS; exact signed IPA/profile claims PASS; processing VALID/internal group confirmed. Old evidence remains `evidence/ordinary-ci.md`, `evidence/prepare-only.md`, `evidence/internal-release.txt`. Those screenshots/tests cover the **old inline teaching**, not the revised first-visit sheet.

## Owner / audit boundary

59.1 installed and home OWNER_REPORTED_PASS; teaching CHANGES_REQUESTED. **Revised build owner observation NOT_RUN.** After internal delivery ask only a short question-mark replay/exit check. No reinstall, clearing selection, reboot, permission revocation, midnight, long usage or S01/pulse retest.

Human VoiceOver, physical Reduce Motion and physical notification-language display remain NOT_RUN. Source/pure/resource tests and actual bundle packaging verify notification copy without making the owner wait for a pulse. System-language choice remains bundle-managed; only English + zh-Hans shipped. S03 LOCKED; PR neither approved nor merged.
