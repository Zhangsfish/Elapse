# S00 audit workspace

This folder preserves audit conclusions and historical feasibility/distribution evidence. Current dispatch is only `STATUS.md`.

- `READINESS_REVIEW_2026-10-03.md` is the current static readiness review. It preserves accepted/VALID upload history but reopens the owner-supplied ITMS-90897 warning and separates installation from runtime acceptance.
- `REAL_DEVICE_CHECKLIST.md` routes device work by current substage. Codex guides the owner one action at a time; it is not a request to run every historical test now.
- `RESULTS.md` and `TESTFLIGHT.md` contain chronological historical records; old NOT_RUN/Next action/PASS paragraphs do not override the latest dated audit and STATUS.
- Codex submits new implementation/device observations under `reports/<stage>/round-NN/`; ChatGPT publishes independent code/evidence reviews here. Do not edit old observations to look like new evidence.
- Upload markers are historical, path-scoped release controls governed by the actual workflow. No new upload marker is authorized by a documentation change; do not infer the active marker from an old audit filename.
- Source/generated entitlement presence, final code signature, profile allowance, Apple processing, device authorization, callback receipt, request acceptance and visible delivery are separate checks.
- Never store private app tokens, other apps' notification contents, Apple credentials/account identifiers, UDIDs or raw signing/profile material. Owner screenshots require consent and redaction before publication.
