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
    /// Spring-like positional settle, borrowed from Lecture Asset's motion language.
    /// Overshoot is intentional for transforms, never used as an opacity or data value.
    func snap(from start: Double, to end: Double) -> Double {
        guard end > start else { return progress(from: start, to: end) }
        let x = min(1, max(0, (time - start) / (end - start)))
        if x == 0 || x == 1 { return x }
        return 1 - exp(-7 * x) * cos(11 * x)
    }
    func selection(_ row: Int) -> Double {
        guard (0..<2).contains(row) else { return 0 }
        let start = 0.55 + Double(row) * 0.72
        return progress(from: start, to: start + 0.32)
    }
    var selectionConfirmation: Double { progress(from: 2.1, to: 2.5) }
    var selectionHandY: Double { 104 + 84 * progress(from: 0.85, to: 1.25) }
    var selectionHandOpacity: Double {
        progress(from: 0, to: 0.25) * (1 - progress(from: 1.7, to: 2))
    }
    var intervalSelection: Double { progress(from: 0.55, to: 0.9) }
    var intervalPress: Double {
        progress(from: 0.35, to: 0.55) * (1 - progress(from: 0.65, to: 0.95))
    }
    var startPress: Double {
        progress(from: 1.4, to: 1.6) * (1 - progress(from: 1.7, to: 2))
    }
    var monitoringProgress: Double { progress(from: 1.65, to: 2.25) }
    var intervalHandY: Double { 203 + 86 * progress(from: 0.95, to: 1.35) }
    var intervalHandOpacity: Double {
        progress(from: 0, to: 0.3) * (1 - progress(from: 2, to: 2.3))
    }
    var sharedUsageProgress: Double { progress(from: 0.3, to: 2.3) }
    var bannerOpacity: Double { progress(from: 2.3, to: 2.7) }
    var bannerPosition: Double { snap(from: 2.3, to: 3) }
    var reportProgress: Double { progress(from: 0.3, to: 0.8) }
    var totalOpacity: Double { progress(from: 0.8, to: 1.2) }
    func barGrowth(_ index: Int) -> Double {
        let start = 1.1 + Double(index) * 0.09
        return progress(from: start, to: start + 0.6)
    }
    func rowAppearance(_ index: Int) -> Double {
        let start = 2 + Double(index) * 0.18
        return progress(from: start, to: start + 0.5)
    }
}
