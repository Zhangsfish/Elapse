import Foundation

enum PulsePlan {
    // Historical S00 finite experiment, retained for old snapshots/tests only.
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
              minutes > 0,
              minutes <= DayPulsePlan.maximumCandidateMinutes,
              minutes % DayPulsePlan.minimumSupportedMinutes == 0,
              eventName(for: minutes) == name else {
            return nil
        }
        return minutes
    }
}

/// A candidate one-activity ladder for the current local day. This is not an
/// assertion that Apple accepts this many events or that rollover is automatic.
struct DayPulsePlan: Equatable {
    static let supportedIntervals = [5, 10, 15, 30, 60]
    static let defaultIntervalMinutes = 5
    static let minimumSupportedMinutes = 5
    static let candidateDayBoundaryMinutes = 25 * 60
    static let maximumCandidateMinutes = candidateDayBoundaryMinutes - minimumSupportedMinutes

    let intervalMinutes: Int

    init?(intervalMinutes: Int) {
        guard Self.supportedIntervals.contains(intervalMinutes) else { return nil }
        self.intervalMinutes = intervalMinutes
    }

    var maximumThresholdMinutes: Int {
        ((Self.candidateDayBoundaryMinutes - 1) / intervalMinutes) * intervalMinutes
    }

    var eventCount: Int { maximumThresholdMinutes / intervalMinutes }

    var thresholds: [Int] {
        Array(stride(from: intervalMinutes, through: maximumThresholdMinutes, by: intervalMinutes))
    }

    func contains(_ minutes: Int) -> Bool {
        minutes >= intervalMinutes &&
            minutes <= maximumThresholdMinutes &&
            minutes % intervalMinutes == 0
    }

    func thresholdComponents(for minutes: Int) -> DateComponents? {
        guard contains(minutes) else { return nil }
        return DateComponents(hour: minutes / 60, minute: minutes % 60)
    }
}

struct PulseNotificationCopy: Equatable {
    let title: String
    let body: String

    static let titleKey = "pulse.title"
    static let bodyKey = "pulse.body"

    static func safeThresholdCopy(
        minutes: Int,
        language: UsageDurationLanguage = .english
    ) -> PulseNotificationCopy {
        switch language {
        case .english:
            return PulseNotificationCopy(
                title: "\(minutes) minutes",
                body: "Selected apps reached the \(minutes)-minute reminder point."
            )
        case .simplifiedChinese:
            return PulseNotificationCopy(
                title: "\(minutes) 分钟",
                body: "所选 App 已达到 \(minutes) 分钟提醒点。"
            )
        }
    }

    static func localizedThresholdCopy(minutes: Int, bundle: Bundle = .main) -> PulseNotificationCopy {
        // Resolve using this process's packaged bundle. Missing resources
        // fall back to safe English, never a raw key or a claim of today total.
        PulseNotificationCopy(
            title: String(format: bundle.localizedString(forKey: titleKey, value: "%ld minutes", table: nil), minutes),
            body: String(format: bundle.localizedString(
                forKey: bodyKey,
                value: "Selected apps reached the %ld-minute reminder point.",
                table: nil
            ), minutes)
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
