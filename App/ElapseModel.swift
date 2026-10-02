import DeviceActivity
import FamilyControls
import Foundation
import OSLog
import UserNotifications

@MainActor
final class ElapseModel: ObservableObject {
    @Published var selection: FamilyActivitySelection {
        didSet {
            persistSelection()
            statusMessage = nil
        }
    }
    @Published private(set) var authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @Published private(set) var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var isMonitoring = false
    @Published var statusMessage: String?

    private let center = DeviceActivityCenter()
    private let logger = Logger(subsystem: "com.zhangsfish.elapse", category: "setup")
    private let selectionKey = "elapse.familyActivitySelection"

    init() {
        selection = Self.loadSelection(key: selectionKey)
        isMonitoring = center.activities.contains(.elapseDaily)
    }

    var authorizationDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Denied"
        case .approved:
            return "Authorized"
        @unknown default:
            return "Authorized (additional data access)"
        }
    }

    var notificationDescription: String {
        switch notificationStatus {
        case .notDetermined:
            return "Not requested"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }

    func refreshState() async {
        let previousAuthorization = authorizationStatus
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        if previousAuthorization != authorizationStatus {
            logger.notice(
                "Authorization transition: \(String(describing: previousAuthorization), privacy: .public) -> \(String(describing: self.authorizationStatus), privacy: .public)"
            )
        }

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationStatus = settings.authorizationStatus
        isMonitoring = center.activities.contains(.elapseDaily)
    }

    func requestFamilyAuthorization() async {
        let before = AuthorizationCenter.shared.authorizationStatus
        logger.notice("Requesting individual Family Controls authorization from state \(String(describing: before), privacy: .public)")
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            statusMessage = "Family Controls authorization request completed."
            logger.notice("Authorization transition: \(String(describing: before), privacy: .public) -> \(String(describing: self.authorizationStatus), privacy: .public)")
        } catch {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            statusMessage = "Authorization failed: \(error.localizedDescription)"
            logger.error("Family Controls authorization failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func requestNotificationAuthorization() async {
        logger.notice("Requesting local notification authorization")
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
            statusMessage = granted ? "Notification permission granted." : "Notification permission was not granted."
            logger.notice("Notification authorization request completed; granted=\(granted, privacy: .public)")
        } catch {
            statusMessage = "Notification authorization failed: \(error.localizedDescription)"
            logger.error("Notification authorization failed: \(error.localizedDescription, privacy: .public)")
        }
        await refreshState()
    }

    func startMonitoring() {
        guard authorizationStatus == .approved else {
            statusMessage = "Authorize Family Controls before starting."
            return
        }
        guard !selection.applicationTokens.isEmpty else {
            statusMessage = "Choose at least one application."
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        let events = Dictionary(uniqueKeysWithValues: PulsePlan.thresholdMinutes.map { minutes in
            let name = DeviceActivityEvent.Name(PulsePlan.eventName(for: minutes))
            let event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                threshold: DateComponents(minute: minutes),
                includesPastActivity: false
            )
            return (name, event)
        })

        logger.notice("Starting daily monitor with \(self.selection.applicationTokens.count, privacy: .public) opaque application tokens and events: \(events.keys.map(\.rawValue).sorted().joined(separator: ","), privacy: .public)")
        do {
            try center.startMonitoring(.elapseDaily, during: schedule, events: events)
            isMonitoring = true
            statusMessage = "Monitoring started. Only selected-app use after this start counts."
            logger.notice("Monitoring start succeeded; includesPastActivity=false")
        } catch {
            isMonitoring = center.activities.contains(.elapseDaily)
            statusMessage = "Monitoring failed: \(error.localizedDescription)"
            logger.error("Monitoring start failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func stopMonitoring() {
        logger.notice("Stopping daily monitor")
        center.stopMonitoring([.elapseDaily])
        isMonitoring = center.activities.contains(.elapseDaily)
        statusMessage = isMonitoring ? "Stop was requested, but monitoring still appears active." : "Monitoring stopped."
        logger.notice("Monitoring stop returned; active=\(self.isMonitoring, privacy: .public)")
    }

    private func persistSelection() {
        do {
            let data = try PropertyListEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: selectionKey)
            logger.notice("Persisted opaque selection with \(self.selection.applicationTokens.count, privacy: .public) applications")
        } catch {
            statusMessage = "Could not save the selection: \(error.localizedDescription)"
            logger.error("Selection persistence failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func loadSelection(key: String) -> FamilyActivitySelection {
        guard let data = UserDefaults.standard.data(forKey: key),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return FamilyActivitySelection()
        }
        return selection
    }
}

extension DeviceActivityName {
    static let elapseDaily = DeviceActivityName("elapse.daily")
}
