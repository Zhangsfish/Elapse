import XCTest
@testable import ElapseCore

final class PulsePlanTests: XCTestCase {
    func testThresholdGeneration() {
        XCTAssertEqual(PulsePlan.thresholdMinutes, [5, 10, 15, 20, 25, 30])
    }

    func testEventNameRoundTrip() {
        for minutes in PulsePlan.thresholdMinutes {
            let name = PulsePlan.eventName(for: minutes)
            XCTAssertEqual(PulsePlan.minutes(fromEventName: name), minutes)
        }
    }

    func testUnknownEventNamesAreRejected() {
        XCTAssertNil(PulsePlan.minutes(fromEventName: "elapse.threshold.7m"))
        XCTAssertNil(PulsePlan.minutes(fromEventName: "other.threshold.5m"))
        XCTAssertNil(PulsePlan.minutes(fromEventName: "elapse.threshold.5"))
    }

    func testNotificationCopyUsesNamedCumulativeThreshold() {
        XCTAssertEqual(
            PulseNotificationCopy.safeThresholdCopy(minutes: 20),
            PulseNotificationCopy(
                title: "20 minutes",
                body: "Selected apps have reached 20 minutes today."
            )
        )
    }

    func testDuplicateReceiptIsSuppressedWithinSameDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeIntervalSince1970: 1_767_225_600)
        let eventName = PulsePlan.eventName(for: 5)
        let receipt = PulseDeliveryDecision.receiptKey(
            for: eventName,
            date: date,
            calendar: calendar
        )

        XCTAssertFalse(
            PulseDeliveryDecision.shouldRequestNotification(
                eventName: eventName,
                existingReceiptKeys: [receipt],
                date: date,
                calendar: calendar
            )
        )
        XCTAssertTrue(
            PulseDeliveryDecision.shouldRequestNotification(
                eventName: eventName,
                existingReceiptKeys: [],
                date: date,
                calendar: calendar
            )
        )
    }

    func testSelectionFeedbackDistinguishesSaveFailureAndCategoryOnly() {
        XCTAssertEqual(
            FoundationFeedback.selectionMessage(applicationCount: 2, otherCount: 0, saved: true),
            "已保存 2 个 App；重启后请核对数量。"
        )
        XCTAssertEqual(
            FoundationFeedback.selectionMessage(applicationCount: 0, otherCount: 1, saved: true),
            "已保存选择，但本轮仅测试 App；请至少选一个应用，而不只是类别或网站。"
        )
        XCTAssertEqual(
            FoundationFeedback.selectionMessage(applicationCount: 2, otherCount: 0, saved: false),
            "选择未保存；请重试，重启后可能无法保留。"
        )
    }

    func testSafeErrorCodeNeverIncludesLocalizedDescription() {
        let error = NSError(domain: "Private Account Detail", code: 37, userInfo: [
            NSLocalizedDescriptionKey: "Do not display this text",
        ])
        XCTAssertEqual(FoundationFeedback.safeErrorCode(error), "37")
    }
}
