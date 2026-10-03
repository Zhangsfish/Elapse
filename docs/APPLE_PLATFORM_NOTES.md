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

For the current TestFlight path, the owner reports that Family Controls Development + Distribution is enabled on the main app and both extensions. That account state is separate from repository compile evidence and must still be proven by a successful distribution export/upload.

For S00-A, Apple [TN3125](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles) clarifies that a provisioning profile's `Entitlements` are an allowlist, not the entitlements claimed by an executable's code signature. The 19.1 upload reached `VALID` but subsequently produced `ITMS-90897` for the main app, and its upload-only export retained no IPA for local signature inspection. A controlled export reproduced the cause: all three profiles allowed Family Controls but all three cloud-distribution signatures omitted the claim because the source archive was unsigned. Adding `archived-expanded-entitlements.xcent` alone did not change that. An Xcode archive step using `Apple Distribution` directly was rejected by the current signing configuration; no development or UDID provisioning route was added.

The S00-A release path now gives the temporary unsigned archive an identity-free, entitlement-bearing placeholder signature for each nested extension and then the main app. That intermediate is never uploaded or installed; it uses no certificate, device registration, or ad-hoc provisioning profile. Xcode still performs automatic cloud-managed App Store distribution signing. The release script then checks the exact exported IPA's bundle code signatures and embedded profile allowlists separately and uploads that same IPA with altool. Build 27.1 passed all three signature/profile checks, was accepted, processed `VALID`, and App Store Connect reported `INTERNAL_ONLY`, `IN_BETA_TESTING`, and internal-group assignment. This evidence addresses signing/delivery only; it does not prove Screen Time behavior on a device.

For S00-A notification self-check, Apple [documents](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/alertsetting) that `alertSetting == enabled` permits alerts but does not guarantee a visible banner. A successful `UNUserNotificationCenter.add` likewise proves request submission, not presentation on the owner's iPhone.

## Distribution and privacy manifests

Apple's current asset-catalog guidance allows Xcode to generate iOS icon variations from a single 1024×1024 image. Archive inspection on Xcode 26 showed that setting `TARGETED_DEVICE_FAMILY=1` only at the project base did not prevent XcodeGen's main target from compiling with `UIDeviceFamily=[1,2]`; Everwhile now sets it explicitly on each target. The main app declares `UISupportedInterfaceOrientations` for portrait and both landscape directions. CI checks the compiled archive plist and `Assets.car` before any upload.

XcodeGen 2.46.0 generates and overwrites every `info.path` plist from `info.properties`; a dictionary present only in a tracked source plist can disappear from the archive. The failed Everwhile archive had no `NSExtension` in either `.appex`. The monitor's generated plist must contain `com.apple.deviceactivity.monitor-extension` and its `DeviceActivityMonitor` subclass principal class. The report's `@main DeviceActivityReportExtension` conforms to Apple's `AppExtension` protocol; it is packaged as an ExtensionKit extension under `Extensions/` with `EXAppExtensionAttributes/EXExtensionPointIdentifier=com.apple.deviceactivityui.report-extension`, without a legacy `NSExtensionPrincipalClass`. CI checks the final archive, not just project/source declarations.

References: [XcodeGen 2.46.0 project spec](https://github.com/yonaskolb/XcodeGen/blob/2.46.0/Docs/ProjectSpec.md), [Apple DeviceActivityMonitor](https://developer.apple.com/documentation/deviceactivity/deviceactivitymonitor), [Apple DeviceActivityReportExtension](https://developer.apple.com/documentation/deviceactivity/deviceactivityreportextension), [Apple DeviceActivityReport extension point](https://developer.apple.com/documentation/deviceactivity/deviceactivityreport), [Apple ExtensionKit attributes example](https://developer.apple.com/documentation/marketplacekit/marketplaceappextension). The ExtensionKit packaging choice is also supported by [developer-reported upload/install evidence](https://developer.apple.com/forums/thread/809227); its real-device behavior remains unverified for Everwhile.

Official docs:
- https://developer.apple.com/documentation/xcode/configuring-your-app-icon
- https://developer.apple.com/documentation/bundleresources/information-property-list/uisupportedinterfaceorientations

Apple's current App Store upload requirement is Xcode 26 or later. The repository therefore uses a GitHub-hosted `macos-26` runner and rejects an older selected Xcode before preparing an archive.

The app and monitor extension use `UserDefaults` only to read or write preferences owned by the same app. Each executable that calls that API includes a privacy manifest declaring required-reason code `CA92.1`. The report extension does not call `UserDefaults` and does not inherit that declaration merely because it is embedded in the app.

Official docs:
- https://developer.apple.com/news/upcoming-requirements/
- https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api

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

## S00 current-API verification

Rechecked against Apple's current public documentation on 2026-10-02:

- `DeviceActivityEvent` accumulates the combined activity of the applications, categories, and web domains supplied to one event. S00 therefore supplies every selected `ApplicationToken` to each named 5/10/15/20/25/30-minute event, which is the public-API expression of one shared pool.
- `includesPastActivity` controls whether activity earlier in the active schedule interval contributes when monitoring starts. S00 explicitly sets it to `false`: every stop/start is a new understandable experiment and use earlier that day is excluded.
- `DeviceActivityFilter.SegmentInterval.hourly(during:)` is a supported aggregate interval. S00 requests hourly segments for the current calendar day.
- `DeviceActivityData.ActivitySegment.totalActivityDuration` is documented as screen-on time for the segment. The selected-app chart must instead sum each filtered `ApplicationActivity.totalActivityDuration`; it must not present segment screen-on duration as selected-app usage.
- Baseline per-app identity remains opaque. The report renders Apple's `Label(ApplicationToken)` rather than depending on bundle identifiers or the EU-only data-access entitlement.

Official docs:
- https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/init(applications:categories:webdomains:threshold:includespastactivity:)
- https://developer.apple.com/documentation/deviceactivity/deviceactivityfilter/segmentinterval-swift.enum/hourly(during:)
- https://developer.apple.com/documentation/deviceactivity/deviceactivitydata/activitysegment/totalactivityduration
- https://developer.apple.com/documentation/deviceactivity/deviceactivitydata/applicationactivity/totalactivityduration
- https://developer.apple.com/documentation/familycontrols/displayingactivitylabels

No repository/API conflict requiring an architecture change was found. The current SDK marks `approvedWithDataAccess` as iOS 26.4+ and documents that it includes ordinary `.approved` abilities plus non-tokenized data access. Elapse availability-checks that status only as an authorization-state compatibility case; it remains EU/customer-restricted, mutually exclusive between apps on a device, and outside the S00 baseline.

Compilation was verified in GitHub-hosted CI with Xcode 26.6, iOS SDK 26.5, and Swift 6.3.3. One concrete source correction was required: `ApplicationToken` is declared by `ManagedSettings`, while the privacy-preserving SwiftUI `Label(ApplicationToken)` presentation is supplied through `FamilyControls`. The report extension imports both frameworks. This was a symbol ownership correction, not a change to the product architecture or privacy model.

## What S00 must answer empirically

1. Can selected apps contribute to one shared cumulative usage event on the target device?
2. Are 5/10/15/20/25/30 minute thresholds reliable enough for the product?
3. How do callbacks behave across app switching, lock/unlock, monitor restart, device restart, midnight, and permission changes?
4. What exact per-app/time-bucket detail can the report extension truthfully render?
5. Which steps require signing/provisioning/entitlement approval rather than code changes?
