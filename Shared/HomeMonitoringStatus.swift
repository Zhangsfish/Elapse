import Foundation

enum HomeMonitoringStatus: Equatable {
    case needsPermission
    case needsApps
    case off
    case on
    case checking
    case needsAttention

    static func resolve(
        authorized: Bool,
        selectedAppCount: Int,
        desired: Bool,
        exactRegistration: Bool,
        intervalActive: Bool,
        intervalCycleIsToday: Bool,
        registrationFailed: Bool
    ) -> Self {
        guard authorized else { return .needsPermission }
        guard selectedAppCount > 0 else { return .needsApps }
        guard desired else { return .off }
        if registrationFailed { return .needsAttention }
        return exactRegistration && intervalActive && intervalCycleIsToday ? .on : .checking
    }
}
