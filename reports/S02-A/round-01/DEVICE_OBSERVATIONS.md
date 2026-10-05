# S02-A device observations

Status: IN_PROGRESS for the duration-axis follow-up. The owner has reviewed 50.1 and 53.1; observations are separated by build below.

Owner observations, 2026-10-05 (three private screenshots and natural-language feedback in the Codex chat):

- Home ON and OFF states, reminder interval, and five selected-app count rendered correctly; owner judged the main screen broadly as expected.
- Today rendered a nonzero total, observed-hour bars, and per-app rows with durations after changing the selection to five apps. Owner reported that values looked correct. The screenshot is one point-in-time observation, not a complete reconciliation against iOS Screen Time.
- Usability issues: Start and Stop had identical prominent blue treatment apart from the words; the Today report still felt visually unfinished. The English copy was understandable but some phrases sounded mechanical. The current-hour bar sat too close to the trailing edge and the long full-width per-app progress tracks added visual noise.
- No private screenshots, app identities, or personal usage figures are copied into this public report. Apple-provided app labels may follow each installed app's own language and are not Everwhile localization errors.

Repairs delivered in 53.1: distinct semantic Stop treatment with visible icon/text; tighter bilingual copy; grouped Today sections, quieter chart and app rows, and a full current-hour chart domain. Fresh CI, archive, final signed IPA audit, upload and VALID processing passed. The subsequent Today appearance review is recorded below; a separate explicit ON/OFF-button appearance observation was not supplied.

53.1 follow-up (2026-10-05, private screenshot and natural-language feedback in this Codex chat): the owner said the report now looks good. The screenshot confirms the grouped total/hourly/app sections render and the trailing bar fits. The remaining request is an absolute duration y-axis with two or three sparse labels that adapt to the highest hourly bar (for example, a 25-minute peak uses 15/30-minute reference labels; 44 uses 25/50). The current hidden y-axis only conveys relative bar heights. No private screenshot or usage values are published here. A duration-axis revision is being implemented; its device appearance remains NOT_RUN.

Remaining short round on the next build: inspect only Today duration-axis labels and clipping. No pulse wait, reboot, permission revocation, or midnight test.

Provenance: owner descriptions and any screenshot shared in this Codex chat. Private screenshot files will not be added to Git without explicit consent.
