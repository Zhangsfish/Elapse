import Foundation
import XCTest
@testable import ElapseCore

final class TodayHourlyChartPlanTests: XCTestCase {
    func testOnlyObservedPositiveHoursAndTrueSeconds() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5, hour: 12))!
        let first = calendar.date(byAdding: .hour, value: 1, to: calendar.startOfDay(for: now))!
        let second = calendar.date(byAdding: .hour, value: 10, to: calendar.startOfDay(for: now))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: first)!
        let plan = TodayHourlyChartPlan(buckets: [second: 30, first: 120, yesterday: 90, now: 0], now: now, calendar: calendar)
        XCTAssertEqual(plan.bars, [TodayHourlyBar(start: first, seconds: 120), TodayHourlyBar(start: second, seconds: 30)])
        XCTAssertEqual(plan.maximumSeconds, 120)
        XCTAssertEqual(plan.start, calendar.startOfDay(for: now))
    }

    func testSubminuteBarIsNotRoundedAway() {
        let now = Date()
        let plan = TodayHourlyChartPlan(buckets: [now: 1], now: now)
        XCTAssertEqual(plan.bars.first?.seconds, 1)
        XCTAssertEqual(plan.maximumSeconds, 60)
    }
}
