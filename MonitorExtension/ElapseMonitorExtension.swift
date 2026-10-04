import DeviceActivity
import Foundation
import OSLog
import UserNotifications

final class ElapseMonitorExtension: DeviceActivityMonitor {
    private let logger = Logger(subsystem: "com.zhangsfish.elapse.monitor", category: "callbacks")

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard let id = PulsePlan.experimentID(fromActivityName: activity.rawValue),
              let store = try? PulseExperimentStore.live() else { return }
        do {
            let accepted = try store.update { snapshot in
                snapshot.markIntervalStarted(id: id, at: Date())
            }
            logger.notice("Interval start classified; new generation=\(accepted, privacy: .public)")
        } catch {
            logger.error("Interval start not recorded: shared state unavailable")
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard let id = PulsePlan.experimentID(fromActivityName: activity.rawValue),
              let store = try? PulseExperimentStore.live() else { return }
        do {
            let accepted = try store.update { snapshot in
                snapshot.markIntervalEnded(id: id, at: Date())
            }
            logger.notice("Interval end classified; current generation ended=\(accepted, privacy: .public)")
        } catch {
            logger.error("Interval end not recorded: shared state unavailable")
        }
    }

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
        let intervalGeneration: Int
        do {
            (decision, intervalGeneration) = try store.update { snapshot in
                let result = snapshot.receive(eventName: eventName, activityName: activityName, at: Date())
                return (result, snapshot.intervalGeneration)
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
        let requestID = "elapse.pulse.\(experimentID).cycle\(intervalGeneration).\(minutes)m"
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { [logger, store] error in
            let errorCode = error.map { String(($0 as NSError).code) }
            do {
                try store.update { snapshot in
                    snapshot.finishRequest(
                        eventName: eventName,
                        activityName: activityName,
                        intervalGeneration: intervalGeneration,
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
