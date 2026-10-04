import XCTest
@testable import ElapseCore

final class TodayIntervalTests: XCTestCase {
    func testTodayIntervalEndsAtSuppliedNow() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        let now = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 14, minute: 30))
        )

        let interval = TodayInterval.make(now: now, calendar: calendar)

        XCTAssertEqual(calendar.component(.hour, from: interval.start), 0)
        XCTAssertEqual(calendar.component(.day, from: interval.start), 2)
        XCTAssertEqual(interval.end, now)
        XCTAssertEqual(interval.duration, 14 * 60 * 60 + 30 * 60, accuracy: 0.001)
    }

    func testDSTSpringForwardUsesLocalStartOfDayWithoutFixedDayLength() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let now = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 12))
        )

        let interval = TodayInterval.make(now: now, calendar: calendar)

        XCTAssertEqual(interval.start, calendar.startOfDay(for: now))
        XCTAssertEqual(interval.end, now)
        XCTAssertEqual(calendar.component(.hour, from: interval.start), 0)
        XCTAssertEqual(interval.duration, 11 * 60 * 60, accuracy: 0.001)
    }

    func testDSTFallBackUsesLocalStartOfDayWithoutFixedDayLength() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let now = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 11, day: 1, hour: 12))
        )

        let interval = TodayInterval.make(now: now, calendar: calendar)

        XCTAssertEqual(interval.start, calendar.startOfDay(for: now))
        XCTAssertEqual(interval.end, now)
        XCTAssertEqual(interval.duration, 13 * 60 * 60, accuracy: 0.001)
    }
}
