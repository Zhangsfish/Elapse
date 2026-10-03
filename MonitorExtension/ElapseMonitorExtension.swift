import DeviceActivity
import Foundation
import OSLog
import UserNotifications

final class ElapseMonitorExtension: DeviceActivityMonitor {
    private let logger = Logger(subsystem: "com.zhangsfish.elapse.monitor", category: "callbacks")

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)

        // Without the shared app-owned state, a callback cannot be attributed to
        // the current experiment. Fail closed instead of sending an untracked pulse.
        guard let store = try? PulseExperimentStore.live() else {
            logger.error("Threshold callback ignored: shared diagnostic container unavailable")
            return
        }

        let eventName = event.rawValue
        let activityName = activity.rawValue
        let decision: PulseCallbackDecision
        do {
            decision = try store.update { snapshot in
                snapshot.receive(eventName: eventName, activityName: activityName, at: Date())
            }
        } catch {
            logger.error("Threshold callback ignored: shared diagnostic state unreadable")
            return
        }

        guard case let .request(minutes) = decision,
              let experimentID = PulsePlan.experimentID(fromActivityName: activityName) else {
            logger.notice("Threshold callback classified without notification request")
            return
        }

        let copy = PulseNotificationCopy.safeThresholdCopy(minutes: minutes)
        let content = UNMutableNotificationContent()
        content.title = copy.title
        content.body = copy.body
        let requestID = "elapse.pulse.\(experimentID).\(minutes)m"
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { [logger, store] error in
            let errorCode = error.map { String(($0 as NSError).code) }
            do {
                try store.update { snapshot in
                    snapshot.finishRequest(
                        eventName: eventName,
                        activityName: activityName,
                        errorCode: errorCode,
                        at: Date()
                    )
                }
            } catch {
                logger.error("Notification request result could not be saved to shared diagnostics")
            }
            if let errorCode {
                logger.error("Notification request failed with safe code \(errorCode, privacy: .public)")
            } else {
                logger.notice("Notification request accepted; visible delivery is not asserted")
            }
        }
    }
}
