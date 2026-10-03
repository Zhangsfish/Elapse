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
                        Text("实验运行中已锁定选择；先停止实验再修改。")
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

                Section("S00-C 连续提醒实验") {
                    Text("所选 App 使用时间在本次开始后累计；启动前的活动不计入。回调可能延迟，通知请求成功不等于横幅已显示。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    LabeledContent("实验", value: model.experimentDescription)
                    LabeledContent("登记状态", value: model.experimentRegistrationDescription)
                    ForEach(PulsePlan.thresholdMinutes, id: \.self) { minutes in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(minutes) 分钟")
                                .font(.headline)
                            Text("回调：\(model.thresholdCallbackDescription(minutes))")
                            Text("通知：\(model.thresholdRequestDescription(minutes))")
                        }
                        .font(.footnote)
                    }
                    LabeledContent("拒绝的旧回调", value: "\(model.pulseSnapshot.staleCallbackCount)")
                    LabeledContent("拒绝的重复回调", value: "\(model.pulseSnapshot.duplicateCallbackCount)")
                    Button("开始新实验") {
                        model.startMonitoring()
                    }
                    .disabled(!model.hasFamilyAuthorization || model.selection.applicationTokens.isEmpty || !model.canChangeSelection || model.pulseStoreStatus != "ready")
                    Button("停止实验", role: .destructive) {
                        model.stopMonitoring()
                    }
                    .disabled(!model.canStopExperiment)
                    Button("刷新实验诊断") {
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

                Section("S00-A/B/C 脱敏诊断") {
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
