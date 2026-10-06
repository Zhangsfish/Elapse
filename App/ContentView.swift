import DeviceActivity
import FamilyControls
import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var model: ElapseModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var pickerPresented = false
    @State private var tutorialPresented = TutorialVisitStore.reserveFirstVisit()
    @State private var aboutPresented = false
    #if DEBUG
    @State private var diagnosticsPresented = false
    #endif
    @State private var notificationPermissionInProgress = false

    private var summaryLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 18))
    }

    private var monitoringStatus: HomeMonitoringStatus {
        HomeMonitoringStatus.resolve(
            authorized: model.hasFamilyAuthorization,
            selectedAppCount: model.selection.applicationTokens.count,
            desired: model.pulseSnapshot.monitoringDesired,
            exactRegistration: model.isMonitoring && model.systemScheduleRepeatsDaily == true,
            intervalActive: model.pulseSnapshot.lifecycleState == .active,
            intervalCycleIsToday: model.pulseSnapshot.intervalCycleKey == PulseCycle.key(for: Date()),
            registrationFailed: model.pulseSnapshot.phase == .failed
        )
    }

    private var statusKey: LocalizedStringKey {
        switch monitoringStatus {
        case .needsPermission: return "home.status.permission"
        case .needsApps: return "home.status.apps"
        case .off: return "home.status.off"
        case .on: return "home.status.on"
        case .checking: return "home.status.checking"
        case .needsAttention: return "home.status.attention"
        }
    }

    private var statusDetailKey: LocalizedStringKey {
        switch monitoringStatus {
        case .needsPermission: return "home.detail.permission"
        case .needsApps: return "home.detail.apps"
        case .off: return "home.detail.off"
        case .on: return "home.detail.on"
        case .checking: return "home.detail.checking"
        case .needsAttention: return "home.detail.attention"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Everwhile").font(.largeTitle.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text("home.tagline")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(statusKey).font(.title2.weight(.semibold))
                            Text(statusDetailKey)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine)

                        summaryLayout {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("home.interval")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 4) {
                                    Text(verbatim: "\(model.configuredIntervalMinutes)")
                                    Text("home.minutes")
                                }
                                .font(.headline.monospacedDigit())
                            }
                            .accessibilityElement(children: .combine)
                            if !dynamicTypeSize.isAccessibilitySize { Spacer(minLength: 8) }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("home.selected")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 4) {
                                    Text(verbatim: "\(model.selection.applicationTokens.count)")
                                    Text(model.selection.applicationTokens.count == 1 ? "home.app" : "home.apps")
                                }
                                .font(.headline.monospacedDigit())
                            }
                            .accessibilityElement(children: .combine)
                        }
                        primaryAction
                        if model.hasFamilyAuthorization && !model.selection.applicationTokens.isEmpty {
                            if model.notificationStatus == .notDetermined {
                                Text("home.notifications.firstStart")
                                    .font(.caption).foregroundStyle(.secondary)
                            } else if model.notificationStatus != .authorized || model.notificationAlertSetting != .enabled {
                                Text("home.notifications.disabled")
                                    .font(.caption).foregroundStyle(.secondary)
                                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                    Button("home.openSettings") { openURL(settingsURL) }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))

                    VStack(spacing: 0) {
                        Button { pickerPresented = true } label: {
                            actionRow("home.chooseApps", icon: "square.stack.3d.up")
                        }
                        .disabled(!model.hasFamilyAuthorization || !model.canChangeSelection)
                        .accessibilityHint(Text(model.canChangeSelection ? "home.chooseApps.hint" : "home.editLocked"))
                        Divider().padding(.leading, 52)
                        AnyLayout(dynamicTypeSize.isAccessibilitySize
                            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                            : AnyLayout(HStackLayout(spacing: 8))) {
                            Image(systemName: "clock")
                                .frame(width: 28)
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                            Picker("home.changeInterval", selection: Binding(
                                get: { model.configuredIntervalMinutes },
                                set: { model.updateInterval(to: $0) }
                            )) {
                                ForEach(DayPulsePlan.supportedIntervals, id: \.self) { minutes in
                                    Text("\(minutes) \(String(localized: "home.minutes"))").tag(minutes)
                                }
                            }
                            .disabled(!model.canChangeInterval)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))

                    NavigationLink {
                        TodayReportView(selection: model.selection)
                    } label: {
                        HStack(alignment: .center, spacing: 14) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.title2)
                                .frame(width: 34)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("home.today").font(.title3.weight(.semibold))
                                Text("home.today.detail")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 4)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .accessibilityHidden(true)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
                    }
                    .buttonStyle(.plain)
                    .disabled(model.selection.applicationTokens.isEmpty)
                }
                .padding(20)
                .frame(maxWidth: 620)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .controlSize(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("tutorial.replay", systemImage: "play.rectangle") { tutorialPresented = true }
                            .accessibilityIdentifier("tutorial-replay")
                        Button("about.title", systemImage: "info.circle") { aboutPresented = true }
                            .accessibilityIdentifier("about-open")
                        #if DEBUG
                        Button("home.diagnostics", systemImage: "slider.horizontal.3") { diagnosticsPresented = true }
                            .accessibilityIdentifier("developer-diagnostics")
                        #endif
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel(Text("home.menu"))
                    }
                    .accessibilityIdentifier("home-menu")
                }
            }
            #if DEBUG
            .navigationDestination(isPresented: $diagnosticsPresented) { DiagnosticsView() }
            #endif
            .sheet(isPresented: $aboutPresented) { AboutSupportView() }
            .sheet(isPresented: $tutorialPresented) {
                QuickStartTutorialView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .familyActivityPicker(
                isPresented: $pickerPresented,
                selection: Binding(
                    get: { model.selection },
                    set: { model.updateSelection($0) }
                )
            )
            .task { await model.refreshState() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { Task { await model.refreshState() } }
            }
        }
    }

    @ViewBuilder
    private var primaryAction: some View {
        if !model.hasFamilyAuthorization {
            Button {
                Task { await model.requestFamilyAuthorization() }
            } label: {
                Text("home.allowScreenTime").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("allow-screen-time")
            if model.isFamilyAuthorizationDenied,
               let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                Button("home.openSettings") { openURL(settingsURL) }
            }
            if model.canStopExperiment {
                Button("home.stop", role: .destructive) { model.stopMonitoring() }
            }
        } else if model.canStopExperiment {
            Button(role: .destructive) { model.stopMonitoring() } label: {
                Label("home.stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        } else if model.selection.applicationTokens.isEmpty {
            Button { pickerPresented = true } label: {
                Text("home.chooseApps").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button {
                notificationPermissionInProgress = true
                Task {
                    defer { notificationPermissionInProgress = false }
                    // First-use UI integration only; registration/reconcile stay unchanged.
                    if model.notificationStatus == .notDetermined {
                        await model.requestNotificationAuthorization()
                    }
                    model.startMonitoring()
                }
            } label: {
                Label("home.start", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(notificationPermissionInProgress || !model.canChangeSelection || model.pulseStoreStatus != "ready")
        }
    }

    private func actionRow(_ title: LocalizedStringKey, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text(title).foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .padding(18)
        .contentShape(Rectangle())
    }
}

#if DEBUG
private struct DiagnosticsView: View {
    @EnvironmentObject private var model: ElapseModel

    var body: some View {
        Form {
            Section("diagnostics.permissions") {
                LabeledContent("diagnostics.screenTime", value: model.authorizationDescription)
                LabeledContent("diagnostics.notifications", value: model.notificationDescription)
                LabeledContent("diagnostics.alerts", value: model.notificationAlertDescription)
                Button("diagnostics.requestNotifications") {
                    Task { await model.requestNotificationAuthorization() }
                }
            }
            Section("diagnostics.registration") {
                LabeledContent("diagnostics.configuration", value: model.pulseSnapshot.shortID)
                LabeledContent("diagnostics.state", value: model.experimentRegistrationDescription)
                LabeledContent("diagnostics.plannedEvents", value: String(model.pulseSnapshot.plannedEventCount))
                LabeledContent("diagnostics.systemEvents", value: model.observedRegisteredEventCount.map { String($0) } ?? "—")
                LabeledContent("diagnostics.lifecycle", value: model.pulseSnapshot.lifecycleState.rawValue)
                LabeledContent("diagnostics.generation", value: String(model.pulseSnapshot.intervalGeneration))
                LabeledContent("diagnostics.recoveries", value: String(model.pulseSnapshot.recoveryCount))
                LabeledContent("diagnostics.callbacks", value: String(model.pulseSnapshot.callbackCount))
                LabeledContent("diagnostics.requests", value: String(model.pulseSnapshot.acceptedRequestCount))
            }
            Section("diagnostics.tools") {
                Text("diagnostics.testNote").font(.footnote).foregroundStyle(.secondary)
                Button("diagnostics.testNotification") {
                    Task { await model.sendOrdinaryTestNotification() }
                }
                Button("diagnostics.refresh") {
                    Task { await model.refreshState() }
                }
                Button("diagnostics.copy") {
                    UIPasteboard.general.string = model.diagnosticSummary
                }
            }
            if let message = model.statusMessage {
                Section("diagnostics.lastResult") { Text(message).textSelection(.enabled) }
            }
            Section("diagnostics.summary") {
                LabeledContent("diagnostics.version", value: model.versionDescription)
                Text(model.diagnosticSummary)
                    .font(.footnote.monospaced())
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("diagnostics.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#endif

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
        VStack(alignment: .leading, spacing: 0) {
            Text("today.scope")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.top, 6)
            DeviceActivityReport(.elapseToday, filter: filter)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("today.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension DeviceActivityReport.Context {
    static let elapseToday = Self("elapse.today")
}
