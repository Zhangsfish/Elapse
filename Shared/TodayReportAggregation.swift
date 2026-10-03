import Foundation

// Pure arithmetic only. Protected DeviceActivity data is read and rendered solely
// by the report extension; this helper never persists or exports usage.
struct TodayReportAggregation<Token: Hashable> {
    private(set) var byApplication: [Token: TimeInterval] = [:]
    private(set) var byHour: [Date: TimeInterval] = [:]

    mutating func add(application: Token, duration: TimeInterval, hourStart: Date) {
        guard duration.isFinite, duration > 0 else { return }
        byApplication[application, default: 0] += duration
        byHour[hourStart, default: 0] += duration
    }

    var totalDuration: TimeInterval {
        byApplication.values.reduce(0, +)
    }
}

enum TodayReportState: Equatable {
    case content
    case zeroUsage
    case unavailable

    static func classify(
        deviceRecordCount: Int,
        isCurrentIPhone: Bool,
        hasUnattributedActivity: Bool,
        totalDuration: TimeInterval
    ) -> Self {
        guard deviceRecordCount == 1, isCurrentIPhone, !hasUnattributedActivity else {
            return .unavailable
        }
        return totalDuration > 0 ? .content : .zeroUsage
    }
}
