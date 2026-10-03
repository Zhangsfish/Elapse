# AGENTS.md

This repository is the single source of truth for Everwhile (internal project/repository: Elapse).

## Read order

1. `STATUS.md` — the only current dispatch authority.
2. `docs/WORKFLOW.md` — Codex-led implementation/device testing; ChatGPT audit.
3. `docs/EXECUTION_PLAN.md` — stage boundaries.
4. The single active task named in STATUS, under `prompts/`, and its audit references.
5. `docs/PRODUCT_DECISIONS.md`, `docs/PRODUCT_SPEC.md`, `docs/APPLE_PLATFORM_NOTES.md`, `docs/TECHNICAL_PLAN.md` as needed for the active changes.

Historical prompts/audits are evidence, not current dispatch. Do not restart the original all-in-one S00 prompt or execute a LOCKED stage. Start through `handoff/CODEX_START.md`.

## Roles

- Owner: product decisions, personal-account/expense/legal authorization, physical-iPhone actions and observations.
- Codex: inspect actual code, implement the active stage, run feasible checks, prepare internally distributed builds, guide the owner **one small device action at a time**, diagnose/fix/retest, and submit evidence/PR.
- ChatGPT cloud: publish tasks, inspect code/diffs/CI/evidence, audit exact SHAs, merge approved changes and unlock the next stage. No parallel implementation or competing cloud-led device checklist under the current owner direction.

Codex does not self-approve, self-merge or unlock stages. While waiting for phone feedback use `WAITING_FOR_OWNER_TEST`, then continue the same task. Reach `READY_FOR_AUDIT` only after the task's required evidence; unavailable evidence stays NOT_RUN/BLOCKED.

## Product authority and invariant

Product truth and brand: `docs/PRODUCT_DECISIONS.md`. Behavioral contract: `docs/PRODUCT_SPEC.md`.

**Make elapsed time perceptible. Awareness before control.** Observe selected-app usage, accumulate across the selected group, request quiet pulses, show truthful retrospective usage. Five minutes is a default, not the brand.

No blockers/shields, guilt, scores, streaks, coaching, accounts, cloud backend, analytics/ad SDK or AI API in the baseline. Do not change product philosophy to justify a feature.

## Engineering

- Apple public APIs/frameworks first; small, local, low-maintenance architecture.
- Source/config presence, build success, final code signature, profile allowance, Apple processing, TestFlight access, installation and actual runtime behavior are separate states.
- A VALID upload does not close a Family Controls entitlement warning. Check final signed artifacts and device authorization.
- Never invent exact sessions from hourly buckets or authoritative usage from callback count multiplied by interval. Callbacks may be delayed/duplicated; registration is not proof of delivery.
- Ordinary Family Controls authorization is the baseline; do not depend on EU-only enhanced data access.
- Keep Screen Time tokens/private report data private. App Groups, if separately justified in the active task, carry only app-owned configuration/diagnostic state, not report-data exfiltration.
- On Windows + iPhone/TestFlight, extension OSLog is not assumed accessible. Provide an actually usable diagnostic path before asking the owner for callback evidence.
- Verify current Apple documentation/SDK for changed APIs. Preserve generated plist/entitlement assertions after XcodeGen.
- Ordinary CI is secret-free. Do not ask to reconfigure existing Apple credentials, register UDIDs, buy tools or create extra signing assets without an evidenced need and applicable owner authorization.
- Reuse the existing internal TestFlight route. Preparing internal builds does not authorize public release, additional testers, new account roles or legal agreements.

## Git and audit

One active substage per branch/PR. Record base, implementation/tested/upload SHA, PR head, version/build, commands, CI URLs, environment and evidence provenance. Codex reports go in `reports/<stage>/round-NN/`; ChatGPT verdicts go in `audits/`.

New implementation after a tested/reviewed SHA requires affected tests and review again. Do not merge failed or unverified code merely to trigger a pipeline. Do not use one-time upload markers for ordinary document changes. Source edits by the cloud reviewer are not an independent implementation audit.

Only actions genuinely requiring the owner should be delegated: exact physical action or private-account confirmation, with one step and the reason. Owner replies can be conversational; Codex structures the report. Private screenshots require consent and redaction before public upload.

## Secrets

Never request, print, commit or expose Apple private keys/.p8, signing private certificates, passwords, JWTs or raw provisioning material. Reuse existing setting names; log only safe diagnostics. Never put opaque tokens, private app notifications, Apple account details or UDIDs in public evidence.
