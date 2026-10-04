import Foundation
import XCTest
@testable import ElapseCore

final class TodayReportAggregationTests: XCTestCase {
    func testRepeatedApplicationAndHourSumWithoutSegmentScreenOnDuration() {
        var summary = TodayReportAggregation<String>()
        let firstHour = Date(timeIntervalSince1970: 1_000)
        let secondHour = Date(timeIntervalSince1970: 4_600)

        summary.add(application: "opaque-a", duration: 120, hourStart: firstHour)
        summary.add(application: "opaque-b", duration: 60, hourStart: firstHour)
        summary.add(application: "opaque-a", duration: 180, hourStart: secondHour)

        XCTAssertEqual(summary.byApplication["opaque-a"], 300)
        XCTAssertEqual(summary.byApplication["opaque-b"], 60)
        XCTAssertEqual(summary.totalDuration, 360)
        XCTAssertEqual(summary.byHour[firstHour], 180)
        XCTAssertEqual(summary.byHour[secondHour], 180)
    }

    func testZeroInvalidAndUnavailableStates() {
        var summary = TodayReportAggregation<String>()
        summary.add(application: "opaque", duration: 0, hourStart: Date())
        summary.add(application: "opaque", duration: -1, hourStart: Date())
        XCTAssertEqual(summary.totalDuration, 0)
        XCTAssertEqual(TodayReportState.classify(deviceRecordCount: 1, isCurrentIPhone: true, hasUnattributedActivity: false, totalDuration: 0), .zeroUsage)
        XCTAssertEqual(TodayReportState.classify(deviceRecordCount: 0, isCurrentIPhone: false, hasUnattributedActivity: false, totalDuration: 0), .unavailable)
        XCTAssertEqual(TodayReportState.classify(deviceRecordCount: 2, isCurrentIPhone: true, hasUnattributedActivity: false, totalDuration: 300), .unavailable)
        XCTAssertEqual(TodayReportState.classify(deviceRecordCount: 1, isCurrentIPhone: false, hasUnattributedActivity: false, totalDuration: 300), .unavailable)
        XCTAssertEqual(TodayReportState.classify(deviceRecordCount: 1, isCurrentIPhone: true, hasUnattributedActivity: true, totalDuration: 300), .unavailable)
        XCTAssertEqual(TodayReportState.classify(deviceRecordCount: 1, isCurrentIPhone: true, hasUnattributedActivity: false, totalDuration: 300), .content)
    }
}
