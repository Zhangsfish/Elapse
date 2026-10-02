import DeviceActivity
import FamilyControls
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: ElapseModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var pickerPresented = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Authorization") {
                    LabeledContent("Screen Time", value: model.authorizationDescription)
                    Button("Request individual authorization") {
                        Task { await model.requestFamilyAuthorization() }
                    }

                    LabeledContent("Notifications", value: model.notificationDescription)
                    Button("Request notification permission") {
                        Task { await model.requestNotificationAuthorization() }
                    }
                }

                Section("Selected applications") {
                    LabeledContent("Count", value: "\(model.selection.applicationTokens.count)")
                    Button("Choose applications") {
                        pickerPresented = true
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
                    .disabled(model.selection.applicationTokens.isEmpty || model.isMonitoring)
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
                    Section("Diagnostic") {
                        Text(message)
                            .textSelection(.enabled)
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
