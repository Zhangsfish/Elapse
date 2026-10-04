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

struct PulseThresholdDiagnostic: Codable, Equatable {
    var callbackAt: Date?
    var requestAt: Date?
    var requestStatus: PulseRequestStatus = .notRequested
    var safeErrorCode: String?

    var callbackReceived: Bool { callbackAt != nil }
}

/// Only app-owned experiment and delivery diagnostics live in the shared container.
/// No selected tokens, app identities, or DeviceActivityReport data are stored here.
struct PulseExperimentSnapshot: Codable, Equatable {
    var experimentID: String? = nil
    var generation = 0
    var phase: PulseExperimentPhase = .idle
    var selectedApplicationCount = 0
    var configurationIntervalMinutes = PulsePlan.intervalMinutes
    var plannedEventCount = PulsePlan.thresholdMinutes.count
    var maximumThresholdMinutes = PulsePlan.maximumTestMinutes
    var thresholds: [Int: PulseThresholdDiagnostic] = [:]
    var safeErrorCode: String?
    var staleCallbackCount = 0
    var duplicateCallbackCount = 0
    var staleCompletionCount = 0
    var invalidCallbackCount = 0
    var receiptKeys: Set<String> = []

    init() {}

    // 32.1 stored only the five-minute diagnostic. Decode that on upgrade so
    // an existing App Group file remains readable; new writes use thresholds.
    private enum CodingKeys: String, CodingKey {
        case experimentID, generation, phase, selectedApplicationCount, thresholds
        case configurationIntervalMinutes, plannedEventCount, maximumThresholdMinutes
        case safeErrorCode, staleCallbackCount, duplicateCallbackCount
        case staleCompletionCount, invalidCallbackCount, receiptKeys
        case fiveMinuteCallbackAt, fiveMinuteRequestAt, fiveMinuteRequestStatus
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        experimentID = try values.decodeIfPresent(String.self, forKey: .experimentID)
        generation = try values.decode(Int.self, forKey: .generation)
        phase = try values.decode(PulseExperimentPhase.self, forKey: .phase)
        selectedApplicationCount = try values.decode(Int.self, forKey: .selectedApplicationCount)
        let newPlanKeys = [
            values.contains(.configurationIntervalMinutes),
            values.contains(.plannedEventCount),
            values.contains(.maximumThresholdMinutes),
        ]
        if newPlanKeys.allSatisfy({ !$0 }) {
            // Pre-S01-A snapshots represent the accepted six-event S00 plan.
            configurationIntervalMinutes = PulsePlan.intervalMinutes
            plannedEventCount = PulsePlan.thresholdMinutes.count
            maximumThresholdMinutes = PulsePlan.maximumTestMinutes
        } else {
            guard newPlanKeys.allSatisfy({ $0 }) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .plannedEventCount,
                    in: values,
                    debugDescription: "Incomplete monitoring configuration"
                )
            }
            configurationIntervalMinutes = try values.decode(Int.self, forKey: .configurationIntervalMinutes)
            plannedEventCount = try values.decode(Int.self, forKey: .plannedEventCount)
            maximumThresholdMinutes = try values.decode(Int.self, forKey: .maximumThresholdMinutes)
        }
        if values.contains(.thresholds) {
            thresholds = try values.decode([Int: PulseThresholdDiagnostic].self, forKey: .thresholds)
        } else {
            thresholds = [:]
        }
        safeErrorCode = try values.decodeIfPresent(String.self, forKey: .safeErrorCode)
        staleCallbackCount = try values.decode(Int.self, forKey: .staleCallbackCount)
        duplicateCallbackCount = try values.decode(Int.self, forKey: .duplicateCallbackCount)
        staleCompletionCount = try values.decode(Int.self, forKey: .staleCompletionCount)
        invalidCallbackCount = try values.decode(Int.self, forKey: .invalidCallbackCount)
        receiptKeys = try values.decode(Set<String>.self, forKey: .receiptKeys)
        if !values.contains(.thresholds) {
            let callbackAt = try values.decodeIfPresent(Date.self, forKey: .fiveMinuteCallbackAt)
            let requestAt = try values.decodeIfPresent(Date.self, forKey: .fiveMinuteRequestAt)
            let requestStatus = try values.decode(PulseRequestStatus.self, forKey: .fiveMinuteRequestStatus)
            if callbackAt != nil || requestAt != nil || requestStatus != .notRequested {
                thresholds[5] = PulseThresholdDiagnostic(
                    callbackAt: callbackAt,
                    requestAt: requestAt,
                    requestStatus: requestStatus,
                    safeErrorCode: requestStatus == .failed ? safeErrorCode : nil
                )
            }
        }
        if (phase == .starting || phase == .registered) && experimentID == nil {
            throw DecodingError.dataCorruptedError(
                forKey: .experimentID,
                in: values,
                debugDescription: "Active experiment is missing its identity"
            )
        }
        let dayPlan = DayPulsePlan(intervalMinutes: configurationIntervalMinutes)
        let isLegacyPlan = configurationIntervalMinutes == PulsePlan.intervalMinutes &&
            plannedEventCount == PulsePlan.thresholdMinutes.count &&
            maximumThresholdMinutes == PulsePlan.maximumTestMinutes
        let isDayPlan = dayPlan != nil &&
            plannedEventCount == dayPlan?.eventCount &&
            maximumThresholdMinutes == dayPlan?.maximumThresholdMinutes
        guard isLegacyPlan || isDayPlan else {
            throw DecodingError.dataCorruptedError(
                forKey: .plannedEventCount,
                in: values,
                debugDescription: "Invalid monitoring configuration"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encodeIfPresent(experimentID, forKey: .experimentID)
        try values.encode(generation, forKey: .generation)
        try values.encode(phase, forKey: .phase)
        try values.encode(selectedApplicationCount, forKey: .selectedApplicationCount)
        try values.encode(configurationIntervalMinutes, forKey: .configurationIntervalMinutes)
        try values.encode(plannedEventCount, forKey: .plannedEventCount)
        try values.encode(maximumThresholdMinutes, forKey: .maximumThresholdMinutes)
        try values.encode(thresholds, forKey: .thresholds)
        try values.encodeIfPresent(safeErrorCode, forKey: .safeErrorCode)
        try values.encode(staleCallbackCount, forKey: .staleCallbackCount)
        try values.encode(duplicateCallbackCount, forKey: .duplicateCallbackCount)
        try values.encode(staleCompletionCount, forKey: .staleCompletionCount)
        try values.encode(invalidCallbackCount, forKey: .invalidCallbackCount)
        try values.encode(receiptKeys, forKey: .receiptKeys)
    }

    func diagnostic(for minutes: Int) -> PulseThresholdDiagnostic {
        thresholds[minutes] ?? PulseThresholdDiagnostic()
    }

    var hasReceivedCallback: Bool {
        thresholds.values.contains { $0.callbackReceived }
    }

    var callbackCount: Int { thresholds.values.filter(\.callbackReceived).count }
    var acceptedRequestCount: Int { thresholds.values.filter { $0.requestStatus == .accepted }.count }
    var failedRequestCount: Int { thresholds.values.filter { $0.requestStatus == .failed }.count }

    var mostRecentAcceptedThresholdMinutes: Int? {
        thresholds.filter { $0.value.requestStatus == .accepted }
            .max { left, right in
                (left.value.requestAt ?? .distantPast) < (right.value.requestAt ?? .distantPast)
            }?.key
    }

    /// A plan cursor, not a measurement of current Screen Time usage.
    var nextPlannedThresholdMinutes: Int? {
        let next = (thresholds.keys.max() ?? 0) + configurationIntervalMinutes
        return next <= maximumThresholdMinutes ? next : nil
    }

    var recentThresholdMinutes: [Int] {
        Array(thresholds.sorted {
            ($0.value.callbackAt ?? .distantPast) > ($1.value.callbackAt ?? .distantPast)
        }.prefix(3).map(\.key))
    }

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

    func containsPlannedThreshold(_ minutes: Int) -> Bool {
        minutes >= configurationIntervalMinutes &&
            minutes <= maximumThresholdMinutes &&
            minutes % configurationIntervalMinutes == 0
    }

    mutating func begin(id: String, selectedApplicationCount: Int, plan: DayPulsePlan? = nil) {
        generation += 1
        experimentID = id
        phase = .starting
        self.selectedApplicationCount = selectedApplicationCount
        configurationIntervalMinutes = plan?.intervalMinutes ?? PulsePlan.intervalMinutes
        plannedEventCount = plan?.eventCount ?? PulsePlan.thresholdMinutes.count
        maximumThresholdMinutes = plan?.maximumThresholdMinutes ?? PulsePlan.maximumTestMinutes
        thresholds = [:]
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
        guard let minutes = PulsePlan.minutes(fromEventName: eventName),
              containsPlannedThreshold(minutes) else {
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
        thresholds[minutes] = PulseThresholdDiagnostic(
            callbackAt: date,
            requestAt: nil,
            requestStatus: .submitting,
            safeErrorCode: nil
        )
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
              isCurrentRegistration,
              let minutes = PulsePlan.minutes(fromEventName: eventName),
              containsPlannedThreshold(minutes),
              var diagnostic = thresholds[minutes],
              diagnostic.requestStatus == .submitting else {
            staleCompletionCount += 1
            return
        }
        // Keep the receipt even on failure. A repeated callback must not turn
        // an uncertain asynchronous request into a second visible pulse.
        diagnostic.requestAt = date
        diagnostic.requestStatus = errorCode == nil ? .accepted : .failed
        diagnostic.safeErrorCode = errorCode
        thresholds[minutes] = diagnostic
    }
}
