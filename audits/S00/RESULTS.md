# S00 results

Updated: 2026-10-02

## Code and CI evidence

Pending first CI run on `codex/s00-screen-time-feasibility`.

## Evidence state

| Item | Status | Evidence / limitation |
|---|---|---|
| Reproducible XcodeGen project definition | PENDING CI | `project.yml`; XcodeGen 2.46.0 is fetched to the ephemeral runner and SHA-256 verified. |
| App + monitor + report extension Simulator compile | PENDING CI | Compile evidence only; Simulator cannot validate Screen Time delivery. |
| Pure logic tests | PENDING CI | Thresholds, identifiers, copy, duplicate decision, and today interval. |
| Individual authorization on iPhone | NOT RUN | Physical iPhone and signing required. |
| Multi-app shared threshold pool | NOT RUN | Physical iPhone required. |
| Unselected/locked time exclusion | NOT RUN | Physical iPhone required. |
| 5–30 minute callback timing/duplicates | NOT RUN | Physical iPhone required. |
| Local notification request from callback | NOT RUN | Physical iPhone required. |
| Visible notification delivery | NOT RUN | Must be observed separately from request acceptance. |
| Per-app/hourly Today report | NOT RUN | Physical iPhone required for real Screen Time data. |

## Signing and entitlement blockers

Family Controls distribution approval is not established for:

- `com.zhangsfish.elapse` — main app;
- `com.zhangsfish.elapse.monitor` — Device Activity Monitor extension;
- `com.zhangsfish.elapse.report` — Device Activity Report extension.

Development signing and a physical-device run remain owner-side prerequisites. No Apple key, certificate, profile, Team ID, or App and Website Usage entitlement is stored in this repository.
