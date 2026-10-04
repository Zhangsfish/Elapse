import Foundation

enum PulseLifecycleState: String, Codable {
    case waitingForStart
    case active
    case ended
    case blockedAuthorization
    case stopped
    case registrationFailed
}

enum PulseRecoveryReason: String, Codable {
    case legacyNonrecurring
    case missingRegistration
    case eventCountMismatch
    case scheduleMismatch
    case selectionMismatch
    case authorizationReapproved
}

enum PulseReconcileAction: Equatable {
    case idle
    case stopStrays
    case blockedAuthorization
    case blockedSelection
    case keepRegistration
    case recover(PulseRecoveryReason)
    case holdFailure
}

struct PulseReconcileFacts {
    let desired: Bool
    let authorizationApproved: Bool
    let selectedApplicationsAvailable: Bool
    let snapshotPhase: PulseExperimentPhase
    let recoveryFailed: Bool
    let authorizationWasBlocked: Bool
    let snapshotRepeatsDaily: Bool
    let selectionMatchesSnapshot: Bool
    let registeredEventsMatchSelection: Bool
    let activityPresent: Bool
    let observedEventCount: Int?
    let plannedEventCount: Int
    let systemScheduleRepeats: Bool?
}

enum PulseReconciliationPolicy {
    static func decide(_ facts: PulseReconcileFacts) -> PulseReconcileAction {
        guard facts.desired else {
            return facts.activityPresent ? .stopStrays : .idle
        }
        guard facts.authorizationApproved else { return .blockedAuthorization }
        guard facts.selectedApplicationsAvailable else { return .blockedSelection }
        guard !facts.recoveryFailed && facts.snapshotPhase != .failed else { return .holdFailure }
        if facts.authorizationWasBlocked { return .recover(.authorizationReapproved) }
        if facts.snapshotPhase == .idle || facts.snapshotPhase == .stopped {
            return .recover(.missingRegistration)
        }
        if !facts.snapshotRepeatsDaily { return .recover(.legacyNonrecurring) }
        if !facts.selectionMatchesSnapshot { return .recover(.selectionMismatch) }
        if !facts.activityPresent { return .recover(.missingRegistration) }
        if facts.observedEventCount != facts.plannedEventCount {
            return .recover(.eventCountMismatch)
        }
        if !facts.registeredEventsMatchSelection { return .recover(.selectionMismatch) }
        if facts.systemScheduleRepeats != true { return .recover(.scheduleMismatch) }
        return .keepRegistration
    }
}

/// Pure values used by the iOS DeviceActivitySchedule builder. The repeated
/// registration is not evidence that intervalDidStart ran for the current day.
enum PulseDailySchedule {
    static let intervalStart = DateComponents(hour: 0, minute: 0, second: 0)
    static let intervalEnd = DateComponents(hour: 23, minute: 59, second: 59)
    static let repeats = true
}

enum PulseCycle {
    static func key(for date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)@\(calendar.timeZone.identifier)"
    }

    static func anchor(
        for intervalCallbackAt: Date,
        registrationRequestedAt: Date?,
        calendar: Calendar = .current
    ) -> Date {
        let dayStart = calendar.startOfDay(for: intervalCallbackAt)
        guard let registrationRequestedAt,
              registrationRequestedAt > dayStart,
              registrationRequestedAt <= intervalCallbackAt else {
            return dayStart
        }
        return registrationRequestedAt
    }
}
