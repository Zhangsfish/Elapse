# Product Specification

## 1. Problem

Some apps make elapsed time subjectively disappear. The product should restore awareness of time without telling the user what they are allowed to do.

## 2. Product principle

**Awareness before control.**

Elapse should make time perceptible, then get out of the way.

## 3. Primary user flow

### One-time setup
1. Grant the required Screen Time / Family Controls authorization.
2. Select several apps using Apple's system picker.
3. Choose a pulse interval. Default: **5 minutes**.
4. Enable Elapse.

### Daily use
The user uses their phone normally.

When cumulative foreground usage of the selected app group reaches each pulse boundary:

- 5 min
- 10 min
- 15 min
- …
- 120 min
- …

Elapse requests a quiet notification.

Target wording:

**Title**
`5 minutes passed`

**Body**
`Selected apps today: 120 minutes`

If the system cannot prove that exactly one clean 5-minute increment elapsed since the previous delivered callback, use safer wording:

**Title**
`120 minutes`

**Body**
`Selected apps have reached 120 minutes today.`

No moral language. No “wasted time”. No guilt.

## 4. Shared pool semantics

All selected apps belong to one logical pool.

Example:

- App A: 2 minutes
- App B: 3 minutes
- Unselected app: 20 minutes
- App A: 5 more minutes

Expected selected-app cumulative thresholds:
- first pulse at 5 minutes selected-app usage;
- second pulse at 10 minutes selected-app usage.

Wall-clock time outside the selected group must not be described as selected-app usage.

## 5. Today view

The user should be able to inspect:

- total selected-app usage today;
- per-app usage today, to the extent Apple exposes it in the report environment;
- a visual distribution across the day using supported report intervals/buckets.

The visual should answer:

> When during the day did this usage happen?

It must not claim false precision.

If Apple exposes only hourly aggregated duration, label the visualization as hourly usage. Do not render a fabricated exact session timeline.

## 6. Export goal

Long-term desired output:

- each app's total usage;
- when usage occurred;
- a machine-readable export suitable for later analysis.

However, export is constrained by Apple's privacy model.

Baseline product must not bypass report-extension sandboxing or misrepresent aggregate data as an exact event log.

If a future Apple entitlement/API legitimately allows structured export, implement it as a separately gated enhancement.

## 7. Interaction rules

Elapse does not:
- block;
- shield;
- impose cooldowns;
- ask why the user opened an app;
- require a breathing exercise;
- force a reflection prompt;
- require daily check-in;
- use streaks;
- give productivity scores;
- shame;
- congratulate;
- coach.

The notification itself is the intervention.

## 8. Privacy

Baseline:
- no account;
- no server;
- no analytics SDK;
- no ads;
- no AI API;
- no sale of data;
- no requirement to identify selected apps outside Apple's token model.

## 9. Design direction

The UI should feel like an instrument, not a self-help program.

Desired qualities:
- quiet;
- sparse;
- obvious;
- readable;
- low configuration burden.

The product should still make sense if the user opens the main app only once per week.
