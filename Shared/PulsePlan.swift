import Foundation

enum PulsePlan {
    static let intervalMinutes = 5
    static let maximumTestMinutes = 30
    static let eventPrefix = "elapse.threshold."

    static var thresholdMinutes: [Int] {
        Array(stride(from: intervalMinutes, through: maximumTestMinutes, by: intervalMinutes))
    }

    static func eventName(for minutes: Int) -> String {
        "\(eventPrefix)\(minutes)m"
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
            title: "\(minutes) minutes",
            body: "Selected apps have reached \(minutes) minutes today."
        )
    }
}

enum PulseDeliveryDecision {
    static func shouldRequestNotification(
        eventName: String,
        existingReceiptKeys: Set<String>,
        date: Date,
        calendar: Calendar = .current
    ) -> Bool {
        guard PulsePlan.minutes(fromEventName: eventName) != nil else {
            return false
        }
        return !existingReceiptKeys.contains(receiptKey(for: eventName, date: date, calendar: calendar))
    }

    static func receiptKey(
        for eventName: String,
        date: Date,
        calendar: Calendar = .current
    ) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d|%@", year, month, day, eventName)
    }
}
