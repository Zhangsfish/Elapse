import DeviceActivity
import Foundation
import OSLog
import UserNotifications

final class ElapseMonitorExtension: DeviceActivityMonitor {
    private let logger = Logger(subsystem: "com.zhangsfish.elapse.monitor", category: "callbacks")
    private let receiptStore = PulseReceiptStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        logger.notice("Monitor interval started: \(activity.rawValue, privacy: .public) at \(Date().timeIntervalSince1970, privacy: .public)")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        logger.notice("Monitor interval ended: \(activity.rawValue, privacy: .public) at \(Date().timeIntervalSince1970, privacy: .public)")
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        let receivedAt = Date()
        logger.notice("Threshold callback event=\(event.rawValue, privacy: .public) activity=\(activity.rawValue, privacy: .public) receivedAt=\(receivedAt.timeIntervalSince1970, privacy: .public)")

        guard let minutes = PulsePlan.minutes(fromEventName: event.rawValue) else {
            logger.error("Ignoring unknown threshold event: \(event.rawValue, privacy: .public)")
            return
        }
        guard receiptStore.reserve(eventName: event.rawValue, at: receivedAt) else {
            logger.notice("Suppressing duplicate threshold callback: \(event.rawValue, privacy: .public)")
            return
        }

        let copy = PulseNotificationCopy.safeThresholdCopy(minutes: minutes)
        let content = UNMutableNotificationContent()
        content.title = copy.title
        content.body = copy.body

        let receiptKey = PulseDeliveryDecision.receiptKey(for: event.rawValue, date: receivedAt)
        let request = UNNotificationRequest(identifier: receiptKey, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { [logger, receiptStore] error in
            if let error {
                receiptStore.release(eventName: event.rawValue, at: receivedAt)
                logger.error("Notification request failed event=\(event.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)")
            } else {
                logger.notice("Notification request accepted event=\(event.rawValue, privacy: .public) thresholdMinutes=\(minutes, privacy: .public); visible delivery is not asserted")
            }
        }
    }
}

private final class PulseReceiptStore {
    private let defaults: UserDefaults
    private let key = "elapse.monitor.receipts"
    private let lock = NSLock()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func reserve(eventName: String, at date: Date) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        var receipts = Set(defaults.stringArray(forKey: key) ?? [])
        guard PulseDeliveryDecision.shouldRequestNotification(
            eventName: eventName,
            existingReceiptKeys: receipts,
            date: date
        ) else {
            return false
        }

        let receiptKey = PulseDeliveryDecision.receiptKey(for: eventName, date: date)
        let dayPrefix = String(receiptKey.prefix(10))
        receipts = Set(receipts.filter { $0.hasPrefix(dayPrefix) })
        receipts.insert(receiptKey)
        defaults.set(Array(receipts).sorted(), forKey: key)
        return true
    }

    func release(eventName: String, at date: Date) {
        lock.lock()
        defer { lock.unlock() }

        var receipts = Set(defaults.stringArray(forKey: key) ?? [])
        receipts.remove(PulseDeliveryDecision.receiptKey(for: eventName, date: date))
        defaults.set(Array(receipts).sorted(), forKey: key)
    }
}
