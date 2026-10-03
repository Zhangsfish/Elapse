# Technical Plan

Updated: 2026-10-03

## Architecture

Keep the current small native implementation. Use Apple's public Screen Time APIs for observation; no screen recorder, VPN, accessibility monitor or cloud service.

### Main iOS app

SwiftUI + FamilyControls + DeviceActivity + UserNotifications. Request individual authorization, present Apple's picker, persist opaque selections, start/stop configured monitoring, host the report, and expose truthful app-owned status.

Interval configuration and production recovery are planned S01 capabilities, not claims about installed S00 build 19.1. A visible diagnostic path must precede device tests that need it.

### DeviceActivityMonitor extension

Receive named threshold callbacks, record minimal app-owned diagnostic events, and request local notifications idempotently. Do not infer actual usage from callback count. Callback receipt, request acceptance and visible delivery remain separate.

### DeviceActivityReport extension

Aggregate real data in the protected report environment and render per-app totals plus supported hourly buckets. Use Apple's opaque labels. Make device/date scope explicit; no fabricated sessions and no report-data side channel.

## Shared state, only when justified

An App Group may be necessary later for experiment/configuration identities and extension callback diagnostics accessible from the main app. Establish the need in the active task, configure/sign it correctly, and keep it limited to app-owned data. It must not export protected Screen Time report data.

S00-A does not add an App Group. It covers final signing, authorization, selection and ordinary local-notification self-test only. S00-B addresses actual threshold observation and repeatable experiments.

## Pulse semantics

Current experimental code registers only 5/10/15/20/25/30-minute events across the same selected application tokens, with includesPastActivity=false. It does not implement an unlimited day-long pulse loop or interval settings.

Before usage testing, fix the static mismatch between date-only deduplication and stop/start experiments, and between changed UI selections and existing registered event tokens. Use tested experiment/configuration identities and explicitly handle late old callbacks; do not assume stop/start resets every layer.

S00 notifications describe the monitored experiment's threshold, not an authoritative natural-day total. Today uses a separately stated daily report interval. S01 will choose and validate daily coverage/reset/calendar semantics and configurable intervals against current SDK limits and real-device evidence.

Keep three data types separate:

1. configured thresholds;
2. callback receipts;
3. reported usage from DeviceActivityReport.

A Timer-based test notification is allowed only as an explicitly labeled one-shot notification diagnostic. A wall-clock timer is not usage accounting.

## Distribution

Retain existing bundle identifiers, Apple credentials, TestFlight infrastructure and generated plist checks. The 19.1 upload was accepted/VALID, but an Apple ITMS-90897 email still reports the parent App missing Family Controls entitlement. Current final-signature correctness is HOLD until checked.

Verify generated entitlements and effective target wiring, then actual distribution-signed code and profile authorization separately. Do not infer one from the other or replace an unreadable file with an empty dictionary. Verify that artifact evidence corresponds to what is uploaded if the upload path re-exports/re-signs.

Internal TestFlight upload, tester assignment, installation, runtime authorization and App Store public release are different gates. Existing internal-test authorization does not authorize public release or extra tester/account access.

## Testing and stages

The authoritative staged plan is `docs/EXECUTION_PLAN.md`; current dispatch is `STATUS.md`:

- S00-A: final-signature validation + authorization/selection + ordinary notification self-test.
- S00-B: first real shared-pool 5-minute pulse with observable and repeatable diagnostics.
- S00-C: limited-range 10–30-minute sequence and switching/stopping anomalies.
- S00-D: real Today rendering, scope and honest hourly aggregates.
- S01: day-long operation, configurable interval and lifecycle/calendar recovery.
- S02: minimal production experience and retrospective presentation.
- S03: public distribution preparation and separately authorized release.

Only the current stage may be implemented. Codex runs focused automatic checks, guides the owner one phone action at a time, fixes/retests, then delivers evidence for cloud audit. Simulator/CI success is not real Screen Time evidence. Pure-logic tests cover identifiers, threshold generation, copy, deduplication, serialization and date logic; they must not pretend to prove runtime delivery.

Structured export and exact sessions remain separately gated future goals, not baseline promises. EU-only enhanced data access, Watch, cloud, AI, accounts, analytics and payments stay out of this plan.
