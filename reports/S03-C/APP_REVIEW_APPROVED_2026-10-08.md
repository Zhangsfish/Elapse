# S03-C — Apple App Review approved Everwhile 0.1.0

Date: 2026-10-08
Evidence: **OWNER_PROVIDED_APPLE_APPROVAL_EMAILS_AND_SCREENSHOT**
State: **APPROVED_FOR_DISTRIBUTION — PUBLIC_RELEASE_NOT_YET_VERIFIED**

## Apple result

The owner supplied two Apple App Review/ASC messages:

1. "Review of your submission has been completed. It is now eligible for distribution."
   The accepted item is Everwhile **0.1.0 for iOS**.
2. "We're pleased to let you know that your app, Everwhile, has been approved
   for distribution."

The screenshot identifies one accepted iOS 0.1.0 item and links to the public
App Store product URL:

https://apps.apple.com/app/everwhile/id6818551574

The email confirms App Review **approval**. It does **not**, by itself, prove
the product has been **manually released**, that Apple contracts are active,
or that the US listing is already publicly downloadable. Apple explicitly
says appearance after release may take up to 24 hours.

The earlier automated Family Controls review blocker is therefore superseded
by the actual acceptance. The exact internal cause of the automated warning
was not independently disclosed by Apple; don't claim Apple admitted an error.

## Exact candidate prior to submission

- App Store version: 0.1.0.
- Associated App Review eligible build before submission: **92.1**.
- Source checkout: `10b9e29f9d730e83a1fbd852fa49b09d83dd155a`.
- Exact signed IPA SHA256:
  `fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`.
- Family Controls Distribution: all three bundle IDs had owner-confirmed
  Assigned status, with App Store Connect support confirmed by owner on the
  applicable detail screenshots.
- No subsequent RC replacement is evidenced in these messages.

## Manual launch gate

Previously confirmed ASC setting: **MANUAL** release, **United States-only**,
Free, iPhone-only, Chinese + English listings, China mainland excluded.

Before a public launch, owner should verify in App Store Connect:
- iOS version 0.1.0 currently shows **Pending Developer Release**
  (or report the exact displayed state if different);
- distribution region still US only and Free;
- current agreements in effect, if ASC flags contracts;
- build remains 92.1 unless portal shows otherwise.

On owner approval of launch timing, use App Store Connect:
Apps → Everwhile → iOS App 0.1.0 → **Release This Version** → Confirm.

Do not initiate release from GitHub or ASC API without explicit owner
authorization. Official Apple guidance:
https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/

Once released, independently verify the US App Store listing and actual
public download availability (Apple allows up to 24 hours), and only then
mark **LIVE_VERIFIED**. Public posting/promo download CTA is a separate decision.

Marketing-video work is parallel and should not delay or force the launch.

## Evidence sensitivity

The owner's messages contain private Apple account/submission identifiers
that are not reproduced in this public repository. No original mailbox
attachments or private screenshots were committed.
