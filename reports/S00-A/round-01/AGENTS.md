# S00-A round 01 task memory

This folder records only S00-A device-foundation delivery and owner observations. The upstream authority is repository `AGENTS.md`, `STATUS.md`, `prompts/S00_A_DEVICE_FOUNDATION.md`, and `docs/WORKFLOW.md`.

- `DELIVERY.md`: concise provenance, signing/upload/CI evidence, and unresolved issues.
- `TEST_RESULTS.json`: machine-readable statuses. `NOT_RUN` never means pass.
- `DEVICE_OBSERVATIONS.md`: owner-reported phone observations, one action at a time. Do not infer device behavior from CI.
- `evidence/`: safe, non-secret evidence if needed. Never commit raw signing logs, provisioning profiles, tokenized selections, or owner screenshots without permission.

Build artifacts and screenshots are not canonical in this repo. GitHub Actions run URLs and exact SHAs are the provenance for CI and distribution; the owner's natural-language observations are the provenance for device tests.
