# S02-A device observations

Status: 50.1 reviewed; UI revision in progress. Everwhile 0.1.0 (50.1) is VALID and assigned to the internal group.

Owner observations, 2026-10-05 (three private screenshots and natural-language feedback in the Codex chat):

- Home ON and OFF states, reminder interval, and five selected-app count rendered correctly; owner judged the main screen broadly as expected.
- Today rendered a nonzero total, observed-hour bars, and per-app rows with durations after changing the selection to five apps. Owner reported that values looked correct. The screenshot is one point-in-time observation, not a complete reconciliation against iOS Screen Time.
- Usability issues: Start and Stop had identical prominent blue treatment apart from the words; the Today report still felt visually unfinished. The English copy was understandable but some phrases sounded mechanical. The current-hour bar sat too close to the trailing edge and the long full-width per-app progress tracks added visual noise.
- No private screenshots, app identities, or personal usage figures are copied into this public report. Apple-provided app labels may follow each installed app's own language and are not Everwhile localization errors.

Repair scope: distinct semantic Stop treatment with visible icon/text; tighter bilingual copy; grouped Today sections, quieter chart and app rows, and a full current-hour chart domain. These revisions require fresh CI and a new internal build before final owner acceptance.

Remaining short round on revised build: inspect ON/OFF button distinction and Today layout, especially the trailing chart bar and five-app list. No pulse wait, reboot, permission revocation, or midnight test.

Provenance: owner descriptions and any screenshot shared in this Codex chat. Private screenshot files will not be added to Git without explicit consent.
