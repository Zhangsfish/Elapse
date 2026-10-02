import DeviceActivity
import FamilyControls
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
        var usageByApplication: [ApplicationToken: TimeInterval] = [:]
        var hourlyBuckets: [HourlyUsage] = []

        for await deviceData in data {
            for await segment in deviceData.activitySegments {
                var selectedUsageInSegment: TimeInterval = 0
                for await category in segment.categories {
                    for await applicationActivity in category.applications {
                        guard let token = applicationActivity.application.token else {
                            continue
                        }
                        let duration = applicationActivity.totalActivityDuration
                        usageByApplication[token, default: 0] += duration
                        selectedUsageInSegment += duration
                    }
                }
                hourlyBuckets.append(
                    HourlyUsage(start: segment.dateInterval.start, duration: selectedUsageInSegment)
                )
            }
        }

        let applications = usageByApplication
            .map { ApplicationUsage(token: $0.key, duration: $0.value) }
            .sorted { $0.duration > $1.duration }
        let buckets = hourlyBuckets
            .reduce(into: [Date: TimeInterval]()) { partial, bucket in
                partial[bucket.start, default: 0] += bucket.duration
            }
            .map { HourlyUsage(start: $0.key, duration: $0.value) }
            .sorted { $0.start < $1.start }

        let configuration = TodayReportConfiguration(
            totalDuration: applications.reduce(0) { $0 + $1.duration },
            applications: applications,
            hourlyBuckets: buckets
        )
        if applications.isEmpty {
            logger.notice("Report configuration completed with no selected-app activity rows")
        } else {
            logger.notice("Report configuration completed with \(applications.count, privacy: .public) opaque application rows and \(buckets.count, privacy: .public) hourly buckets")
        }
        return configuration
    }
}

private struct TodayReportConfiguration {
    let totalDuration: TimeInterval
    let applications: [ApplicationUsage]
    let hourlyBuckets: [HourlyUsage]
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

    private var maximumBucketDuration: TimeInterval {
        configuration.hourlyBuckets.map(\.duration).max() ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected apps today")
                        .font(.headline)
                    Text(durationText(configuration.totalDuration))
                        .font(.title2.monospacedDigit())
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Per application")
                        .font(.headline)
                    if configuration.applications.isEmpty {
                        Text("No selected-app activity is available for this report yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(configuration.applications) { item in
                            HStack {
                                Label(item.token)
                                Spacer()
                                Text(durationText(item.duration))
                                    .monospacedDigit()
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Hourly selected-app usage")
                        .font(.headline)
                    Text("Each row is an hourly aggregate, not an exact session.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(configuration.hourlyBuckets) { bucket in
                        HourlyUsageRow(
                            bucket: bucket,
                            maximumDuration: maximumBucketDuration
                        )
                    }
                }
            }
            .padding()
        }
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = duration >= 3600 ? [.hour, .minute] : [.minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: duration) ?? "0m"
    }
}

private struct HourlyUsageRow: View {
    let bucket: HourlyUsage
    let maximumDuration: TimeInterval

    private var fraction: Double {
        guard maximumDuration > 0 else { return 0 }
        return bucket.duration / maximumDuration
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(bucket.start, format: .dateTime.hour())
                .font(.caption.monospacedDigit())
                .frame(width: 52, alignment: .leading)
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 3)
                    .fill(.blue.opacity(0.65))
                    .frame(width: max(2, proxy.size.width * fraction))
            }
            .frame(height: 10)
            Text("\(Int(bucket.duration / 60))m")
                .font(.caption.monospacedDigit())
                .frame(width: 42, alignment: .trailing)
        }
    }
}

private extension DeviceActivityReport.Context {
    static let elapseToday = Self("elapse.today")
}
