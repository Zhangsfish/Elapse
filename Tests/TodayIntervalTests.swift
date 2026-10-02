import XCTest
@testable import ElapseCore

final class TodayIntervalTests: XCTestCase {
    func testTodayIntervalUsesCalendarDayBoundaries() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        let now = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 14, minute: 30))
        )

        let interval = TodayInterval.make(now: now, calendar: calendar)

        XCTAssertEqual(calendar.component(.hour, from: interval.start), 0)
        XCTAssertEqual(calendar.component(.day, from: interval.start), 2)
        XCTAssertEqual(calendar.component(.day, from: interval.end), 3)
        XCTAssertEqual(interval.duration, 24 * 60 * 60, accuracy: 0.001)
    }
}
