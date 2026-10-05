# S02-A device observations

Status: READY_FOR_AUDIT on Everwhile 0.1.0 (56.1), which is VALID and assigned to the internal group. The owner has reviewed 50.1, 53.1 and the 56.1 duration-axis revision; observations are separated by build below. This records owner feedback, not independent audit approval.

Owner observations, 2026-10-05 (three private screenshots and natural-language feedback in the Codex chat):

- Home ON and OFF states, reminder interval, and five selected-app count rendered correctly; owner judged the main screen broadly as expected.
- Today rendered a nonzero total, observed-hour bars, and per-app rows with durations after changing the selection to five apps. Owner reported that values looked correct. The screenshot is one point-in-time observation, not a complete reconciliation against iOS Screen Time.
- Usability issues: Start and Stop had identical prominent blue treatment apart from the words; the Today report still felt visually unfinished. The English copy was understandable but some phrases sounded mechanical. The current-hour bar sat too close to the trailing edge and the long full-width per-app progress tracks added visual noise.
- No private screenshots, app identities, or personal usage figures are copied into this public report. Apple-provided app labels may follow each installed app's own language and are not Everwhile localization errors.

Repairs delivered in 53.1: distinct semantic Stop treatment with visible icon/text; tighter bilingual copy; grouped Today sections, quieter chart and app rows, and a full current-hour chart domain. Fresh CI, archive, final signed IPA audit, upload and VALID processing passed. The subsequent Today appearance review is recorded below; a separate explicit ON/OFF-button appearance observation was not supplied.

53.1 follow-up (2026-10-05, private screenshot and natural-language feedback in this Codex chat): the owner said the report now looks good. The screenshot confirms the grouped total/hourly/app sections render and the trailing bar fits. The remaining request was an absolute duration y-axis with two or three sparse labels that adapt to the highest hourly bar (for example, a 25-minute peak uses 15/30-minute reference labels; 44 uses 25/50). The hidden y-axis only conveyed relative bar heights. No private screenshot or usage values are published here.

56.1 delivery: the duration axis is implemented; it has a zero baseline and sparse localized duration labels at whole-minute positions. CI (47 Swift tests), prepare, final signed IPA audit, upload and VALID processing passed; existing internal group assignment confirmed.

56.1 follow-up (2026-10-05, natural-language feedback in this Codex chat): after being asked to inspect the new Today duration-axis labels and clipping, the owner replied “没问题，很好”. Record the revision as OWNER_REPORTED_PASS: no rendering issue was reported. No new screenshot was supplied, so this does not assert independently measured tick values or a complete quantitative reconciliation.

No further phone action is requested for this round. Runtime dark mode, Dynamic Type, VoiceOver, Chinese-language UI inspection and a separate explicit revised ON/OFF-button appearance check remain NOT_RUN; source support, localization tests and packaged resources are distinct evidence. No pulse wait, reboot, permission revocation, or midnight test was added.

Provenance: owner descriptions and any screenshot shared in this Codex chat. Private screenshot files will not be added to Git without explicit consent.
