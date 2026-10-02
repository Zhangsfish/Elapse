# AGENTS.md

This repository is the single source of truth for **Elapse**.

## Read order

Before changing code or product behavior, read:

1. `STATUS.md`
2. `docs/PRODUCT_DECISIONS.md`
3. `docs/PRODUCT_SPEC.md`
4. `docs/APPLE_PLATFORM_NOTES.md`
5. `docs/TECHNICAL_PLAN.md`
6. the active task under `prompts/`

## Product authority

- Product truth and brand foundation: `docs/PRODUCT_DECISIONS.md`.
- Current behavioral contract: `docs/PRODUCT_SPEC.md`.
- If a proposed name, feature, notification, or marketing idea conflicts with the product truth, change the proposal rather than silently changing the product philosophy.

## Product invariant

Elapse exists to **make elapsed time perceptible**.

Default intervention:
- observe selected-app foreground usage;
- accumulate usage across the selected group;
- emit a quiet pulse every configured interval;
- show truthful retrospective usage.

Do not turn Elapse into a blocker, parental-control suite, productivity coach, habit tracker, or AI assistant unless a future product decision explicitly changes the scope.

## Engineering rules

- Prefer Apple public APIs and first-party frameworks.
- Prefer boring, local, low-maintenance architecture.
- No account, cloud backend, analytics SDK, ad SDK, or AI API in the baseline product.
- Do not invent data Apple does not expose.
- Do not infer exact app-open/app-close sessions from hourly aggregate buckets.
- Do not calculate authoritative usage as `number of callbacks × pulse interval`.
- Treat callbacks as events that may be delayed, duplicated, or delivered under OS constraints.
- Preserve privacy: opaque Screen Time tokens are acceptable and preferred for the baseline.
- Keep ordinary Family Controls authorization as the baseline. EU-only `approvedWithDataAccess` must not become a hidden dependency.
- Any Screen Time extension requiring distribution entitlement must be documented explicitly.
- Simulator/build success is not a substitute for real-device validation.

## Workflow

For each stage:

1. Create a focused branch.
2. Implement only the active stage.
3. Run all tests that are actually runnable.
4. Record exact commands/results.
5. Update `STATUS.md` with PASS / HOLD / BLOCKED / NOT RUN.
6. Open a PR with a concise evidence-based summary.
7. Do not mark real-device gates PASS without real-device evidence.

If blocked by signing, entitlement approval, hardware, or App Store Connect, finish all independent work and leave the smallest possible user action list.

## Secrets

Never request, print, commit, or expose:
- Apple private keys;
- `.p8` contents;
- signing certificates/private keys;
- passwords;
- provisioning secrets.

Reuse existing secret names only if they already exist in the repository/environment and are clearly appropriate.
