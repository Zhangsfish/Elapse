# S03-C — Apple automated Family Controls review blocker

Date: 2026-10-08
Status: **BLOCKED_APPLE_ENTITLEMENT_GATE — OWNER_PORTAL_READBACK_REQUIRED**

## Observed by owner

The owner forwarded an App Store Connect / App Review automated message after
submission, stating the review "cannot proceed" because a Screen Time API app
"has not been submitted with the Family Controls entitlement". This is an
owner-provided automated reviewer message, not independently fetched ASC state,
and does not identify which bundle or precise server-side entitlement check failed.
Do not relabel it as a human reviewer verdict.

Affected candidate: Everwhile 0.1.0 (92.1), bundle
`com.zhangsfish.elapse`, currently the only selected review candidate.

## Verified earlier: exact submitted RC is signed correctly

The exact RC run:
https://github.com/Zhangsfish/Elapse/actions/runs/37580987653

- Git source `10b9e29f9d730e83a1fbd852fa49b09d83dd155a`
- Exact IPA SHA256:
  `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`
- IPA signed with Apple Distribution; `codesign --verify --strict` PASS.
- `com.apple.developer.family-controls == true` in **both code signature and
  embedded distribution provisioning profile**, independently checked for:
  1. `com.zhangsfish.elapse` (App)
  2. `com.zhangsfish.elapse.monitor` (DeviceActivity Monitor)
  3. `com.zhangsfish.elapse.report` (DeviceActivity Report)
- App Group checks PASS where required; `get-task-allow=false`.
- Upload ACCEPTED; processing VALID; build audience APP_STORE_ELIGIBLE.

The audit script `scripts/s03_review_ipa_audit.py` directly checks those signed
claims and decoded profile allowances; do not confuse this with only an
entitlements plist in source.

**Important correction:** none of these checks independently reads Apple's
Developer Portal **Family Controls (Distribution) / Capability Requests / Assigned**
approval state. The previous cloud decision treating this UI as optional or the
operational gate as conclusively closed was overconfident. Apple's own App Review
block makes authorization verification mandatory before more submissions.

## Apple official policy

- https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement
- https://developer.apple.com/documentation/xcode/configuring-family-controls
- https://developer.apple.com/help/account/capabilities/capability-requests

Official process: Account Holder requests distribution Family Controls for the
main App ID **and each Screen Time API extension App ID**. Apple approval shows
**Assigned** in the Developer Portal, and details show provisioning support for
App Store distribution. Development capability alone is not proof.

## Minimal owner portal action

In Apple Developer → Certificates, Identifiers & Profiles → Identifiers,
open each of the three App IDs above → Capability Requests → Family Controls
(Distribution). Record:

- Assigned + App Store provisioning support;
- Submitted / Pending;
- Not requested / No entry;
- Rejected / Other;
- Unclear.

Do not share account passwords, private certificates or provisioning profiles.
A screenshot with account IDs/redactions is optional; text status of the 3 IDs
is sufficient. This portal view is not presently available through the linked
GitHub connector.

## Branches of resolution

**A. Any of three not Assigned:** Account Holder submit/request the missing
Family Controls Distribution approval(s). Explain adult **individual** Screen
Time awareness: user selects apps, shared cumulative DeviceActivity monitoring,
quiet local reminders, on-device Today report; no shielding, account or
transmission of personal usage. Wait for Apple's approval or instructions.
Do not resubmit prematurely.

**B. All three Assigned and App Store-supported:** the 92.1 binary appears
correctly signed, so ask App Review to manually reconcile its entitlement check,
specify the flagged executable/App ID/key, and confirm server-side assignment.
2026 Apple Developer Forums contains a matching developer-reported automated
rejection despite approved distribution and correctly signed App/extension
binaries; not proof of a general Apple bug:
https://developer.apple.com/forums/tags/family-controls
Do not create build 93.1 merely to reset the automated check.

**C. Portal states unclear or Apple says a different entitlement is missing:**
ask Apple to name the precise bundle and key before changing code or
provisioning. The app uses tokenized Family Controls/DeviceActivity.
`approvedWithDataAccess` appears in authorization-state compatibility
handling, but no use of `FamilyActivityData` is established in this audit.
The separate `com.apple.developer.family-controls.app-and-website-usage`
entitlement must not be added speculatively.

## Reply outline if all three are Assigned

> Everwhile 0.1.0 (92.1) intentionally uses Family Controls and DeviceActivity.
> The submitted IPA is signed with Apple Distribution. We verified that
> `com.apple.developer.family-controls = true` is present in both the code
> signature and embedded App Store provisioning profile for the app, Monitor
> extension and Report extension. All three App IDs also show Family Controls
> (Distribution) Assigned with App Store support in the Developer Portal.
> Please recheck the entitlement assignment and the automated rejection, or
> identify the precise bundle ID, binary and entitlement key your system flags.
> We can supply redacted signing/profile evidence through Apple support.

Only claim Assigned if the owner actually confirms it. The user-facing reply
should be adapted to match their observed portal states.

## Hard holds

- No new IPA, TestFlight, code change or resubmission until portal/Apple
  evidence justifies it.
- No removal of legitimate Screen Time APIs to bypass review.
- No App public release; manual release remains.
- Marketing promo work is independent and not a technical fix for entitlement
  approval.
