# Technical Plan

## Architecture philosophy

Keep the product boring.

Use Apple frameworks for observation and delivery. Elapse should not run its own continuous screen recorder, VPN, accessibility monitor, or cloud service.

## Baseline targets

### 1. Main iOS app
Responsibilities:
- explain the product in one screen;
- request individual Family Controls authorization;
- present Apple's app picker;
- store selected tokens locally;
- choose pulse interval;
- start/stop monitoring;
- host the Today report view.

Frameworks:
- SwiftUI
- FamilyControls
- DeviceActivity
- UserNotifications

### 2. DeviceActivityMonitor extension
Responsibilities:
- receive named threshold callbacks;
- record minimal diagnostic metadata;
- request a local notification;
- behave idempotently if a callback repeats.

It must not:
- block apps;
- infer morality/productivity;
- treat callback count as ground-truth duration.

### 3. DeviceActivityReport extension
Responsibilities:
- aggregate/report data Apple supplies;
- render honest per-app totals;
- render supported time-distribution buckets.

It must not:
- leak protected report data through unofficial side channels;
- fabricate exact sessions.

## Local shared state

If an App Group is needed, use it only for Elapse-owned state such as:
- configuration;
- selected-token archives where permitted;
- pulse interval;
- monitor enabled state;
- diagnostic callback receipts.

Do not use App Groups as a workaround to exfiltrate protected report data.

## Pulse model

For S00:
- hard-code test interval = 5 minutes;
- register thresholds at 5/10/15/20/25/30 minutes;
- name each threshold deterministically;
- notification body should derive from the named reached threshold, not from callback count.

For later stages:
- generate thresholds safely for the configured daily operating range;
- reset/re-register across day boundaries in a way proven by real-device tests;
- handle timezone/calendar changes explicitly.

## Data model principle

Separate three concepts:

1. **Configured threshold** — what usage boundary the system was asked to monitor.
2. **Callback receipt** — what the OS told the extension and when.
3. **Reported usage** — what Device Activity reporting APIs say happened.

These are not interchangeable.

## Testing strategy

### Automated
Test pure logic:
- threshold generation;
- identifiers;
- notification copy;
- duplicate callback suppression;
- date/day reset calculations;
- configuration serialization.

### Real device
Required:
- authorization;
- picker;
- shared app pool;
- threshold delivery;
- notifications;
- report rendering;
- lock/switch/restart/cross-day behavior.

Simulator results must never be used to declare Screen Time behavior correct.

## Stage plan

### S00 — Feasibility
Prove monitoring, notification, and report primitives.

### S01 — Daily pulse
Turn the validated primitive into a day-long reliable 5-minute pulse loop. Handle reset, re-registration, error states, permission changes, and minimal production UI.

### S02 — Today report
Polish truthful per-app and time-distribution visualization. Add only export forms legitimately supported by the platform.

### S03 — Distribution
Family Controls entitlement approval, signing, TestFlight, privacy copy, App Store compliance, and external-user testing.

Do not begin a later stage to hide a failed earlier gate.
