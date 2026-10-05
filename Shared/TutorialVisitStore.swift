import Foundation

/// App-owned presentation state only. Never writes selection/configuration or App Group data.
enum TutorialVisitStore {
    static let visitKey = "everwhile.tutorial.seen.v1"
    private static let existingSetupKeys = ["elapse.familyActivitySelection", "elapse.pulseIntervalMinutes"]

    /// Reserve once, including Skip/swipe dismissal. Upgrades with saved setup do not auto-present.
    static func reserveFirstVisit(defaults: UserDefaults = .standard) -> Bool {
        guard defaults.object(forKey: visitKey) == nil else { return false }
        let existingSetup = existingSetupKeys.contains { defaults.object(forKey: $0) != nil }
        defaults.set(true, forKey: visitKey)
        // If storage is unavailable, do not create a repeated presentation loop.
        return defaults.bool(forKey: visitKey) && !existingSetup
    }
}
