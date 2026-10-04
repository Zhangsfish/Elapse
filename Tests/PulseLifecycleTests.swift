import Foundation
import XCTest
@testable import ElapseCore

final class PulseLifecycleTests: XCTestCase {
    private let firstID = "6bd15048-58f7-4da0-9738-f5cef9df1d12"
    private let secondID = "960e56ce-a607-49d4-9e0e-98d81101ce29"
    private let dayStart = Date(timeIntervalSince1970: 1_767_225_600)

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func startedState(interval: Int = 5) throws -> PulseExperimentSnapshot {
        let plan = try XCTUnwrap(DayPulsePlan(intervalMinutes: interval))
        var state = PulseExperimentSnapshot()
        state.begin(
            id: firstID,
            selectedApplicationCount: 2,
            plan: plan,
            at: dayStart,
            repeatsDaily: true
        )
        return state
    }

    private func facts(
        desired: Bool = true,
        approved: Bool = true,
        selected: Bool = true,
        phase: PulseExperimentPhase = .registered,
        recoveryFailed: Bool = false,
        authorizationWasBlocked: Bool = false,
        snapshotRepeats: Bool = true,
        selectionMatches: Bool = true,
        eventsMatchSelection: Bool = true,
        present: Bool = true,
        observedCount: Int? = 299,
        systemRepeats: Bool? = true
    ) -> PulseReconcileFacts {
        PulseReconcileFacts(
            desired: desired,
            authorizationApproved: approved,
            selectedApplicationsAvailable: selected,
            snapshotPhase: phase,
            recoveryFailed: recoveryFailed,
            authorizationWasBlocked: authorizationWasBlocked,
            snapshotRepeatsDaily: snapshotRepeats,
            selectionMatchesSnapshot: selectionMatches,
            registeredEventsMatchSelection: eventsMatchSelection,
            activityPresent: present,
            observedEventCount: observedCount,
            plannedEventCount: 299,
            systemScheduleRepeats: systemRepeats
        )
    }

    func testProductScheduleIsDailyRecurringWithoutAssumingLifecycleDelivery() {
        XCTAssertEqual(PulseDailySchedule.intervalStart.hour, 0)
        XCTAssertEqual(PulseDailySchedule.intervalEnd.hour, 23)
        XCTAssertEqual(PulseDailySchedule.intervalEnd.minute, 59)
        XCTAssertTrue(PulseDailySchedule.repeats)
    }

    func testInitialStartMayArriveBeforeMainAppMarksRegistered() throws {
        var state = try startedState()
        XCTAssertTrue(state.monitoringDesired)
        XCTAssertTrue(state.scheduleRepeatsDaily)
        XCTAssertEqual(state.phase, .starting)
        XCTAssertTrue(state.markIntervalStarted(
            id: firstID, at: dayStart.addingTimeInterval(2), calendar: utcCalendar
        ))
        XCTAssertEqual(state.intervalGeneration, 1)
        XCTAssertEqual(state.intervalAnchor, dayStart)
        XCTAssertEqual(state.lifecycleState, .active)
        state.markRegistered(id: firstID)
        XCTAssertEqual(state.lifecycleState, .active)
        XCTAssertEqual(state.phase, .registered)
    }

    func testDuplicateStartIsIdempotentAndNewCycleResetsOnlyIntervalReceipts() throws {
        var state = try startedState()
        state.markRegistered(id: firstID)
        XCTAssertTrue(state.markIntervalStarted(id: firstID, at: dayStart.addingTimeInterval(2), calendar: utcCalendar))
        let activity = PulsePlan.activityName(for: firstID)
        let event = PulsePlan.eventName(for: 5)
        XCTAssertEqual(state.receive(eventName: event, activityName: activity, at: dayStart.addingTimeInterval(300)), .request(minutes: 5))
        state.finishRequest(eventName: event, activityName: activity, intervalGeneration: 1, errorCode: nil, at: dayStart.addingTimeInterval(301))
        XCTAssertFalse(state.markIntervalStarted(id: firstID, at: dayStart.addingTimeInterval(3600), calendar: utcCalendar))
        XCTAssertEqual(state.intervalGeneration, 1)
        XCTAssertEqual(state.acceptedRequestCount, 1)

        let nextDay = dayStart.addingTimeInterval(86_400)
        XCTAssertTrue(state.markIntervalStarted(id: firstID, at: nextDay.addingTimeInterval(2), calendar: utcCalendar))
        XCTAssertEqual(state.experimentID, firstID)
        XCTAssertEqual(state.intervalGeneration, 2)
        XCTAssertEqual(state.intervalAnchor, nextDay)
        XCTAssertEqual(state.plannedEventCount, 299)
        XCTAssertTrue(state.receiptKeys.isEmpty)
        XCTAssertTrue(state.thresholds.isEmpty)
        state.finishRequest(eventName: event, activityName: activity, intervalGeneration: 1, errorCode: nil, at: nextDay.addingTimeInterval(3))
        XCTAssertEqual(state.staleCompletionCount, 1)
        XCTAssertEqual(state.acceptedRequestCount, 0)
    }

    func testEndRecordsCallbackWithoutInventingNextInterval() throws {
        var state = try startedState()
        state.markRegistered(id: firstID)
        XCTAssertTrue(state.markIntervalStarted(id: firstID, at: dayStart.addingTimeInterval(2), calendar: utcCalendar))
        let end = dayStart.addingTimeInterval(86_401)
        XCTAssertTrue(state.markIntervalEnded(id: firstID, at: end))
        XCTAssertEqual(state.lastIntervalEndAt, end)
        XCTAssertEqual(state.lifecycleState, .ended)
        XCTAssertEqual(state.intervalGeneration, 1)
        XCTAssertFalse(state.markIntervalEnded(id: firstID, at: end.addingTimeInterval(1)))
    }

    func testPrematureFiveFifteenAndHighThresholdFailClosed() throws {
        var state = try startedState()
        state.markRegistered(id: firstID)
        let activity = PulsePlan.activityName(for: firstID)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 5), activityName: activity, at: dayStart.addingTimeInterval(60)), .unanchored)
        XCTAssertEqual(state.unanchoredCallbackCount, 1)
        XCTAssertTrue(state.markIntervalStarted(id: firstID, at: dayStart.addingTimeInterval(65), calendar: utcCalendar))
        for minutes in [5, 15, 720] {
            XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: minutes), activityName: activity, at: dayStart.addingTimeInterval(120)), .premature)
        }
        XCTAssertEqual(state.prematureCallbackCount, 3)
        XCTAssertTrue(state.receiptKeys.isEmpty)
        XCTAssertTrue(state.thresholds.isEmpty)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 5), activityName: activity, at: dayStart.addingTimeInterval(300)), .request(minutes: 5))
        state.finishRequest(eventName: PulsePlan.eventName(for: 5), activityName: activity, intervalGeneration: 1, errorCode: nil, at: dayStart.addingTimeInterval(301))
        XCTAssertEqual(state.acceptedRequestCount, 1)
    }

    func testOldConfigurationStaysStaleAndStoppedIntentBlocksCallbacks() throws {
        var state = try startedState()
        state.markRegistered(id: firstID)
        state.markIntervalStarted(id: firstID, at: dayStart.addingTimeInterval(1), calendar: utcCalendar)
        let oldActivity = PulsePlan.activityName(for: firstID)
        state.begin(id: secondID, selectedApplicationCount: 2, plan: DayPulsePlan(intervalMinutes: 15), at: dayStart.addingTimeInterval(100), repeatsDaily: true)
        state.markRegistered(id: secondID)
        state.markIntervalStarted(id: secondID, at: dayStart.addingTimeInterval(101), calendar: utcCalendar)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 5), activityName: oldActivity, at: dayStart.addingTimeInterval(500)), .stale)
        state.markStopped(id: secondID)
        XCTAssertFalse(state.monitoringDesired)
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 15), activityName: PulsePlan.activityName(for: secondID), at: dayStart.addingTimeInterval(1000)), .stale)
    }

    func testReconcileSeparatesDesiredRegistrationAndAuthorization() {
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(desired: false, present: false)), .idle)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(desired: false)), .stopStrays)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts()), .keepRegistration)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(present: false, observedCount: nil)), .recover(.missingRegistration))
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(observedCount: 98)), .recover(.eventCountMismatch))
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(systemRepeats: false)), .recover(.scheduleMismatch))
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(selectionMatches: false)), .recover(.selectionMismatch))
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(eventsMatchSelection: false)), .recover(.selectionMismatch))
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(snapshotRepeats: false)), .recover(.legacyNonrecurring))
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(approved: false)), .blockedAuthorization)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(selected: false)), .blockedSelection)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(authorizationWasBlocked: true, present: false, observedCount: nil)), .recover(.authorizationReapproved))
    }

    func testSingleRecoveryNewUUIDAndFailedAttemptDoesNotLoopOnRefresh() throws {
        var state = try startedState()
        state.markRegistered(id: firstID)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(present: false, observedCount: nil)), .recover(.missingRegistration))
        state.begin(id: secondID, selectedApplicationCount: 2, plan: DayPulsePlan(intervalMinutes: 5), at: dayStart.addingTimeInterval(10), repeatsDaily: true, recoveryReason: .missingRegistration)
        state.markRegistered(id: secondID)
        XCTAssertNotEqual(state.experimentID, firstID)
        XCTAssertEqual(state.recoveryCount, 1)
        XCTAssertEqual(state.lastRecoveryReason, .missingRegistration)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts()), .keepRegistration)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts()), .keepRegistration)

        state.markRegistrationFailed(id: secondID, errorCode: "registered_event_count_mismatch")
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(phase: state.phase, recoveryFailed: true, observedCount: 98)), .holdFailure)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(phase: state.phase, recoveryFailed: true, observedCount: 98)), .holdFailure)
        XCTAssertEqual(state.recoveryCount, 1)
    }

    func testAuthorizationBlockedPreservesIntentAndReapprovalRequiresNewConfig() throws {
        var state = try startedState()
        state.markRegistered(id: firstID)
        state.markIntervalStarted(id: firstID, at: dayStart.addingTimeInterval(2), calendar: utcCalendar)
        state.markAuthorizationBlocked()
        XCTAssertTrue(state.monitoringDesired)
        XCTAssertTrue(state.authorizationWasBlocked)
        XCTAssertEqual(state.lifecycleState, .blockedAuthorization)
        XCTAssertFalse(state.markIntervalStarted(id: firstID, at: dayStart.addingTimeInterval(86_402), calendar: utcCalendar))
        XCTAssertEqual(state.receive(eventName: PulsePlan.eventName(for: 5), activityName: PulsePlan.activityName(for: firstID), at: dayStart.addingTimeInterval(600)), .unanchored)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(approved: false)), .blockedAuthorization)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(authorizationWasBlocked: true, present: false, observedCount: nil)), .recover(.authorizationReapproved))
        state.begin(id: secondID, selectedApplicationCount: 2, plan: DayPulsePlan(intervalMinutes: 5), at: dayStart.addingTimeInterval(700), repeatsDaily: true, recoveryReason: .authorizationReapproved)
        XCTAssertTrue(state.monitoringDesired)
        XCTAssertFalse(state.authorizationWasBlocked)
        XCTAssertEqual(state.lastRecoveryReason, .authorizationReapproved)

        state.markStopped(id: secondID)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(desired: state.monitoringDesired, present: false, observedCount: nil)), .idle)
    }

    func testLegacySnapshotMigratesToDesiredButNonrecurringAndPartialNewKeysFailClosed() throws {
        let legacy = """
        {"experimentID":"\(firstID)","generation":1,"phase":"registered","selectedApplicationCount":2,
         "configurationIntervalMinutes":5,"plannedEventCount":299,"maximumThresholdMinutes":1495,
         "thresholds":{},"receiptKeys":[],"staleCallbackCount":0,"duplicateCallbackCount":0,
         "staleCompletionCount":0,"invalidCallbackCount":0}
        """
        let state = try JSONDecoder().decode(PulseExperimentSnapshot.self, from: Data(legacy.utf8))
        XCTAssertTrue(state.monitoringDesired)
        XCTAssertFalse(state.scheduleRepeatsDaily)
        XCTAssertEqual(state.intervalGeneration, 0)
        XCTAssertEqual(PulseReconciliationPolicy.decide(facts(snapshotRepeats: state.scheduleRepeatsDaily)), .recover(.legacyNonrecurring))
        let roundTrip = try JSONDecoder().decode(PulseExperimentSnapshot.self, from: JSONEncoder().encode(state))
        XCTAssertEqual(roundTrip, state)
        let partial = legacy.replacingOccurrences(of: "\"thresholds\":{}", with: "\"monitoringDesired\":true,\"thresholds\":{}")
        XCTAssertThrowsError(try JSONDecoder().decode(PulseExperimentSnapshot.self, from: Data(partial.utf8)))
    }
}
