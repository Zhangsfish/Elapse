# S02 UX research and product direction

Updated: 2026-10-05
Status: design baseline for S02; implementation authority remains STATUS + active S02 prompt.

## Why S02 exists

The functional foundation now works, but the visible App is still an engineering console.

Current main-screen problems:
- implementation labels such as `S00-A` / `S01-B` leak into the product;
- permission/test/registration/debug details dominate the hierarchy;
- ordinary users see config IDs, 299-event counts, generation/anchor and callback counters before the product value;
- the ordinary test-notification control is still first-class UI;
- Today is hidden behind a secondary navigation row and repeats long scope explanations;
- the hourly report is a long list of tiny bars rather than one glanceable daily shape;
- positive sub-minute buckets can visibly have activity yet render as `0m`;
- visual hierarchy is flat, so everything looks equally important.

The owner has already described the Today experience as “像毛坯、太丑”. S02 is the point where test scaffolding stops defining the product.

## Product constraint

Everwhile is not a blocker or self-help course.

The invariant remains:

> **Awareness before control.**

The interface should feel like a quiet instrument:
- show what is happening;
- make elapsed time and today's usage easy to perceive;
- let the user choose the interval / apps / on-off state;
- then get out of the way.

No score, streak, guilt, coach, “you failed”, focus grade, shield, lock, social comparison or productivity judgment.

## Benchmark research

### Apple Screen Time — hierarchy worth borrowing

Apple's Screen Time summary puts the aggregate first, lets the user switch day/week, and then exposes app/category breakdown below. The useful pattern is **headline metric -> time distribution -> detail rows**, not the restriction features themselves.

Reference:
https://support.apple.com/guide/iphone/get-started-with-screen-time-iphbfa595995/ios

### Opal — useful hierarchy, wrong philosophy for Everwhile

Opal makes the important number immediately visible and then lets the user drill into app-level usage and longer-range charts. That hierarchy is useful.

Everwhile must explicitly **not** copy Opal's Focus Score, “reclaimed time”, peer comparison, rewards, blocker framing or moral classification of screen time.

References:
https://opalapp.com/help/how-when-and-where-does-opal-report-your-screen-time
https://opalapp.com/blog/introducing-the-new-opal-home-screen-track-your-screen-time-and-improve-your-focus
https://brandkit.opal.so/

### ScreenZen / one sec — mostly anti-references

Both products foreground behavior-change interventions: delay, block, goals, streaks, reflection/friction. They are useful proof that this category often becomes feature-heavy.

Everwhile's differentiation should be visible in the UI by **not** presenting those mechanisms.

References:
https://apps.apple.com/us/app/screenzen-screen-time-control/id1541027222
https://apps.apple.com/us/app/one-sec-screen-time-focus/id1532875441

### Apple chart guidance

For hourly usage, the underlying data is a sum per hour, so a bar chart is the natural truthful mark. The data should dominate; axes/help text should recede. Charts need accessible labels and should not rely on color alone.

Reference:
https://developer.apple.com/design/human-interface-guidelines/charts

## S02 information architecture

### 1. Main screen = product state, not diagnostics

The normal screen should answer four questions in seconds:

1. Is Everwhile on?
2. What interval am I using?
3. How many Apps are selected?
4. Where did today's selected-App time go?

Proposed reading order:

**Everwhile**
- optional quiet subline: “All the while, time passes.” / localized equivalent.

**Monitoring card**
- one human status: On / Off / Needs permission / Needs Apps;
- pulse interval;
- selected-App count;
- one primary action: Start or Stop;
- tap rows to edit Apps / interval when allowed.

Do not show on the primary surface:
- config UUID;
- event count 299;
- generation;
- anchor;
- callback counters;
- recovery reason;
- raw authorization enum;
- ordinary test notification.

Those remain available under an explicit **Diagnostics / Advanced** destination for troubleshooting.

### 2. Today should be visually primary

Today is not a developer report. It is the retrospective half of the product.

Within the DeviceActivityReport extension, use this hierarchy:

**Hero**
- “Today” / localized date scope;
- selected-App total as the largest number;
- last updated as subdued metadata.

**Hourly distribution**
- one compact bar chart across the local day;
- bars represent hourly aggregate duration only;
- sparse X-axis labels (for example 0 / 6 / 12 / 18 or equivalent);
- no fabricated exact sessions;
- one short caption: hourly usage, not exact open/close times.

**Apps**
- selected Apps ranked by duration;
- each row shows Apple-provided token label + duration;
- optional proportional background/bar to make relative share glanceable;
- no “worst app”, “culprit”, score or red-warning semantics.

### 3. Empty/loading/unavailable states

Keep three states semantically distinct:
- loading / system report pending;
- valid zero selected-App usage;
- unavailable / ambiguous data.

Never turn “report unavailable” into “0 minutes”.

## Duration formatting decision

Positive usage must never display as `0m`.

Baseline:
- 0 seconds -> `0m`;
- >0 and <60 seconds -> `<1m` / localized equivalent;
- >=60 seconds and <1h -> whole minutes;
- >=1h -> hours + minutes.

The chart itself can retain continuous seconds for bar height. Text rounding is presentation only.

## Localization

S02 production UI must support:
- Simplified Chinese;
- English.

Use a proper string catalog / localization resources; do not duplicate large view trees by language.

User-visible technical diagnostic terms may remain concise but still need understandable localized labels.

## Visual language

- native SwiftUI first;
- quiet, sparse, high legibility;
- semantic/system colors preferred;
- both light and dark mode;
- Dynamic Type;
- VoiceOver descriptions for chart meaning and app-duration rows;
- do not use color as the sole status distinction;
- avoid decorative gradients/3D/gamified cards that make the product look like a launch presentation.

No requirement to imitate any competitor's skin.

## Privacy / architecture boundary

Protected DeviceActivityReport data stays inside the report extension.

Do not:
- move App names / tokens / per-App usage into App Group;
- invent an export path;
- infer exact sessions from hourly buckets;
- add analytics/account/cloud/AI;
- change S01 monitoring semantics merely to make the UI easier.

## S02 split

### S02-A — production shell + Today redesign
Do now:
- replace engineering-console primary UI with production hierarchy;
- move diagnostics/test tools behind Advanced;
- redesign Today total / hourly chart / app ranking;
- fix duration precision;
- add zh-Hans + English localization foundation;
- preserve all S01 functional behavior.

### S02-B — onboarding/polish
Locked until S02-A audit.

Likely candidates:
- first-run setup polish;
- “choose Apps” instructional animation if still useful;
- copy tightening after device review;
- final spacing/iconography/accessibility polish;
- optional app-language-specific refinements.

Do not pre-implement S02-B inside S02-A.
