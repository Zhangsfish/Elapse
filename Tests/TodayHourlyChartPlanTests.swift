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
        XCTAssertEqual(plan.end, calendar.dateInterval(of: .hour, for: now)?.end)
    }

    func testSubminuteBarIsNotRoundedAway() {
        let now = Date()
        let plan = TodayHourlyChartPlan(buckets: [now: 1], now: now)
        XCTAssertEqual(plan.bars.first?.seconds, 1)
        XCTAssertEqual(plan.maximumSeconds, 60)
    }

    func testCurrentHourHasTrailingDomainSpace() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 5, hour: 12, minute: 53))!
        let hourStart = calendar.dateInterval(of: .hour, for: now)!.start
        let plan = TodayHourlyChartPlan(buckets: [hourStart: 90], now: now, calendar: calendar)
        XCTAssertEqual(plan.end, calendar.dateInterval(of: .hour, for: now)!.end)
        XCTAssertGreaterThan(plan.end, now)
        XCTAssertEqual(plan.bars, [TodayHourlyBar(start: hourStart, seconds: 90)])
    }

    func testYAxisProvidesSparseMinuteScaleForOwnerExamples() {
        let now = Date()
        let twentyFive = TodayHourlyChartPlan(buckets: [now: 25 * 60], now: now)
        XCTAssertEqual(twentyFive.maximumSeconds, 30 * 60)
        XCTAssertEqual(twentyFive.yAxisTicks, [0, 15 * 60, 30 * 60])
        let fortyFour = TodayHourlyChartPlan(buckets: [now: 44 * 60], now: now)
        XCTAssertEqual(fortyFour.maximumSeconds, 50 * 60)
        XCTAssertEqual(fortyFour.yAxisTicks, [0, 25 * 60, 50 * 60])
    }

    func testYAxisSmallAndExactBoundariesHaveWholeMinuteLabels() {
        let now = Date()
        for (seconds, expectedCeiling) in [
            (0.0, 60.0), (1, 60), (59, 60), (60, 60),
            (61, 120), (180, 240), (600, 600), (601, 1200), (1800, 1800)
        ] {
            let plan = TodayHourlyChartPlan(buckets: [now: seconds], now: now)
            XCTAssertEqual(plan.maximumSeconds, expectedCeiling)
            XCTAssertTrue((2...3).contains(plan.yAxisTicks.count))
            XCTAssertEqual(plan.yAxisTicks.first, 0)
            XCTAssertEqual(plan.yAxisTicks.last, expectedCeiling)
            XCTAssertTrue(plan.yAxisTicks.allSatisfy { $0.truncatingRemainder(dividingBy: 60) == 0 })
            XCTAssertGreaterThanOrEqual(expectedCeiling, seconds)
        }
    }

    func testYAxisDoesNotClipLongBucketOrChangeActualSeconds() {
        let now = Date()
        let plan = TodayHourlyChartPlan(buckets: [now: 3601], now: now)
        XCTAssertEqual(plan.maximumSeconds, 70 * 60)
        XCTAssertEqual(plan.yAxisTicks, [0, 35 * 60, 70 * 60])
        XCTAssertEqual(plan.bars.first?.seconds, 3601)
    }
}
