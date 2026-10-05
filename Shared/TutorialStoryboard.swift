import Foundation

/// Deterministic teaching frames only. Never computes real usage or schedules a pulse.
enum TutorialScene: Int, CaseIterable {
    case chooseApps, chooseInterval, reminder, today

    var titleKey: String {
        ["tutorial.apps.title", "tutorial.interval.title", "tutorial.reminder.title", "tutorial.today.title"][rawValue]
    }
    var detailKey: String {
        ["tutorial.apps.detail", "tutorial.interval.detail", "tutorial.reminder.detail", "tutorial.today.detail"][rawValue]
    }
    var voiceKey: String {
        ["tutorial.apps.voice", "tutorial.interval.voice", "tutorial.reminder.voice", "tutorial.today.voice"][rawValue]
    }
    var next: TutorialScene { TutorialScene(rawValue: min(3, rawValue + 1))! }
    var previous: TutorialScene { TutorialScene(rawValue: max(0, rawValue - 1))! }
}

struct TutorialFrame: Equatable {
    static let duration = 3.0
    let time: Double

    init(time: Double) {
        self.time = time.isFinite ? min(Self.duration, max(0, time)) : 0
    }
    func progress(from start: Double, to end: Double) -> Double {
        guard end > start else { return time >= end ? 1 : 0 }
        let fraction = min(1, max(0, (time - start) / (end - start)))
        return fraction * fraction * (3 - 2 * fraction)
    }
    var selectedRows: Int { time < 0.6 ? 0 : (time < 1.3 ? 1 : 2) }
    var selectionConfirmed: Bool { time >= 2.1 }
    var intervalChosen: Bool { time >= 0.7 }
    var monitoringOn: Bool { time >= 1.8 }
    var sharedUsageProgress: Double { progress(from: 0.3, to: 2.3) }
    var bannerOpacity: Double { progress(from: 2.3, to: 2.7) }
    var reportOpened: Bool { time >= 0.7 }
    var totalOpacity: Double { progress(from: 0.8, to: 1.2) }
    var hourlyOpacity: Double { progress(from: 1.3, to: 1.7) }
    var appRowsOpacity: Double { progress(from: 1.8, to: 2.2) }
}
