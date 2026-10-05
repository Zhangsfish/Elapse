# S02-B delivery

State: IN_PROGRESS. Base main: `c1480eb0021c1fc2261a54ace4576feb7c537d8d`.
Branch: `codex/s02-b-onboarding-polish`. Exact runtime/tested/upload SHAs, PR and build will be recorded after checks; no unexecuted check is PASS.

## Changes

Single-screen setup remains permission -> selection -> Start -> quiet ON/Stop. A generic, optional selection illustration shows two checkmarks and confirmation; it appears inline only with authorization, no selected apps and editable selection. Returning users can open Selection tips without clearing their choices. Reduce Motion/VoiceOver use static illustration; actual selection remains FamilyActivityPicker.

Pulse copy uses the Monitor bundle's en/zh-Hans resources and the actual threshold. Pure and resource-backed tests cover multiple thresholds and safe missing-resource English fallback. Tagline matches Everwhile's product direction.

Duration formatting follows the bundle's resolved localization, not every `zh` locale. Explicit Traditional Chinese scripts use English in the pure fallback resolver; no Traditional Chinese product language added. Home summary and report App rows stack at accessibility sizes; chart height scales with Dynamic Type. Aggregation, lifecycle, registration semantics, groups, capabilities and IDs are unchanged.

PRODUCT_SPEC previously contained historical `today` pulse wording inconsistent with current interval semantics; this stage updates only that copy contract to the active prompt's reminder-point wording.

## Verification boundaries

Windows has no Xcode. Use existing macos-26 CI / XcodeGen / native XCTest and internal TestFlight route. Ordinary CI uses no secrets. New packaging assertions cover App, Monitor and Report in simulator/device/archive. Native UI smoke runs on a clean simulator with English light and zh-Hans dark/accessibility text; it cannot prove Screen Time behavior or human VoiceOver quality.

Apple references verified against current official documentation: [bundle language selection](https://developer.apple.com/documentation/foundation/bundle/preferredlocalizations), [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion), [Dynamic Type](https://developer.apple.com/videos/play/wwdc2024/10074/). Current SDK compilation remains separate evidence.
