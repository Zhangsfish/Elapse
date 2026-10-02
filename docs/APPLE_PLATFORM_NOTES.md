# Apple Platform Notes

Last reviewed: 2026-10-02

This file records platform facts that affect Elapse. Verify against the current SDK and Apple documentation before changing architecture.

## Baseline frameworks

### FamilyControls
Purpose:
- request authorization;
- let the user select apps/websites/categories through Apple's privacy-preserving picker.

For a self-use app, Apple exposes individual authorization through:

`AuthorizationCenter.shared.requestAuthorization(for: .individual)`

Official docs:
- https://developer.apple.com/documentation/FamilyControls/AuthorizationCenter
- https://developer.apple.com/documentation/FamilyControls/AuthorizationCenter/requestAuthorization(for:)
- https://developer.apple.com/documentation/familycontrols

### DeviceActivity
Purpose:
- monitor device activity according to a schedule;
- receive callbacks when configured activity thresholds are reached;
- render privacy-preserving activity reports through report extensions.

Elapse's core S00 hypothesis is that multiple selected application tokens can be monitored as one event/pool and thresholds can represent cumulative selected-app usage.

Official overview:
- https://developer.apple.com/documentation/ScreenTimeAPIDocumentation

### UserNotifications
Purpose:
- request notification permission;
- request local notifications when an activity threshold is reached.

Notification request success is not the same as visible delivery. Focus modes, notification settings, summaries, and OS behavior may affect what the user sees.

## Entitlements

### Family Controls

The app and relevant Screen Time API extensions require the Family Controls capability.

Apple states that distribution requires entitlement approval, and Screen Time API extensions need to be included in the request.

Official docs:
- https://developer.apple.com/documentation/FamilyControls/requesting-the-family-controls-entitlement
- https://developer.apple.com/documentation/Xcode/configuring-family-controls
- https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.family-controls

Do not assume the existing Apple Developer Program membership automatically grants distribution approval for a new App ID/extension.

## Standard privacy model

Under ordinary authorization, application and web selections are represented with privacy-preserving tokens.

This is acceptable for the Elapse baseline because the user selects the monitored set directly.

The main app should not depend on knowing raw bundle identifiers.

## Device Activity reports

A Device Activity Report extension is the baseline route for showing usage inside the app.

Important product rule:
- report interval/bucket boundaries are not automatically exact app-open/app-close sessions;
- never fabricate exact session boundaries from aggregate usage.

## Structured usage export

Apple now documents:

`DeviceActivityData.activityData(filteredBy:using:)`

as a way to export family activity data for use in another app/platform.

But customer use is restricted:
- device located in the EU;
- signed into an Apple Account with an EU country/region;
- authorization status `approvedWithDataAccess`;
- Family Controls App and Website Usage entitlement.

Official docs:
- https://developer.apple.com/documentation/deviceactivity/deviceactivitydata/activitydata(filteredby:using:)
- https://developer.apple.com/documentation/FamilyControls/AuthorizationStatus/approvedWithDataAccess
- https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.family-controls.app-and-website-usage

Therefore this API is **not** a baseline dependency for Elapse.

## Important exclusivity / coexistence risk

Apple documents that only one app at a time can hold `approvedWithDataAccess` on a device. Treat the enhanced data-access mode as a separate future product decision, not as an automatic upgrade.

## Reliability risk

Screen Time / Device Activity behavior has generated developer reports of early, duplicate, or otherwise surprising threshold callbacks on recent iOS versions.

A forum report is not an API contract, but it is enough reason to require real-device validation:
- https://developer.apple.com/forums/thread/808470

Engineering consequence:
- record callback identity and receipt time;
- make handlers idempotent;
- never derive authoritative total usage from callback count;
- test on the actual target iPhone before declaring S00 PASS.

## What S00 must answer empirically

1. Can selected apps contribute to one shared cumulative usage event on the target device?
2. Are 5/10/15/20/25/30 minute thresholds reliable enough for the product?
3. How do callbacks behave across app switching, lock/unlock, monitor restart, device restart, midnight, and permission changes?
4. What exact per-app/time-bucket detail can the report extension truthfully render?
5. Which steps require signing/provisioning/entitlement approval rather than code changes?
