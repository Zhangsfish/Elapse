import XCTest
@testable import ElapseCore

final class PulsePlanTests: XCTestCase {
    func testThresholdGeneration() {
        XCTAssertEqual(PulsePlan.thresholdMinutes, [5, 10, 15, 20, 25, 30])
    }

    func testProductIntervalsAndFullDayCandidateLadders() throws {
        XCTAssertEqual(DayPulsePlan.defaultIntervalMinutes, 5)
        XCTAssertEqual(DayPulsePlan.supportedIntervals, [5, 10, 15, 30, 60])
        XCTAssertNil(DayPulsePlan(intervalMinutes: 1))
        XCTAssertNil(DayPulsePlan(intervalMinutes: 7))
        for (interval, count, maximum) in [
            (5, 299, 1495), (10, 149, 1490), (15, 99, 1485),
            (30, 49, 1470), (60, 24, 1440),
        ] {
            let plan = try XCTUnwrap(DayPulsePlan(intervalMinutes: interval))
            XCTAssertEqual(plan.eventCount, count)
            XCTAssertEqual(plan.maximumThresholdMinutes, maximum)
            XCTAssertEqual(plan.thresholds.first, interval)
            XCTAssertEqual(plan.thresholds.last, maximum)
            XCTAssertEqual(plan.thresholds.count, count)
            XCTAssertFalse(plan.contains(maximum + interval))
            XCTAssertEqual(plan.thresholdComponents(for: maximum)?.hour, maximum / 60)
            XCTAssertEqual(plan.thresholdComponents(for: maximum)?.minute, maximum % 60)
        }
        // 25h is only a planning ceiling: 23h, 24h and 25h calendar days
        // require later lifecycle/DST validation, not an assumed fixed day.
    }

    func testEventNameRoundTrip() {
        for minutes in [5, 30, 60, 720, 1440, 1495] {
            let name = PulsePlan.eventName(for: minutes)
            XCTAssertEqual(PulsePlan.minutes(fromEventName: name), minutes)
        }
    }

    func testActivityNameCarriesValidatedExperimentIdentity() {
        let id = "6bd15048-58f7-4da0-9738-f5cef9df1d12"
        XCTAssertEqual(PulsePlan.experimentID(fromActivityName: PulsePlan.activityName(for: id)), id)
        XCTAssertNil(PulsePlan.experimentID(fromActivityName: "elapse.daily"))
        XCTAssertNil(PulsePlan.experimentID(fromActivityName: "elapse.experiment.not-a-uuid"))
    }

    func testUnknownEventNamesAreRejected() {
        XCTAssertNil(PulsePlan.minutes(fromEventName: "elapse.threshold.7m"))
        XCTAssertNil(PulsePlan.minutes(fromEventName: "other.threshold.5m"))
        XCTAssertNil(PulsePlan.minutes(fromEventName: "elapse.threshold.5"))
        XCTAssertNil(PulsePlan.minutes(fromEventName: "elapse.threshold.005m"))
        XCTAssertNil(PulsePlan.minutes(fromEventName: "elapse.threshold.1500m"))
    }

    func testNotificationCopyUsesNamedCumulativeThreshold() {
        XCTAssertEqual(
            PulseNotificationCopy.safeThresholdCopy(minutes: 20),
            PulseNotificationCopy(
                title: "20 分钟",
                body: "所选 App 使用已达到本轮的 20 分钟提醒点。"
            )
        )
        XCTAssertFalse(PulseNotificationCopy.safeThresholdCopy(minutes: 20).body.contains("今天"))
    }

    func testReceiptIsScopedToExperimentNotCalendarDay() {
        let eventName = PulsePlan.eventName(for: 5)
        let receipt = PulseDeliveryDecision.receiptKey(
            for: eventName,
            experimentID: "first"
        )
        XCTAssertFalse(
            PulseDeliveryDecision.shouldRequestNotification(
                eventName: eventName,
                experimentID: "first",
                currentExperimentID: "first",
                isActive: true,
                existingReceiptKeys: [receipt]
            )
        )
        XCTAssertTrue(
            PulseDeliveryDecision.shouldRequestNotification(
                eventName: eventName,
                experimentID: "second",
                currentExperimentID: "second",
                isActive: true,
                existingReceiptKeys: [receipt]
            )
        )
        XCTAssertFalse(
            PulseDeliveryDecision.shouldRequestNotification(
                eventName: eventName,
                experimentID: "first",
                currentExperimentID: "second",
                isActive: true,
                existingReceiptKeys: []
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
