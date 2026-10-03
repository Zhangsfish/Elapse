import Foundation

enum PulsePlan {
    static let intervalMinutes = 5
    static let maximumTestMinutes = 30
    static let eventPrefix = "elapse.threshold."
    static let activityPrefix = "elapse.experiment."

    static var thresholdMinutes: [Int] {
        Array(stride(from: intervalMinutes, through: maximumTestMinutes, by: intervalMinutes))
    }

    static func eventName(for minutes: Int) -> String {
        "\(eventPrefix)\(minutes)m"
    }

    static func activityName(for experimentID: String) -> String {
        "\(activityPrefix)\(experimentID)"
    }

    static func experimentID(fromActivityName name: String) -> String? {
        guard name.hasPrefix(activityPrefix) else { return nil }
        let value = String(name.dropFirst(activityPrefix.count))
        guard let uuid = UUID(uuidString: value), uuid.uuidString.lowercased() == value else {
            return nil
        }
        return value
    }

    static func minutes(fromEventName name: String) -> Int? {
        guard name.hasPrefix(eventPrefix), name.hasSuffix("m") else {
            return nil
        }

        let start = name.index(name.startIndex, offsetBy: eventPrefix.count)
        let end = name.index(before: name.endIndex)
        guard start < end,
              let minutes = Int(name[start..<end]),
              thresholdMinutes.contains(minutes) else {
            return nil
        }
        return minutes
    }
}

struct PulseNotificationCopy: Equatable {
    let title: String
    let body: String

    static func safeThresholdCopy(minutes: Int) -> PulseNotificationCopy {
        PulseNotificationCopy(
            title: "\(minutes) 分钟",
            body: "所选 App 自本次监控开始后已达到 \(minutes) 分钟。"
        )
    }
}

enum PulseDeliveryDecision {
    static func shouldRequestNotification(
        eventName: String,
        experimentID: String,
        currentExperimentID: String?,
        isActive: Bool,
        existingReceiptKeys: Set<String>
    ) -> Bool {
        guard PulsePlan.minutes(fromEventName: eventName) != nil,
              isActive,
              experimentID == currentExperimentID else {
            return false
        }
        return !existingReceiptKeys.contains(receiptKey(for: eventName, experimentID: experimentID))
    }

    static func receiptKey(
        for eventName: String,
        experimentID: String
    ) -> String {
        "\(experimentID)|\(eventName)"
    }
}
