import DeviceActivity
import FamilyControls
import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var model: ElapseModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var pickerPresented = false

    var body: some View {
        NavigationStack {
            Form {
                Section("权限状态") {
                    LabeledContent("屏幕使用时间", value: model.authorizationDescription)
                    Button("请求屏幕使用时间授权") {
                        Task { await model.requestFamilyAuthorization() }
                    }
                    if model.isFamilyAuthorizationDenied,
                       let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        Button("打开 Everwhile 设置") {
                            openURL(settingsURL)
                        }
                    }

                    LabeledContent("通知", value: model.notificationDescription)
                    LabeledContent("提醒显示", value: model.notificationAlertDescription)
                    Button("请求通知权限") {
                        Task { await model.requestNotificationAuthorization() }
                    }
                }

                Section("所选 App") {
                    LabeledContent("App 数量", value: "\(model.selection.applicationTokens.count)")
                    Button("选择 App") {
                        pickerPresented = true
                    }
                    .disabled(!model.hasFamilyAuthorization || !model.canChangeSelection)
                    if !model.canChangeSelection {
                        Text("监控运行中已锁定选择；先停止监控再修改。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("S00-A 普通通知自检") {
                    Text("测试，不计使用时间。仅验证普通本地通知；不证明 Screen Time 阈值链路。")
                        .font(.footnote)
                    Button("发送普通测试通知") {
                        Task { await model.sendOrdinaryTestNotification() }
                    }
                }

                Section("S01-A 日内提醒配置") {
                    Text("所选 App 使用从本轮开始后累计；提醒点不等于 Today 总量。此版只验证当天计划登记，尚不自动跨日续接。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Picker("提醒间隔", selection: Binding(
                        get: { model.configuredIntervalMinutes },
                        set: { model.updateInterval(to: $0) }
                    )) {
                        ForEach(DayPulsePlan.supportedIntervals, id: \.self) { minutes in
                            Text("\(minutes) 分钟").tag(minutes)
                        }
                    }
                    .disabled(!model.canChangeInterval)
                    if !model.canChangeInterval {
                        Text("监控运行中已锁定间隔；先停止监控再修改。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("配置", value: model.experimentDescription)
                    LabeledContent("配置 ID", value: model.pulseSnapshot.shortID)
                    LabeledContent("登记间隔", value: "\(model.pulseSnapshot.configurationIntervalMinutes) 分钟")
                    LabeledContent("计划事件数", value: "\(model.pulseSnapshot.plannedEventCount)")
                    LabeledContent("系统登记事件数", value: model.observedRegisteredEventCount.map { String($0) } ?? "未确认")
                    LabeledContent("登记状态", value: model.experimentRegistrationDescription)
                    LabeledContent("登记错误", value: model.pulseSnapshot.safeErrorCode ?? "无")
                    LabeledContent("已收到回调", value: "\(model.pulseSnapshot.callbackCount)")
                    LabeledContent("已接受通知请求", value: "\(model.pulseSnapshot.acceptedRequestCount)")
                    LabeledContent("通知请求失败", value: "\(model.pulseSnapshot.failedRequestCount)")
                    LabeledContent("最近已接受提醒点", value: model.pulseSnapshot.mostRecentAcceptedThresholdMinutes.map { "\($0) 分钟" } ?? "无")
                    LabeledContent("计划下一档（非实时计量）", value: model.pulseSnapshot.nextPlannedThresholdMinutes.map { "\($0) 分钟" } ?? "无")
                    ForEach(model.pulseSnapshot.recentThresholdMinutes, id: \.self) { minutes in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("最近回调 · \(minutes) 分钟")
                                .font(.headline)
                            Text("回调：\(model.thresholdCallbackDescription(minutes))")
                            Text("通知：\(model.thresholdRequestDescription(minutes))")
                        }
                        .font(.footnote)
                    }
                    LabeledContent("拒绝的旧回调", value: "\(model.pulseSnapshot.staleCallbackCount)")
                    LabeledContent("拒绝的重复回调", value: "\(model.pulseSnapshot.duplicateCallbackCount)")
                    Button("开始监控") {
                        model.startMonitoring()
                    }
                    .disabled(!model.hasFamilyAuthorization || model.selection.applicationTokens.isEmpty || !model.canChangeSelection || model.pulseStoreStatus != "ready")
                    Button("停止监控", role: .destructive) {
                        model.stopMonitoring()
                    }
                    .disabled(!model.canStopExperiment)
                    Button("刷新监控诊断") {
                        Task { await model.refreshState() }
                    }
                }

                Section("Today") {
                    NavigationLink("查看今日真实使用报告") {
                        TodayReportView(selection: model.selection)
                    }
                    .disabled(model.selection.applicationTokens.isEmpty)
                    Text("当前用户 · 当前 iPhone · 今天截至现在。报告由系统加载；小时汇总不是精确的 App 打开或关闭时间线。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let message = model.statusMessage {
                    Section("操作结果") {
                        Text(message)
                            .textSelection(.enabled)
                    }
                }

                Section("脱敏诊断") {
                    LabeledContent("版本", value: model.versionDescription)
                    Text(model.diagnosticSummary)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                    Button("复制脱敏诊断") {
                        UIPasteboard.general.string = model.diagnosticSummary
                    }
                }
            }
            .navigationTitle("Everwhile")
            .familyActivityPicker(
                isPresented: $pickerPresented,
                selection: Binding(
                    get: { model.selection },
                    set: { model.updateSelection($0) }
                )
            )
            .task { await model.refreshState() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task { await model.refreshState() }
                }
            }
        }
    }
}

struct TodayReportView: View {
    let selection: FamilyActivitySelection

    private var filter: DeviceActivityFilter {
        DeviceActivityFilter(
            segment: .hourly(during: TodayInterval.make()),
            devices: nil,
            applications: selection.applicationTokens
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("当前用户 · 当前 iPhone · 今天截至现在")
                .font(.footnote)
            Text("屏幕使用时间报告由 iOS 加载，可能需要片刻更新。")
                .font(.footnote)
                .foregroundStyle(.secondary)
            DeviceActivityReport(.elapseToday, filter: filter)
        }
        .padding(.horizontal)
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension DeviceActivityReport.Context {
    static let elapseToday = Self("elapse.today")
}
