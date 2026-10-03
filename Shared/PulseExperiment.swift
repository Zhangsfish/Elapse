import Foundation

enum PulseExperimentPhase: String, Codable {
    case idle
    case starting
    case registered
    case stopped
    case failed
}

enum PulseRequestStatus: String, Codable {
    case notRequested
    case submitting
    case accepted
    case failed
}

enum PulseCallbackDecision: Equatable {
    case request(minutes: Int)
    case duplicate
    case stale
    case invalid
}

/// Only app-owned experiment and delivery diagnostics live in the shared container.
/// No selected tokens, app identities, or DeviceActivityReport data are stored here.
struct PulseExperimentSnapshot: Codable, Equatable {
    var experimentID: String? = nil
    var generation = 0
    var phase: PulseExperimentPhase = .idle
    var selectedApplicationCount = 0
    var fiveMinuteCallbackAt: Date?
    var fiveMinuteRequestAt: Date?
    var fiveMinuteRequestStatus: PulseRequestStatus = .notRequested
    var safeErrorCode: String?
    var staleCallbackCount = 0
    var duplicateCallbackCount = 0
    var staleCompletionCount = 0
    var invalidCallbackCount = 0
    var receiptKeys: Set<String> = []

    var shortID: String {
        guard let experimentID else { return "none" }
        return String(experimentID.prefix(8))
    }

    var isCurrentRegistration: Bool {
        phase == .registered
    }

    var canChangeSelection: Bool {
        phase != .starting && phase != .registered
    }

    mutating func begin(id: String, selectedApplicationCount: Int) {
        generation += 1
        experimentID = id
        phase = .starting
        self.selectedApplicationCount = selectedApplicationCount
        fiveMinuteCallbackAt = nil
        fiveMinuteRequestAt = nil
        fiveMinuteRequestStatus = .notRequested
        safeErrorCode = nil
        staleCallbackCount = 0
        duplicateCallbackCount = 0
        staleCompletionCount = 0
        invalidCallbackCount = 0
        receiptKeys = []
    }

    mutating func markRegistered(id: String) {
        guard experimentID == id, phase == .starting else { return }
        phase = .registered
    }

    mutating func markStopped(id: String) {
        guard experimentID == id else { return }
        phase = .stopped
    }

    mutating func markRegistrationFailed(id: String, errorCode: String) {
        guard experimentID == id else { return }
        phase = .failed
        safeErrorCode = errorCode
    }

    mutating func receive(
        eventName: String,
        activityName: String,
        at date: Date
    ) -> PulseCallbackDecision {
        guard let callbackID = PulsePlan.experimentID(fromActivityName: activityName),
              callbackID == experimentID,
              isCurrentRegistration else {
            staleCallbackCount += 1
            return .stale
        }
        guard let minutes = PulsePlan.minutes(fromEventName: eventName) else {
            invalidCallbackCount += 1
            return .invalid
        }
        guard PulseDeliveryDecision.shouldRequestNotification(
            eventName: eventName,
            experimentID: callbackID,
            currentExperimentID: experimentID,
            isActive: isCurrentRegistration,
            existingReceiptKeys: receiptKeys
        ) else {
            duplicateCallbackCount += 1
            return .duplicate
        }
        receiptKeys.insert(PulseDeliveryDecision.receiptKey(for: eventName, experimentID: callbackID))
        if minutes == 5 {
            fiveMinuteCallbackAt = date
            fiveMinuteRequestStatus = .submitting
            safeErrorCode = nil
        }
        return .request(minutes: minutes)
    }

    mutating func finishRequest(
        eventName: String,
        activityName: String,
        errorCode: String?,
        at date: Date
    ) {
        guard let callbackID = PulsePlan.experimentID(fromActivityName: activityName),
              callbackID == experimentID,
              isCurrentRegistration else {
            staleCompletionCount += 1
            return
        }
        guard let minutes = PulsePlan.minutes(fromEventName: eventName) else { return }
        if errorCode != nil {
            receiptKeys.remove(PulseDeliveryDecision.receiptKey(for: eventName, experimentID: callbackID))
        }
        if minutes == 5 {
            fiveMinuteRequestAt = date
            fiveMinuteRequestStatus = errorCode == nil ? .accepted : .failed
            safeErrorCode = errorCode
        }
    }
}
