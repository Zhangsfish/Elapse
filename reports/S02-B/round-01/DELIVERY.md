# S02-B delivery

State: **WAITING_FOR_OWNER_TEST — corrected second scene only**. Same PR #21; no merge/approval; S03 LOCKED.
Base main: `c1480eb0021c1fc2261a54ace4576feb7c537d8d`.
Branch / draft PR: `codex/s02-b-onboarding-polish` / [#21](https://github.com/Zhangsfish/Elapse/pull/21).

## Current second-scene correction — 2026-10-06

Owner observed that the filling clock ring in 78.1 resembles elapsed usage, then approved a static clock + selected interval preview. Removed the ring/rotation; the localized 5-minute value fades in with selection, while chip press/release and Start→ON remain continuous. No new copy/API/dependency; all other scenes and actual monitoring/Today unchanged. Added a regression guard for no elapsed-time visual in this scene. 15 local Python tests PASS; new macOS checks and internal delivery PASS. 78.1 evidence below is prior-candidate evidence, not acceptance of the new code.

Runtime `a21a85728bb5780213e9c03319f721215108e91a`; ordinary/prepare-tested `5fefc21abac31c2bf87c15093ddf914c17dba07d` (marker only). [Prepare 37423164305](https://github.com/Zhangsfish/Elapse/actions/runs/37423164305), job 112136836173: **PASS**, 60 Swift / 15 Python; unsigned Release build/archive, effective entitlements/metadata, App/Monitor/Report en+zh-Hans resources; **80.1 NOT_UPLOADED**, no Apple secrets.

[Ordinary 37423169387](https://github.com/Zhangsfish/Elapse/actions/runs/37423169387), job 112137196237: **PASS**, 60 Swift / 15 Python, simulator build, both actual native English/Chinese-large-text UI tests and four-scene layout audits (no exemption). Artifact 11394775844: eleven clean-simulator PNGs inspected, including corrected second scenes in English light/Chinese dark; static clock + chosen value, no elapsed ring. Largest-text content is scrollable below pinned navigation, not all visible in one viewport. One Chinese second-scene capture has a transient blank Next label; actual navigation tests/audits pass, not a promise that each capture shows every settled control. Still images do not prove measured frame rate or physical animation acceptance.

Upload marker-only SHA `3c15db6cb114bbb6862d0a4c7191899dd0b6d367`; [internal upload 37424768327](https://github.com/Zhangsfish/Elapse/actions/runs/37424768327), job 112141818458: **PASS — Everwhile 0.1.0 (81.1)**. Final App/Monitor/Report signatures, expected Bundle IDs, Family Controls claims/profile allowance and required App Groups PASS. Exactly the audited IPA bytes uploaded ACCEPTED; processing VALID / INTERNAL_ONLY / IN_BETA_TESTING / existing internal group assigned TRUE at 2026-10-06T06:45:06Z. Safe evidence: `evidence/interval-preview-release.txt`. Executed markers removed in this evidence closeout; ordinary pushes/merge do not upload again. No Apple credential/workflow changes or owner Actions click.

Only `App/TutorialArtwork.swift` and `scripts/tests/test_s02_localization.py` changed implementation/test behavior in this correction; remaining edits are status/reports/temporary markers. Protected source/config diff against prior delivery `bdca465...` is empty for Home/model/tutorial chrome, Shared, Monitor, Report, localization, project.yml and existing Swift/UI tests. No runtime edits after tested SHA. Documentation-only cleanup head CI remains pending at handoff; passing runtime CI above is not a claim about that new head.

Owner next action: update to 81.1, home `…` → Replay quick start / 重播新手教学 → Next / 下一步, look only at the corrected interval scene. Physical acceptance **NOT_RUN**; no functional retest. On actual acceptance update this same PR to READY_FOR_AUDIT; do not self-approve/merge/unlock S03.

## Previous cloud-requested revision — 78.1

[Cloud comment](https://github.com/Zhangsfish/Elapse/pull/21#issuecomment-6009677604) reviewed `07fee759...`: CHANGES_REQUESTED, product polish only. Runtime `14bd931ac3e2da342f15760a4ace33fa0a28e6e3`; ordinary/prepare-tested `97120c9f64f73f71f49589ea63b5c8e9b14e49a6`; upload marker `8351242adbecde205f87f1e70423e054f478a02a`. Only markers differ across tested/upload SHAs. Continuous 60 Hz requested playback/fixed drawing canvas, four scene motion/composition, simplified chrome, single home menu, dead view/copy removed. Scope/provenance: `evidence/cloud-polish-revision.md`. Native audit exposed capped text scaling of UIKit toolbar Skip; same top-trailing position now uses a height-adaptive header, with audits retained.

[Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37419869042), job112126634480: **PASS**. 60 Swift / 14 Python; simulator build; App/Monitor/Report en+zh-Hans resources; English first visit/replay and Chinese largest-text replay, four-scene Dynamic Type/text-clipping audits without exemptions. Artifact11393056917: eleven clean-simulator PNG attachments inspected (first scene captured twice); English light and all four Chinese dark scenes. At largest text, artwork/caption below the pinned footer is scrollable, not a promise that everything fits one viewport. Still screenshots are not measured frame-rate or physical motion acceptance.

[Prepare](https://github.com/Zhangsfish/Elapse/actions/runs/37419863932), job112126588786: **PASS**. Xcode26.6 / Swift6.3.3 / XcodeGen2.46 / macos-26; 60 Swift / 14 Python; unsigned iPhone Release build/archive, effective capabilities, final archive metadata and App/Monitor/Report localization. **77.1 NOT_UPLOADED**; no Apple secrets used.

[New internal upload](https://github.com/Zhangsfish/Elapse/actions/runs/37421509866), job112131672984: **PASS — Everwhile 0.1.0 (78.1)**. Final App/Monitor/Report signatures, expected Bundle IDs, Family Controls claims/profile allowance and required App Groups PASS. Exactly the audited IPA bytes uploaded ACCEPTED; processing VALID / INTERNAL_ONLY / IN_BETA_TESTING / existing internal group assigned TRUE at 2026-10-06T06:07:40Z. Safe evidence: `evidence/cloud-polish-release.txt`. No workflow/credential changes or owner Actions click. Executed one-time markers removed in evidence closeout, so docs/merge cannot replay this upload.

The 78.1 handoff requested four tutorial animations and the single home menu. It is superseded by the owner's second-scene correction above, not whole-candidate acceptance. No S01/Today/pulse/reboot/revocation/midnight retest. 69.1 observation below is historical and does not transfer to a later candidate. Upon actual acceptance, update this same PR to READY_FOR_AUDIT, without self-approval/merge/S03 unlock.

## Historical owner-approved 69.1 revision

Owner installed 65.1 but asked for less text and Lecture Asset-style actions. Owner explicitly approved four scenes on 2026-10-06. This replaces the text-heavy sheet, not the accepted home/Today or S01 behavior.
- Choose multiple generic Apps; confirm.
- Choose reminder interval; demonstrate Start.
- Shared selected-App time adds up; example banner.
- Example Today total, hourly aggregate bars and per-App rows.

One short title/caption per scene; optional Next/Back/Skip/Get started; first visit and home-question-mark replay retained. Demo cards cannot operate real settings. No permission, picker, monitor or notification requests from teaching; sample durations stay local to the App artwork.
Three-second time-addressable SwiftUI artwork plays once, then pauses; static settled frame with Reduce Motion/VoiceOver/background. Pinned footer stacks at accessibility text sizes. S01 lifecycle/reconcile, Today aggregation, report privacy boundary, App Groups, Bundle IDs and capabilities unchanged.

Reference: Lecture Asset current main `4995c1d0d70ebdf3712416bf96ee31219fc67720`, TutorialView/TutorialArtwork. Owner direction and current Apple API links: `evidence/four-scene-direction.md`. No installs or remote media.

## Historical 69.1 provenance

- Runtime code: `f05df01fa52a144664d3ca87ffd8340fddd5cf6f`.
- Ordinary/prepare-tested: `e1fba3d5ead1790b5ffef2e9118fc82d78ad58df` (marker only).
- Explicit upload SHA: `9de0a209c653769a2881e68e1586a6f34bacdff7` (upload marker only); **Everwhile 0.1.0 (69.1)**.
- Final evidence/marker-cleanup head recorded in PR metadata; no source edits after tested build without affected retesting.

## Historical 69.1 checks

Windows: 13 Python tests, Bash syntax, whitespace PASS; no local Xcode/Swift.
[Prepare](https://github.com/Zhangsfish/Elapse/actions/runs/37353626575): 58 Swift / 0 failures, 13 Python, XcodeGen/effective entitlements, unsigned iPhone Release build/archive, actual metadata/extensions and en+zh-Hans App/Monitor/Report resources PASS. 68.1 not uploaded; Apple secrets/signing skipped.
[Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37353631696), attempt 2: PASS. 58 Swift / 13 Python, simulator build/resources/capabilities and English first-visit/replay + Chinese largest-text replay PASS. All four scenes retain Dynamic Type/text-clipping audits; ten unique clean-simulator captures inspected. Requested dark mode settled in the final Chinese scene, not all captures; exhaustive four-scene dark visual coverage remains unverified. Attempt 1 was a pre-test simulator boot timeout (NOT_RUN), not UI PASS.
[Explicit upload](https://github.com/Zhangsfish/Elapse/actions/runs/37357058165): PASS. Final signed IPA App/Monitor/Report signatures, expected IDs, Family Controls claims/profile allowance and required App Groups PASS. Exactly those audited bytes uploaded ACCEPTED; 69.1 processing VALID / INTERNAL_ONLY / IN_BETA_TESTING / existing internal-group assignment TRUE at 18:43:49Z. Safe evidence: `evidence/four-scene-release.txt`. No new account setup or owner Actions click.
[Extra exact-upload ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37357063413), job111922047054: PASS. 58 Swift / 13 Python, simulator build/resources/capabilities, English and Chinese-largest-text native UI/audits PASS at the exact upload SHA. Only markers differ from tested runtime.
Current raw safe extracts/limits: `evidence/four-scene-validation.md`.
[Previous evidence-head CI](https://github.com/Zhangsfish/Elapse/actions/runs/37358794703), `0251cc2cb637764d9e95814a4510d22eda7148db`, job111927874783: 58 Swift / 13 Python, simulator build/resources/capabilities and both native UI/layout-audit checks PASS. This closeout edits documentation only, not the tested/uploaded runtime.
Executed prepare/upload marker files removed; history retains the exact trigger commits.
Ordinary code/docs pushes and PR merge do not repeat this upload. No workflow change
was needed for the four-scene revision.

## Historical evidence

59.1 home OWNER_REPORTED_PASS; inline teaching CHANGES_REQUESTED. 65.1 installed OWNER_REPORTED; text-heavy teaching also requires revision. Their tests, delivery and screenshots are historical, not four-scene acceptance.
65.1 runtime2117717..., preparefdeddf4..., uploadb6ff74e... had 54 Swift / 12 Python and two native UI/audit checks PASS at prepare SHA; extra upload-SHA UI attempt BLOCKED_ENV/NOT_RUN. Final signatures PASS, ACCEPTED/VALID/IN_BETA_TESTING/internal group TRUE after read-only run37328896729.
Safe historic evidence remains first-visit-validation.md / first-visit-release.txt, owner-onboarding-revision.md and original ordinary-ci.md / prepare-only.md / internal-release.txt. Superseded62.1 real Dynamic Type failure and bounded processing PENDING remain explicitly recorded.

## Historical 69.1 device / audit boundary

2026-10-06 owner replied to the 69.1 handoff: “没啥问题，就是效果稍微还可以优化，先停在这里吧。” Record general tutorial visual acceptance as **OWNER_REPORTED_ACCEPTABLE_WITH_POLISH_NOTE**. Build association is conversation context; no new screenshot/restated build number or per-button log. Do not manufacture separate physical Next/Back/Skip, language, VoiceOver or Reduce Motion PASS. See DEVICE_OBSERVATIONS.md. Animation details are deferred optional polish, not further work authorized in this round. No new code, upload or S01/Today retest.
Human VoiceOver, physical Reduce Motion and physical notification-language display remain NOT_RUN. Source/pure/resource/native tests are labelled separately. No private screenshots or raw signing materials published.
The historical 69.1 closeout reached READY_FOR_AUDIT, then the cloud requested this revision. Current state is the top-level state above, not that old verdict. No self-approval/merge/S03 unlock or App Review submission. Public distribution preparation remains the locked next stage.
