# S02-B delivery

State: **WAITING_FOR_OWNER_TEST**. No stage approval.
Base main: `c1480eb0021c1fc2261a54ace4576feb7c537d8d`.
Branch / draft PR: `codex/s02-b-onboarding-polish` / [#21](https://github.com/Zhangsfish/Elapse/pull/21).

## Active first-visit revision

- Runtime code: `2117717d2061128204bf89aec51cd9ef141c376f`.
- Ordinary/prepare-tested: `fdeddf4827ea62a323d38e892712779de4b10c28`.
- Signed/upload-tested: `b6ff74e1188e307290ac12be2594d1eb965a0a46`.
- Only explicit markers differ between these SHAs; no runtime edits after candidate.
- Delivered: **Everwhile 0.1.0 (65.1)**; signed IPA PASS, Apple processing VALID, existing internal group assignment TRUE / IN_BETA_TESTING.
- Final documentation/marker-cleanup head is recorded in PR metadata after commit.

Owner accepted 59.1 home but rejected the inline teaching placement. Direct owner direction supersedes the prompt's inline/help preference, without adding mandatory multi-page onboarding. Inspected current [Lecture Asset tutorial](https://github.com/Zhangsfish/lecture-asset/blob/a04fe9b073dbe06d264ac7fa62c707e4f594a617/App/TutorialView.swift): borrow optional first visit, immediate Skip, replay and pinned footer, not its five-page photo workflow.

Everwhile now has one short, scrollable native teaching sheet, shown on first visit and replayable from the home question mark. Skip, Continue or swipe closes it. Existing saved selection/interval suppresses automatic upgrade presentation; neither is decoded/changed/cleared by the tutorial. Seen state is one App-owned standard UserDefaults flag covered by existing CA92.1. Teaching does not request permission, open the picker, Start/Stop monitoring, or read private report data. Illustration uses generic symbols only; Reduce Motion/VoiceOver is static.

Files: ContentView presentation/replay; new QuickStartTutorialView and TutorialVisitStore; existing generic teaching policy; en/zh-Hans tutorial strings; pure/XCTest UI/resource checks; reports/STATUS. No S01 model/lifecycle/registration or Today aggregation changes in this revision. Apple APIs remain native sheet/dismiss/safeAreaInset; current SDK build passed.

## Active checks and limits

Windows: 12 Python tests, Bash syntax and whitespace PASS; no local Xcode/Swift and no new dependency installation.
[Prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37325275231): 54 Swift tests / 0 failures, 12 Python tests, effective capabilities, unsigned iPhone build/archive, metadata and en/zh-Hans App/Monitor/Report resources PASS. 64.1 not uploaded; no Apple secrets.
[Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37325288715): simulator build, 54 Swift / 12 Python tests, localization/capabilities and both native first-visit/replay tests PASS. English light/default and Chinese dark/largest accessibility text; automated Dynamic Type/text-clipping checks PASS. Four clean-simulator home/tutorial PNGs visually inspected. This is not human VoiceOver or physical Screen Time proof.
[Exact-upload ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37326743639): 54 Swift / 12 Python, simulator build/resources/capabilities PASS. Its additional UI attempt was **BLOCKED_ENV_BOOT_TIMEOUT / NOT_RUN**, not UI PASS; runtime is identical to the already passing prepare-tested candidate.
[Explicit internal upload](https://github.com/Zhangsfish/Elapse/actions/runs/37326734165): unsigned checks PASS; exact final signed IPA/App/Monitor/Report signatures and Family Controls/profile allowances PASS; upload ACCEPTED; processing VALID at 14:49Z. The immediate group query was FALSE (not yet available), not a signing problem.
[Read-only availability recheck](https://github.com/Zhangsfish/Elapse/actions/runs/37328896729) at unchanged main `c1480eb0021c1fc2261a54ace4576feb7c537d8d`: exact **65.1**, VALID, INTERNAL_ONLY, IN_BETA_TESTING, existing internal group TRUE / assignment TRUE at 14:57:38Z. No second upload, assignment mutation, new tester/group or owner account operation. Safe final summaries: `evidence/first-visit-release.txt`. One-time upload/prepare markers removed after execution; ordinary docs pushes do not upload.

Initial candidate attempts had real BLOCKED_ENV boot timeouts. A later run executed the new UI and failed Dynamic Type specifically at the navigation-bar Skip button. Cropped/full attachments confirmed the element. Both exits now use a pinned unconstrained footer that stacks at accessibility sizes; the unchanged audit passed after the fix. Superseded 62.1: final signing/profile claims and upload ACCEPTED, but processing PENDING at the bounded poll end; it is not the final UI candidate. Safe evidence: `evidence/superseded-release-62.txt` and `evidence/first-visit-validation.md`. No failing UI test is relabelled as an environment issue.

Exact revision provenance/limits: `evidence/first-visit-validation.md`; owner direction/reference: `evidence/owner-onboarding-revision.md`. No raw signing logs, profiles, tokens or private screenshots published.

## Retained S02-B work / historical 59.1

Before this revision, S02-B added bilingual actual-threshold Monitor notifications, the Everwhile tagline, supported-locale fallback, first-Start notification-permission entry and accessibility-sized layout polish. These remain unchanged. PRODUCT_SPEC copy was aligned with the factual reminder-point contract. The existing Home state resolver still distinguishes desired intent, registration and active current interval. Report usage stays inside the extension; groups, Bundle IDs/capabilities and accepted product boundaries are unchanged.

Historical 59.1 runtime `e1d6a5c81041d93e0f121c0ed757eb8fff391c89`, prepare `9a58c1d43c45edbe1f31172ce6ff97ddfb6e7fef`, upload `764825461b913f777fae9aea84019b049f4502e5`. Old 53 Swift / 12 Python + two native simulator tests PASS; exact signed IPA/profile claims PASS; processing VALID/internal group confirmed. Old evidence remains `evidence/ordinary-ci.md`, `evidence/prepare-only.md`, `evidence/internal-release.txt`. Those screenshots/tests cover the **old inline teaching**, not the revised first-visit sheet.

## Owner / audit boundary

59.1 installed and home OWNER_REPORTED_PASS; teaching CHANGES_REQUESTED. **Revised build owner observation NOT_RUN.** After internal delivery ask only a short question-mark replay/exit check. No reinstall, clearing selection, reboot, permission revocation, midnight, long usage or S01/pulse retest.

Human VoiceOver, physical Reduce Motion and physical notification-language display remain NOT_RUN. Source/pure/resource tests and actual bundle packaging verify notification copy without making the owner wait for a pulse. System-language choice remains bundle-managed; only English + zh-Hans shipped. S03 LOCKED; PR neither approved nor merged.
