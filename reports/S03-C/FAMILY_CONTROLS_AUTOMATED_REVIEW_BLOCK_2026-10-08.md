# S03-C — Apple automated Family Controls review blocker

Date: 2026-10-08
Status: **BLOCKED_APPLE_AUTOMATED_REVIEW — THREE PORTAL ASSIGNMENTS OWNER_VERIFIED; MANUAL_RECHECK_NEEDED**

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


## Owner Developer Portal readback — 2026-10-08

Owner reviewed Apple's live Certificates, Identifiers & Profiles screens:

| Bundle ID | Capability Requests status | Detail: App Store Connect provisioning |
|---|---|---|
| `com.zhangsfish.elapse` | **Assigned** | NOT_SHOWN_IN_OWNER_SCREENSHOT; the exact 92.1 distribution signature/profile allows the entitlement |
| `com.zhangsfish.elapse.monitor` | **Assigned** | **Confirmed:** Development, Ad hoc, App Store Connect |
| `com.zhangsfish.elapse.report` | **Assigned** | **Confirmed:** Development, Ad hoc, App Store Connect |

For Monitor and Report the detail popover also displays:
`Entitlement Keys: com.apple.developer.family-controls`, matching the exact
code signatures and embedded App Store profiles in the 92.1 IPA audit.

Evidence type: **OWNER_VISIBLE_APPLE_PORTAL_SCREENSHOTS**. Original screenshots
are kept in the conversation, not uploaded to public GitHub because they expose
account/team information. No password, provisioning payload, or account identifier
other than the public app bundle IDs is copied to this report.

**Conclusion:** No missing request or Pending/Submitted state has been found
across the three shipping App IDs. The mismatch between the reviewer bot's
"not submitted with entitlement" message and our approval/signature evidence
now warrants a **manual App Review reassessment** before any binary change.
This is strong grounds for a false-positive investigation, not proof of Apple's
server-side logic.

### Recommended immediate reply in App Store Connect

> Hello App Review Team,
>
> Thank you for your message. Everwhile 0.1.0 (92.1) intentionally uses
> the Screen Time APIs. We have already received Family Controls
> (Distribution) approval for all three App IDs:
>
> - com.zhangsfish.elapse — Assigned
> - com.zhangsfish.elapse.monitor — Assigned
> - com.zhangsfish.elapse.report — Assigned
>
> The Monitor and Report approvals explicitly list App Store Connect
> under Provisioning Support. For the exact submitted 92.1 IPA, we
> independently inspected the Apple Distribution code signatures and
> embedded provisioning profiles of the main app and both extensions;
> all three contain com.apple.developer.family-controls = true.
>
> Could you please recheck this automated entitlement finding and
> continue the review, or identify the exact bundle ID, executable,
> entitlement key, or server-side authorization that failed your check?
> We can provide redacted screenshots and signing evidence if needed.
> We have not removed Screen Time functionality or changed the submitted build.
>
> Thank you.

Do not state that Apple's review already resumed. Do not resubmit/withdraw or
upload build 93.1 solely because of this automated message. If Apple identifies
a specific key or binary, assess it independently first.

### Secondary technical diagnostic only if Apple requests further detail

Apple separately documents the
`com.apple.developer.family-controls.app-and-website-usage` entitlement.
Everwhile's source checks `AuthorizationStatus.approvedWithDataAccess` only to
normalize an authorization status; the product uses ordinary tokenized
Family Controls/DeviceActivity, not `FamilyActivityData` or privileged
bundle/domain identifiers. A 2026 Apple Developer Forums report describes a
similar automated rejection despite correctly assigned Family Controls and a
signed IPA, where the author investigated such symbol references. This is
an *unproven hypothesis*, **not** grounds to add enhanced-data entitlements or
modify the accepted runtime preemptively. Wait for Apple's exact flag if its
manual recheck does not resolve the issue.
https://developer.apple.com/forums/tags/family-controls

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
