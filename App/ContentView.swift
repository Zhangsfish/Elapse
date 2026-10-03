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
                    .disabled(!model.hasFamilyAuthorization)
                }

                Section("S00-A 普通通知自检") {
                    Text("测试，不计使用时间。仅验证普通本地通知；不证明 Screen Time 阈值链路。")
                        .font(.footnote)
                    Button("发送普通测试通知") {
                        Task { await model.sendOrdinaryTestNotification() }
                    }
                }

                Section("S00 pulse") {
                    Text("One shared selected-app pool. Thresholds: 5, 10, 15, 20, 25, and 30 minutes.")
                    Text("Monitoring starts from zero when you tap Start. Earlier activity today is excluded.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    LabeledContent("Status", value: model.isMonitoring ? "Running" : "Stopped")
                    Button("Start monitoring") {
                        model.startMonitoring()
                    }
                    .disabled(!model.hasFamilyAuthorization || model.selection.applicationTokens.isEmpty || model.isMonitoring)
                    Button("Stop monitoring", role: .destructive) {
                        model.stopMonitoring()
                    }
                    .disabled(!model.isMonitoring)
                }

                Section("Today") {
                    NavigationLink("Open truthful usage report") {
                        TodayReportView(selection: model.selection)
                    }
                    .disabled(model.selection.applicationTokens.isEmpty)
                    Text("The report uses hourly aggregate buckets and does not claim exact app-open or app-close sessions.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let message = model.statusMessage {
                    Section("操作结果") {
                        Text(message)
                            .textSelection(.enabled)
                    }
                }

                Section("S00-A 脱敏诊断") {
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
            .familyActivityPicker(isPresented: $pickerPresented, selection: $model.selection)
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
            applications: selection.applicationTokens
        )
    }

    var body: some View {
        DeviceActivityReport(.elapseToday, filter: filter)
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension DeviceActivityReport.Context {
    static let elapseToday = Self("elapse.today")
}
