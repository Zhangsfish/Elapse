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
        XCTAssertEqual(state.fiveMinuteRequestStatus, .accepted)

        state.markStopped(id: firstID)
        state.begin(id: secondID, selectedApplicationCount: 2)
        state.markRegistered(id: secondID)
        XCTAssertEqual(state.generation, 2)
        XCTAssertNil(state.fiveMinuteCallbackAt)
        XCTAssertEqual(state.fiveMinuteRequestStatus, .notRequested)
        XCTAssertEqual(state.receive(eventName: event, activityName: PulsePlan.activityName(for: secondID), at: callbackDate), .request(minutes: 5))
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
        XCTAssertNil(state.fiveMinuteCallbackAt)
    }

    func testRequestFailureIsVisibleAndAllowsRetry() {
        var state = PulseExperimentSnapshot()
        state.begin(id: firstID, selectedApplicationCount: 2)
        state.markRegistered(id: firstID)
        let event = PulsePlan.eventName(for: 5)
        let name = PulsePlan.activityName(for: firstID)
        XCTAssertEqual(state.receive(eventName: event, activityName: name, at: callbackDate), .request(minutes: 5))
        XCTAssertEqual(state.fiveMinuteRequestStatus, .submitting)
        state.finishRequest(eventName: event, activityName: name, errorCode: "37", at: callbackDate)
        XCTAssertEqual(state.fiveMinuteRequestStatus, .failed)
        XCTAssertEqual(state.safeErrorCode, "37")
        XCTAssertEqual(state.receive(eventName: event, activityName: name, at: callbackDate), .request(minutes: 5))
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
        try first.update { $0.begin(id: firstID, selectedApplicationCount: 2) }
        let second = try PulseExperimentStore(directory: directory)
        let restored = try second.read()
        XCTAssertEqual(restored.experimentID, firstID)
        XCTAssertEqual(restored.selectedApplicationCount, 2)
        XCTAssertEqual(restored.phase, .starting)

        try Data("corrupt".utf8).write(to: directory.appendingPathComponent("experiment.json"))
        XCTAssertThrowsError(try second.read())
    }
}
