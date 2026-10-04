import Foundation
import XCTest
@testable import ElapseCore

final class PulseExperimentTests: XCTestCase {
    private let firstID = "6bd15048-58f7-4da0-9738-f5cef9df1d12"
    private let secondID = "960e56ce-a607-49d4-9e0e-98d81101ce29"
    private let callbackDate = Date(timeIntervalSince1970: 1_767_225_600)

    func testNewExperimentIsDistinctAndCannotReuseOldReceipt() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let event = PulsePlan.eventName(for: 5)
        XCTAssertEqual(state.receive(eventName: event, activityName: PulsePlan.activityName(for: firstID), at: callbackDate), .request(minutes: 5))
        state.finishRequest(eventName: event, activityName: PulsePlan.activityName(for: firstID), errorCode: nil, at: callbackDate)
        XCTAssertEqual(state.diagnostic(for: 5).requestStatus, .accepted)

        state.markStopped(id: firstID)
        state.begin(id: secondID, selectedApplicationCount: 2)
        state.markRegistered(id: secondID)
        XCTAssertEqual(state.generation, 2)
        XCTAssertNil(state.diagnostic(for: 5).callbackAt)
        XCTAssertEqual(state.diagnostic(for: 5).requestStatus, .notRequested)
        XCTAssertEqual(state.receive(eventName: event, activityName: PulsePlan.activityName(for: secondID), at: callbackDate), .request(minutes: 5))
    }

    func testFullDayHighThresholdReceiptsAndNewIntervalIdentity() throws {
        let five = try XCTUnwrap(DayPulsePlan(intervalMinutes: 5))
        let fifteen = try XCTUnwrap(DayPulsePlan(intervalMinutes: 15))
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2, plan: five)
        state.markRegistered(id: firstID)
        XCTAssertEqual(state.configurationIntervalMinutes, 5)
        XCTAssertEqual(state.plannedEventCount, 299)
        XCTAssertEqual(state.maximumThresholdMinutes, 1495)
        let firstActivity = PulsePlan.activityName(for: firstID)
        for minutes in [5, 720, 1495] {
            let event = PulsePlan.eventName(for: minutes)
            let receivedAt = callbackDate.addingTimeInterval(TimeInterval(minutes))
            XCTAssertEqual(state.receive(eventName: event, activityName: firstActivity, at: receivedAt), .request(minutes: minutes))
            state.finishRequest(eventName: event, activityName: firstActivity, errorCode: nil, at: receivedAt)
        }
        XCTAssertEqual(state.receiptKeys.count, 3)
        XCTAssertEqual(state.callbackCount, 3)
        XCTAssertEqual(state.acceptedRequestCount, 3)
        XCTAssertEqual(state.mostRecentAcceptedThresholdMinutes, 1495)
        XCTAssertNil(state.nextPlannedThresholdMinutes)
        XCTAssertEqual(state.recentThresholdMinutes.count, 3)
        state.markStopped(id: firstID)
        state.begin(id: secondID, selectedApplicationCount: 2, plan: fifteen)
        state.markRegistered(id: secondID)
        XCTAssertEqual(state.configurationIntervalMinutes, 15)
        XCTAssertEqual(state.plannedEventCount, 99)
        XCTAssertEqual(state.maximumThresholdMinutes, 1485)
        XCTAssertTrue(state.receiptKeys.isEmpty)
        XCTAssertEqual(state.callbackCount, 0)
        XCTAssertEqual(state.nextPlannedThresholdMinutes, 15)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 15), activityName: firstActivity, at: callbackDate), .stale)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 10), activityName: PulsePlan.activityName(for: secondID), at: callbackDate), .invalid)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 15), activityName: PulsePlan.activityName(for: secondID), at: callbackDate), .request(minutes: 15))
        state.finishRequest(eventName: PulsePlan.eventName(for: 1495), activityName: firstActivity, errorCode: nil, at: callbackDate)
        XCTAssertEqual(state.staleCompletionCount, 1)
    }

    func testFullDaySnapshotPersistenceAndIncompleteConfigFailsClosed() throws {
        let plan = try XCTUnwrap(DayPulsePlan(intervalMinutes: 60))
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2, plan: plan)
        state.markRegistered(id: firstID)
        let encoded = try JSONEncoder().encode(state)
        XCTAssertEqual(try JSONDecoder().decode(PulseExperimentSnapshot.self, from: encoded), state)
        let incomplete = """
        {"experimentID":"\(firstID)","generation":1,"phase":"registered","selectedApplicationCount":2,
         "configurationIntervalMinutes":60,"thresholds":{},"receiptKeys":[],
         "staleCallbackCount":0,"duplicateCallbackCount":0,"staleCompletionCount":0,"invalidCallbackCount":0}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(PulseExperimentSnapshot.self, from: Data(incomplete.utf8)))
    }

    func testDuplicateAndStaleCallbacksAreSeparated() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let event = PulsePlan.eventName(for: 5)
        let firstName = PulsePlan.activityName(for: firstID)
        XCTAssertEqual(state.receive(eventName: event, activityName: firstName, at: callbackDate), .request(minutes: 5))
        XCTAssertEqual(state.receive(eventName: event, activityName: firstName, at: callbackDate), .duplicate)
        XCTAssertEqual(state.duplicateCallbackCount, 1)
        state.markStopped(id: firstID)
        XCTAssertEqual(state.receive(eventName: event, activityName: firstName, at: callbackDate), .stale)
        state.begin(id: secondID, selectedApplicationCount: 2)
        state.markRegistered(id: secondID)
        XCTAssertEqual(state.receive(eventName: event, activityName: firstName, at: callbackDate), .stale)
        XCTAssertEqual(state.staleCallbackCount, 1)
        XCTAssertNil(state.diagnostic(for: 5).callbackAt)
    }

    func testRequestFailureIsVisibleOnlyForItsThresholdAndDoesNotRetry() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let event = PulsePlan.eventName(for: 5)
        let name = PulsePlan.activityName(for: firstID)
        XCTAssertEqual(state.receive(eventName: event, activityName: name, at: callbackDate), .request(minutes: 5))
        XCTAssertEqual(state.diagnostic(for: 5).requestStatus, .submitting)
        state.finishRequest(eventName: event, activityName: name, errorCode: "37", at: callbackDate)
        XCTAssertEqual(state.diagnostic(for: 5).requestStatus, .failed)
        XCTAssertEqual(state.diagnostic(for: 5).safeErrorCode, "37")
        XCTAssertEqual(state.diagnostic(for: 10).requestStatus, .notRequested)
        XCTAssertEqual(state.receive(eventName: event, activityName: name, at: callbackDate), .duplicate)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 10), activityName: name, at: callbackDate), .request(minutes: 10))
        XCTAssertEqual(state.diagnostic(for: 5).requestStatus, .failed)
    }

    func testAllSixThresholdsHaveIndependentReceiptsAndActualArrivalTimes() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let activity = PulsePlan.activityName(for: firstID)
        for (index, minutes) in PulsePlan.thresholdMinutes.enumerated() {
            let event = PulsePlan.eventName(for: minutes)
            let receivedAt = callbackDate.addingTimeInterval(Double(index * 300 + 17))
            XCTAssertEqual(state.receive(eventName: event, activityName: activity, at: receivedAt), .request(minutes: minutes))
            XCTAssertEqual(state.diagnostic(for: minutes).callbackAt, receivedAt)
            XCTAssertEqual(state.diagnostic(for: minutes).requestStatus, .submitting)
            XCTAssertEqual(state.receive(eventName: event, activityName: activity, at: receivedAt), .duplicate)
            state.finishRequest(eventName: event, activityName: activity, errorCode: nil, at: receivedAt.addingTimeInterval(1))
            XCTAssertEqual(state.diagnostic(for: minutes).requestStatus, .accepted)
        }
        XCTAssertEqual(state.receiptKeys.count, 6)
        XCTAssertEqual(state.duplicateCallbackCount, 6)
    }

    func testOutOfOrderCallbacksKeepTheirOwnIdentityAndArrivalTime() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let activity = PulsePlan.activityName(for: firstID)
        let twentyAt = callbackDate
        let tenAt = callbackDate.addingTimeInterval(20)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 20), activityName: activity, at: twentyAt), .request(minutes: 20))
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 10), activityName: activity, at: tenAt), .request(minutes: 10))
        XCTAssertEqual(state.diagnostic(for: 20).callbackAt, twentyAt)
        XCTAssertEqual(state.diagnostic(for: 10).callbackAt, tenAt)
        XCTAssertEqual(state.diagnostic(for: 15).requestStatus, .notRequested)
    }

    func testStoppedFailedOldAndInvalidCallbacksNeverRequest() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let activity = PulsePlan.activityName(for: firstID)
        XCTAssertEqual(state.receive(eventName: "invalid", activityName: activity, at: callbackDate), .invalid)
        XCTAssertEqual(state.invalidCallbackCount, 1)
        XCTAssertTrue(state.receiptKeys.isEmpty)
        state.markStopped(id: firstID)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 10), activityName: activity, at: callbackDate), .stale)
        state.begin(id: secondID, selectedApplicationCount: 2)
        state.markRegistered(id: secondID)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 15), activityName: activity, at: callbackDate), .stale)
        state.markRegistrationFailed(id: secondID, errorCode: "37")
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 20), activityName: PulsePlan.activityName(for: secondID), at: callbackDate), .stale)
        XCTAssertTrue(state.receiptKeys.isEmpty)
    }

    func testLateOldCompletionCannotChangeNewExperiment() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let event = PulsePlan.eventName(for: 25)
        let oldActivity = PulsePlan.activityName(for: firstID)
        XCTAssertEqual(state.receive(eventName: event, activityName: oldActivity, at: callbackDate), .request(minutes: 25))
        state.markStopped(id: firstID)
        state.begin(id: secondID, selectedApplicationCount: 2)
        state.markRegistered(id: secondID)
        state.finishRequest(eventName: event, activityName: oldActivity, errorCode: nil, at: callbackDate)
        XCTAssertEqual(state.staleCompletionCount, 1)
        XCTAssertEqual(state.diagnostic(for: 25).requestStatus, .notRequested)
        XCTAssertEqual(state.receive(eventName: event, activityName: PulsePlan.activityName(for: secondID), at: callbackDate), .request(minutes: 25))
    }

    func testRepeatedCompletionCannotOverwriteAcceptedRequest() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let event = PulsePlan.eventName(for: 30)
        let activity = PulsePlan.activityName(for: firstID)
        XCTAssertEqual(state.receive(eventName: event, activityName: activity, at: callbackDate), .request(minutes: 30))
        state.finishRequest(eventName: event, activityName: activity, errorCode: nil, at: callbackDate)
        state.finishRequest(eventName: event, activityName: activity, errorCode: "37", at: callbackDate.addingTimeInterval(1))
        XCTAssertEqual(state.diagnostic(for: 30).requestStatus, .accepted)
        XCTAssertEqual(state.staleCompletionCount, 1)
        state.markStopped(id: firstID)
        state.finishRequest(eventName: event, activityName: activity, errorCode: nil, at: callbackDate.addingTimeInterval(2))
        XCTAssertEqual(state.staleCompletionCount, 2)
    }

    func testLegacyFiveMinuteStoreMigratesWithoutLosingReadableState() throws {
        let legacy = """
        {"experimentID":"\(firstID)","generation":1,"phase":"registered", "selectedApplicationCount":2,
         "fiveMinuteRequestStatus":"accepted","receiptKeys":[],
         "staleCallbackCount":0,"duplicateCallbackCount":0,"staleCompletionCount":0,"invalidCallbackCount":0}
        """
        let state = try JSONDecoder().decode(PulseExperimentSnapshot.self, from: Data(legacy.utf8))
        XCTAssertEqual(state.diagnostic(for: 5).requestStatus, .accepted)
        XCTAssertEqual(state.diagnostic(for: 10).requestStatus, .notRequested)
        let encoded = try JSONEncoder().encode(state)
        let roundTrip = try JSONDecoder().decode(PulseExperimentSnapshot.self, from: encoded)
        XCTAssertEqual(roundTrip, state)
    }

    func testSyntacticallyValidButIncompleteStateFailsClosed() {
        let incomplete = """
        {"experimentID":"\(firstID)","generation":1,"phase":"registered","selectedApplicationCount":2,
         "thresholds":{},"staleCallbackCount":0,"duplicateCallbackCount":0,
         "staleCompletionCount":0,"invalidCallbackCount":0}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(PulseExperimentSnapshot.self, from: Data(incomplete.utf8)))
    }

    func testSelectionIsFrozenOnlyDuringCurrentRegistration() {
        var state = PulseExperimentSnapshot()
        XCTAssertTrue(state.canChangeSelection)
        state.begin(id: firstID, selectedApplicationCount: 2)
        XCTAssertFalse(state.canChangeSelection)
        state.markRegistered(id: firstID)
        XCTAssertFalse(state.canChangeSelection)
        state.markStopped(id: firstID)
        XCTAssertTrue(state.canChangeSelection)
    }

    func testStoreSurvivesNewInstanceAndCorruptionFailsClosed() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let first = try PulseExperimentStore(directory: directory)
        try first.update {
            $0.begin(id: firstID, selectedApplicationCount: 2)
            $0.markRegistered(id: firstID)
            _ = $0.receive(
                eventName: PulsePlan.eventName(for: 30),
                activityName: PulsePlan.activityName(for: firstID),
                at: callbackDate
            )
        }
        let second = try PulseExperimentStore(directory: directory)
        let restored = try second.read()
        XCTAssertEqual(restored.experimentID, firstID)
        XCTAssertEqual(restored.selectedApplicationCount, 2)
        XCTAssertEqual(restored.phase, .registered)
        XCTAssertEqual(restored.diagnostic(for: 30).callbackAt, callbackDate)
        XCTAssertEqual(restored.diagnostic(for: 30).requestStatus, .submitting)

        try Data("corrupt".utf8).write(to: directory.appendingPathComponent("experiment.json"))
        XCTAssertThrowsError(try second.read())
    }
}
