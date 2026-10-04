import Charts
import DeviceActivity
import FamilyControls
import ManagedSettings
import OSLog
import SwiftUI

@main
struct ElapseReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TodayReportScene()
    }
}

private struct TodayReportScene: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .elapseToday
    let content: (TodayReportConfiguration) -> TodayReportView
    private let logger = Logger(subsystem: "com.zhangsfish.elapse.report", category: "configuration")

    init() {
        content = { configuration in
            TodayReportView(configuration: configuration)
        }
    }

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> TodayReportConfiguration {
        logger.notice("Building hourly selected-app report configuration")
        var aggregation = TodayReportAggregation<ApplicationToken>()
        var deviceRecordCount = 0
        var isCurrentIPhone = false
        var hasUnattributedActivity = false
        var lastUpdatedDate: Date?

        for await deviceData in data {
            deviceRecordCount += 1
            guard deviceRecordCount == 1 else { continue }
            isCurrentIPhone = deviceData.device.model == .iPhone
            lastUpdatedDate = deviceData.lastUpdatedDate
            for await segment in deviceData.activitySegments {
                for await category in segment.categories {
                    for await applicationActivity in category.applications {
                        let duration = applicationActivity.totalActivityDuration
                        guard let token = applicationActivity.application.token else {
                            if duration > 0 { hasUnattributedActivity = true }
                            continue
                        }
                        aggregation.add(
                            application: token,
                            duration: duration,
                            hourStart: segment.dateInterval.start
                        )
                    }
                }
            }
        }

        let state = TodayReportState.classify(
            deviceRecordCount: deviceRecordCount,
            isCurrentIPhone: isCurrentIPhone,
            hasUnattributedActivity: hasUnattributedActivity,
            totalDuration: aggregation.totalDuration
        )
        guard state == .content else {
            logger.notice("Report configuration completed without displayable selected-app activity")
            return TodayReportConfiguration(
                state: state,
                totalDuration: 0,
                applications: [],
                hourlyBuckets: [],
                lastUpdatedDate: state == .zeroUsage ? lastUpdatedDate : nil
            )
        }

        let applications = aggregation.byApplication
            .map { ApplicationUsage(token: $0.key, duration: $0.value) }
            .sorted { $0.duration > $1.duration }
        let buckets = aggregation.byHour
            .map { HourlyUsage(start: $0.key, duration: $0.value) }
            .sorted { $0.start < $1.start }

        let configuration = TodayReportConfiguration(
            state: state,
            totalDuration: aggregation.totalDuration,
            applications: applications,
            hourlyBuckets: buckets,
            lastUpdatedDate: lastUpdatedDate
        )
        logger.notice("Report configuration completed with \(applications.count, privacy: .public) opaque application rows and \(buckets.count, privacy: .public) hourly buckets")
        return configuration
    }
}

private struct TodayReportConfiguration {
    let state: TodayReportState
    let totalDuration: TimeInterval
    let applications: [ApplicationUsage]
    let hourlyBuckets: [HourlyUsage]
    let lastUpdatedDate: Date?
}

private struct ApplicationUsage: Identifiable {
    let token: ApplicationToken
    let duration: TimeInterval

    var id: ApplicationToken { token }
}

private struct HourlyUsage: Identifiable {
    let start: Date
    let duration: TimeInterval

    var id: Date { start }
}

private struct TodayReportView: View {
    let configuration: TodayReportConfiguration
    @Environment(\.locale) private var locale

    private var chartPlan: TodayHourlyChartPlan {
        TodayHourlyChartPlan(
            buckets: Dictionary(
                uniqueKeysWithValues: configuration.hourlyBuckets.map { ($0.start, $0.duration) }
            ),
            now: Date()
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                switch configuration.state {
                case .unavailable:
                    ContentUnavailableView(
                        "report.unavailable.title",
                        systemImage: "hourglass",
                        description: Text("report.unavailable.detail")
                    )
                case .zeroUsage:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("report.total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(durationText(0))
                            .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                        Text("report.zero")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                case .content:
                    VStack(alignment: .leading, spacing: 6) {
                        Text("report.total")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(durationText(configuration.totalDuration))
                            .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                            .minimumScaleFactor(0.75)
                        if let lastUpdatedDate = configuration.lastUpdatedDate {
                            HStack(spacing: 4) {
                                Text("report.updated")
                                Text(lastUpdatedDate, format: .dateTime.hour().minute())
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("report.hourly").font(.headline)
                        Chart(chartPlan.bars, id: \.start) { bucket in
                            BarMark(
                                x: .value(String(localized: "report.hour"), bucket.start, unit: .hour),
                                y: .value(String(localized: "report.duration"), bucket.seconds),
                                width: .fixed(9)
                            )
                            .foregroundStyle(Color.accentColor)
                            .accessibilityLabel(bucket.start.formatted(.dateTime.hour()))
                            .accessibilityValue(durationText(bucket.seconds))
                        }
                        .chartXScale(domain: chartPlan.start...chartPlan.end)
                        .chartYScale(domain: 0...chartPlan.maximumSeconds)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .hour, count: 4)) { _ in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.hour())
                            }
                        }
                        .chartYAxis(.hidden)
                        .frame(height: 168)
                        .accessibilityLabel(Text("report.hourly"))
                        Text("report.hourlyNote")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("report.apps").font(.headline)
                        ForEach(configuration.applications) { item in
                            VStack(alignment: .leading, spacing: 7) {
                                HStack(spacing: 8) {
                                    Label(item.token)
                                        .lineLimit(2)
                                    Spacer(minLength: 8)
                                    Text(durationText(item.duration))
                                        .monospacedDigit()
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                                ProgressView(value: item.duration, total: configuration.totalDuration)
                                    .tint(.secondary)
                                    .accessibilityHidden(true)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func durationText(_ duration: TimeInterval) -> String {
        UsageDurationFormatter.format(duration, language: .forLocale(locale))
    }
}

private extension DeviceActivityReport.Context {
    static let elapseToday = Self("elapse.today")
}
