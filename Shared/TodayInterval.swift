import Foundation

enum TodayInterval {
    static func make(now: Date = Date(), calendar: Calendar = .current) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        return DateInterval(start: start, end: now)
    }
}
