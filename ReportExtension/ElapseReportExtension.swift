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

    private var maximumBucketDuration: TimeInterval {
        configuration.hourlyBuckets.map(\.duration).max() ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("当前用户 · 当前 iPhone · 今天截至现在")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let lastUpdatedDate = configuration.lastUpdatedDate {
                    Text("系统报告更新于 \(lastUpdatedDate, format: .dateTime.hour().minute())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                switch configuration.state {
                case .unavailable:
                    Text("当前还没有可用的屏幕使用时间报告数据。这不代表所选 App 使用时间为零。")
                case .zeroUsage:
                    Text("今天截至目前没有可显示的所选 App 使用记录。")
                case .content:
                    VStack(alignment: .leading, spacing: 4) {
                        Text("所选 App 今日总时长")
                            .font(.headline)
                        Text(durationText(configuration.totalDuration))
                            .font(.title2.monospacedDigit())
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("各所选 App")
                            .font(.headline)
                        ForEach(configuration.applications) { item in
                            HStack {
                                Label(item.token)
                                Spacer()
                                Text(durationText(item.duration))
                                    .monospacedDigit()
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("所选 App 每小时汇总")
                            .font(.headline)
                        Text("小时汇总，不是精确的 App 打开或关闭时间线。")
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
