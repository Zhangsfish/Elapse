import Foundation

struct TodayHourlyBar: Equatable {
    let start: Date
    let seconds: TimeInterval
}

/// Keeps the chart faithful to the report: no invented empty hours or sessions.
struct TodayHourlyChartPlan {
    let bars: [TodayHourlyBar]
    let start: Date
    let end: Date

    init(buckets: [Date: TimeInterval], now: Date, calendar: Calendar = .current) {
        let dayStart = calendar.startOfDay(for: now)
        start = dayStart
        // A mark for the current hour represents the whole hour. Ending the
        // domain at "now" can cut its bar off at the trailing edge.
        end = calendar.dateInterval(of: .hour, for: now)?.end
            ?? max(now, dayStart.addingTimeInterval(1))
        bars = buckets.compactMap { hour, seconds in
            guard hour >= dayStart, hour <= now, seconds.isFinite, seconds > 0 else { return nil }
            return TodayHourlyBar(start: hour, seconds: seconds)
        }.sorted { $0.start < $1.start }
    }

    /// Axis ceiling only; bar heights retain the original seconds.
    /// Whole-minute ticks avoid labelling a fractional minute as a rounded value.
    var maximumSeconds: TimeInterval {
        let peak = bars.map(\.seconds).max() ?? 0
        guard peak > 60 else { return 60 }
        let step: TimeInterval = peak <= 600 ? 120 : 600
        return ceil(peak / step) * step
    }

    var yAxisTicks: [TimeInterval] {
        let ceiling = maximumSeconds
        return ceiling == 60 ? [0, ceiling] : [0, ceiling / 2, ceiling]
    }
}
