import DeviceActivity
import FamilyControls
import Foundation
import OSLog
import UserNotifications

@MainActor
final class ElapseModel: ObservableObject {
    @Published private(set) var selection: FamilyActivitySelection
    @Published private(set) var authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @Published private(set) var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var notificationAlertSetting: UNNotificationSetting = .notSupported
    @Published private(set) var isMonitoring = false
    @Published private(set) var observedRegisteredEventCount: Int?
    @Published private(set) var configuredIntervalMinutes: Int
    @Published private(set) var pulseSnapshot = PulseExperimentSnapshot()
    @Published private(set) var pulseStoreStatus = "未检查"
    @Published var statusMessage: String?
    @Published private(set) var lastAction = "launch"
    @Published private(set) var lastResult = "not_run"
    @Published private(set) var lastErrorCode: String?

    private let center = DeviceActivityCenter()
    private let pulseStore: PulseExperimentStore?
    private let logger = Logger(subsystem: "com.zhangsfish.elapse", category: "setup")
    private let selectionKey = "elapse.familyActivitySelection"
    private static let intervalKey = "elapse.pulseIntervalMinutes"
    private let testNotificationID = "com.zhangsfish.elapse.s00a.ordinary-test"

    init() {
        let restored = Self.loadSelection(key: selectionKey)
        selection = restored.selection
        let savedInterval = UserDefaults.standard.object(forKey: Self.intervalKey) as? Int
        configuredIntervalMinutes = DayPulsePlan(intervalMinutes: savedInterval ?? DayPulsePlan.defaultIntervalMinutes)?.intervalMinutes
            ?? DayPulsePlan.defaultIntervalMinutes
        statusMessage = restored.message
        lastResult = restored.result
        pulseStore = try? PulseExperimentStore.live()
        if center.activities.contains(.elapseDaily) {
            center.stopMonitoring([.elapseDaily])
            statusMessage = "旧版监控已停止；请使用新实验重新开始。"
            lastResult = "legacy_monitor_retired"
        }
        refreshExperimentState()
    }

    var versionDescription: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }

    var authorizationDescription: String {
        switch authorizationStatus {
        case .notDetermined:
            return "尚未确认"
        case .denied:
            return "已拒绝"
        case .approved:
            return "已授权"
        case .approvedWithDataAccess:
            return "已授权（增强访问）"
        @unknown default:
            return "未知"
        }
    }

    var hasFamilyAuthorization: Bool {
        if authorizationStatus == .approved {
            return true
        }
        if #available(iOS 26.4, *) {
            return authorizationStatus == .approvedWithDataAccess
        }
        return false
    }

    var isFamilyAuthorizationDenied: Bool {
        authorizationStatus == .denied
    }

    var notificationDescription: String {
        switch notificationStatus {
        case .notDetermined:
            return "尚未请求"
        case .denied:
            return "已拒绝"
        case .authorized:
            return "已允许"
        case .provisional:
            return "临时允许（可能静默）"
        case .ephemeral:
            return "临时允许"
        @unknown default:
            return "未知"
        }
    }

    var notificationAlertDescription: String {
        switch notificationAlertSetting {
        case .enabled: return "已开启"
        case .disabled: return "已关闭"
        case .notSupported: return "不可用或尚未确认"
        @unknown default: return "未知"
        }
    }

    var diagnosticSummary: String {
        let header = [
            "Everwhile=\(versionDescription)",
            "ScreenTime=\(authorizationDescription)",
            "NotificationAuthorization=\(notificationDescription)",
            "NotificationAlerts=\(notificationAlertDescription)",
            "SelectedApplications=\(selection.applicationTokens.count)",
            "SelectedCategories=\(selection.categoryTokens.count)",
            "SelectedWebDomains=\(selection.webDomainTokens.count)",
            "MonitorRegistration=\(isMonitoring ? "registered_not_verified" : "stopped")",
            "Experiment=\(pulseSnapshot.generation):\(pulseSnapshot.shortID)",
            "ExperimentPhase=\(pulseSnapshot.phase.rawValue)",
            "ExperimentSelectedApplications=\(pulseSnapshot.selectedApplicationCount)",
            "ConfiguredIntervalMinutes=\(configuredIntervalMinutes)",
            "ConfigurationID=\(pulseSnapshot.shortID)",
            "RegistrationIntervalMinutes=\(pulseSnapshot.configurationIntervalMinutes)",
            "PlannedEventCount=\(pulseSnapshot.plannedEventCount)",
            "ObservedRegisteredEventCount=\(observedRegisteredEventCount.map { String($0) } ?? "none")",
            "MaximumThresholdMinutes=\(pulseSnapshot.maximumThresholdMinutes)",
            "CallbackCount=\(pulseSnapshot.callbackCount)",
            "AcceptedRequestCount=\(pulseSnapshot.acceptedRequestCount)",
            "FailedRequestCount=\(pulseSnapshot.failedRequestCount)",
            "MostRecentAcceptedThresholdMinutes=\(pulseSnapshot.mostRecentAcceptedThresholdMinutes.map { String($0) } ?? "none")",
            "NextPlannedThresholdMinutes=\(pulseSnapshot.nextPlannedThresholdMinutes.map { String($0) } ?? "none")_plan_only",
        ]
        let thresholds = pulseSnapshot.recentThresholdMinutes.flatMap { minutes -> [String] in
            let diagnostic = pulseSnapshot.diagnostic(for: minutes)
            let prefix = "Threshold\(minutes)m"
            return [
                "\(prefix)Callback=\(diagnostic.callbackReceived ? "received_current_experiment" : "not_observed")",
                "\(prefix)CallbackAt=\(diagnostic.callbackAt.map { ISO8601DateFormatter().string(from: $0) } ?? "none")",
                "\(prefix)Request=\(diagnostic.requestStatus.rawValue)",
                "\(prefix)RequestAt=\(diagnostic.requestAt.map { ISO8601DateFormatter().string(from: $0) } ?? "none")",
                "\(prefix)ErrorCode=\(diagnostic.safeErrorCode ?? "none")",
            ]
        }
        let footer = [
            "StaleCallbacksRejected=\(pulseSnapshot.staleCallbackCount)",
            "DuplicateCallbacksRejected=\(pulseSnapshot.duplicateCallbackCount)",
            "StaleCompletionsRejected=\(pulseSnapshot.staleCompletionCount)",
            "InvalidCallbacksRejected=\(pulseSnapshot.invalidCallbackCount)",
            "SharedDiagnosticStore=\(pulseStoreStatus)",
            "RegistrationErrorCode=\(pulseSnapshot.safeErrorCode ?? "none")",
            "LastAction=\(lastAction)",
            "LastResult=\(lastResult)",
            "ErrorCode=\(lastErrorCode ?? "none")",
        ]
        return (header + thresholds + footer).joined(separator: "\n")
    }

    func refreshState() async {
        let previousAuthorization = authorizationStatus
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        if previousAuthorization != authorizationStatus {
            logger.notice(
                "Authorization transition: \(String(describing: previousAuthorization), privacy: .public) -> \(String(describing: self.authorizationStatus), privacy: .public)"
            )
        }

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationStatus = settings.authorizationStatus
        notificationAlertSetting = settings.alertSetting
        refreshExperimentState()
    }

    var experimentDescription: String {
        pulseSnapshot.experimentID == nil ? "尚未开始" : "第 \(pulseSnapshot.generation) 次（配置 \(pulseSnapshot.shortID)）"
    }

    func thresholdCallbackDescription(_ minutes: Int) -> String {
        guard let receivedAt = pulseSnapshot.diagnostic(for: minutes).callbackAt else { return "未观察到" }
        return "当前实验已收到（\(receivedAt.formatted(date: .omitted, time: .standard))）"
    }

    func thresholdRequestDescription(_ minutes: Int) -> String {
        let diagnostic = pulseSnapshot.diagnostic(for: minutes)
        switch diagnostic.requestStatus {
        case .notRequested: return "尚未请求"
        case .submitting: return "回调已到，请求结果待确认"
        case .accepted: return "请求已接受，是否显示待观察"
        case .failed: return "请求失败（代码 \(diagnostic.safeErrorCode ?? "未知")）"
        }
    }

    var experimentRegistrationDescription: String {
        guard pulseStoreStatus == "ready" else { return "共享诊断不可用" }
        switch pulseSnapshot.phase {
        case .idle: return "尚未开始"
        case .starting: return "正在登记"
        case .stopped: return "已停止"
        case .failed: return "登记失败"
        case .registered:
            guard isMonitoring else { return "登记状态未确认" }
            return pulseSnapshot.hasReceivedCallback ? "已登记，已收到真实回调" : "已登记，等待真实回调"
        }
    }

    var canChangeSelection: Bool {
        !isMonitoring && pulseSnapshot.canChangeSelection
    }

    var canChangeInterval: Bool { canChangeSelection }

    func updateInterval(to minutes: Int) {
        lastAction = "interval_change"
        guard canChangeInterval else {
            lastResult = "locked_while_monitoring"
            statusMessage = "监控运行中不能修改提醒间隔；请先停止监控。"
            return
        }
        guard DayPulsePlan(intervalMinutes: minutes) != nil else {
            lastResult = "unsupported_interval"
            statusMessage = "不支持该提醒间隔。"
            return
        }
        guard configuredIntervalMinutes != minutes else { return }
        UserDefaults.standard.set(minutes, forKey: Self.intervalKey)
        guard UserDefaults.standard.object(forKey: Self.intervalKey) as? Int == minutes else {
            lastResult = "interval_save_failed"
            statusMessage = "提醒间隔未能保存，配置保持不变。"
            return
        }
        configuredIntervalMinutes = minutes
        lastResult = "interval_saved"
        statusMessage = "提醒间隔已设为 \(minutes) 分钟；下次开始监控时生效。"
    }

    var canStopExperiment: Bool {
        isMonitoring || pulseSnapshot.phase == .starting || pulseSnapshot.phase == .registered
    }

    func updateSelection(_ newSelection: FamilyActivitySelection) {
        guard canChangeSelection else {
            statusMessage = "实验运行中不能修改所选 App；请先停止实验。"
            return
        }
        guard newSelection != selection else { return }
        selection = newSelection
        lastErrorCode = nil
        let saved = persistSelection()
        statusMessage = FoundationFeedback.selectionMessage(
            applicationCount: selection.applicationTokens.count,
            otherCount: selection.categoryTokens.count + selection.webDomainTokens.count,
            saved: saved
        )
        lastAction = "selection"
        lastResult = saved ? "saved" : "save_failed"
    }

    func refreshExperimentState() {
        guard let pulseStore else {
            pulseStoreStatus = "group_unavailable"
            isMonitoring = false
            observedRegisteredEventCount = nil
            return
        }
        do {
            pulseSnapshot = try pulseStore.read()
            pulseStoreStatus = "ready"
            if let id = pulseSnapshot.experimentID {
                let activity = DeviceActivityName(PulsePlan.activityName(for: id))
                isMonitoring = pulseSnapshot.isCurrentRegistration && center.activities.contains(activity)
                observedRegisteredEventCount = isMonitoring ? center.events(for: activity).count : nil
            } else {
                isMonitoring = false
                observedRegisteredEventCount = nil
            }
        } catch {
            pulseStoreStatus = "read_error"
            isMonitoring = false
            observedRegisteredEventCount = nil
        }
    }

    func requestFamilyAuthorization() async {
        let before = AuthorizationCenter.shared.authorizationStatus
        lastAction = "screen_time_authorization"
        lastErrorCode = nil
        logger.notice("Requesting individual Family Controls authorization from state \(String(describing: before), privacy: .public)")
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            lastResult = hasFamilyAuthorization ? "authorized" : "not_authorized"
            statusMessage = hasFamilyAuthorization
                ? "屏幕使用时间状态：已授权。"
                : "授权请求已结束，但当前状态是\(authorizationDescription)；尚不能选择 App。"
            logger.notice("Authorization transition: \(String(describing: before), privacy: .public) -> \(String(describing: self.authorizationStatus), privacy: .public)")
        } catch {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            lastErrorCode = FoundationFeedback.safeErrorCode(error)
            lastResult = "request_failed"
            statusMessage = "屏幕使用时间授权未完成（错误代码 \(lastErrorCode ?? "未知")）；当前状态：\(authorizationDescription)。"
            logger.error("Family Controls authorization failed; code=\(self.lastErrorCode ?? "unknown", privacy: .public)")
        }
    }

    func requestNotificationAuthorization() async {
        lastAction = "notification_authorization"
        lastErrorCode = nil
        logger.notice("Requesting local notification authorization")
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
            await refreshState()
            lastResult = notificationStatus == .authorized ? "authorized" : "not_authorized"
            statusMessage = "通知请求已结束；当前状态：\(notificationDescription)，提醒显示：\(notificationAlertDescription)。"
            logger.notice("Notification authorization request completed; granted=\(granted, privacy: .public)")
        } catch {
            lastErrorCode = FoundationFeedback.safeErrorCode(error)
            lastResult = "request_failed"
            statusMessage = "通知权限请求失败（错误代码 \(lastErrorCode ?? "未知")）。"
            logger.error("Notification authorization failed; code=\(self.lastErrorCode ?? "unknown", privacy: .public)")
            await refreshState()
        }
    }

    func sendOrdinaryTestNotification() async {
        lastAction = "ordinary_test_notification"
        lastErrorCode = nil
        await refreshState()
        guard notificationStatus == .authorized, notificationAlertSetting == .enabled else {
            lastResult = "notification_settings_not_ready"
            statusMessage = "尚不能测试可见提醒：先允许通知，并确认提醒显示已开启。"
            return
        }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [testNotificationID])
        center.removeDeliveredNotifications(withIdentifiers: [testNotificationID])
        let content = UNMutableNotificationContent()
        content.title = "Everwhile 测试通知"
        content.body = "这只是普通通知，不计使用时间。"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8, repeats: false)
        let request = UNNotificationRequest(identifier: testNotificationID, content: content, trigger: trigger)
        do {
            try await center.add(request)
            lastResult = "request_accepted_delivery_unobserved"
            statusMessage = "普通测试通知已提交；约 8 秒后观察手机。提交成功不等于已看到提醒。"
            logger.notice("Ordinary S00-A notification request accepted; visible delivery unobserved")
        } catch {
            lastErrorCode = FoundationFeedback.safeErrorCode(error)
            lastResult = "request_failed"
            statusMessage = "普通测试通知提交失败（错误代码 \(lastErrorCode ?? "未知")）。"
            logger.error("Ordinary S00-A notification request failed; code=\(self.lastErrorCode ?? "unknown", privacy: .public)")
        }
    }

    func startMonitoring() {
        lastAction = "start_experiment"
        lastErrorCode = nil
        guard hasFamilyAuthorization else {
            statusMessage = "请先完成屏幕使用时间授权；未授权不能登记监控。"
            lastResult = "not_authorized"
            return
        }
        guard !selection.applicationTokens.isEmpty else {
            statusMessage = "请先选至少一个 App；类别或网站不计入本轮所选应用。"
            lastResult = "no_app_selected"
            return
        }
        guard let plan = DayPulsePlan(intervalMinutes: configuredIntervalMinutes) else {
            statusMessage = "提醒间隔无效；监控未启动。"
            lastResult = "invalid_interval"
            return
        }
        guard persistSelection() else {
            statusMessage = "所选 App 未能保存；新实验未启动。"
            lastResult = "selection_save_failed"
            return
        }
        refreshExperimentState()
        guard let pulseStore, pulseStoreStatus == "ready" else {
            statusMessage = "共享诊断不可用，不能开始无法核验回调的新实验。"
            lastResult = "shared_diagnostic_unavailable"
            return
        }
        guard !isMonitoring else {
            statusMessage = "已有实验正在运行；请先停止。"
            lastResult = "already_running"
            return
        }

        // Retire both the S00-A fixed activity and any previous experiment.
        // A delayed old callback is rejected by the experiment identity in
        // the extension, even after stopMonitoring returns.
        let previousActivities = center.activities.filter {
            $0 == .elapseDaily || $0.rawValue.hasPrefix(PulsePlan.activityPrefix)
        }
        if !previousActivities.isEmpty {
            do {
                if let oldID = pulseSnapshot.experimentID {
                    try pulseStore.update { $0.markStopped(id: oldID) }
                }
            } catch {
                statusMessage = "无法隔离旧实验；新实验未开始。"
                lastResult = "shared_diagnostic_write_failed"
                return
            }
            center.stopMonitoring(previousActivities)
            guard !center.activities.contains(where: { previousActivities.contains($0) }) else {
                statusMessage = "旧监控仍显示已登记；新实验未开始。"
                lastResult = "old_monitor_still_registered"
                refreshExperimentState()
                return
            }
        }

        let experimentID = UUID().uuidString.lowercased()
        let activity = DeviceActivityName(PulsePlan.activityName(for: experimentID))
        do {
            try pulseStore.update {
                $0.begin(
                    id: experimentID,
                    selectedApplicationCount: selection.applicationTokens.count,
                    plan: plan
                )
            }
        } catch {
            statusMessage = "新实验状态无法保存；监控未启动。"
            lastResult = "shared_diagnostic_write_failed"
            refreshExperimentState()
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: false
        )
        let events = Dictionary(uniqueKeysWithValues: plan.thresholds.map { minutes in
            let name = DeviceActivityEvent.Name(PulsePlan.eventName(for: minutes))
            let event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                threshold: plan.thresholdComponents(for: minutes)!,
                includesPastActivity: false
            )
            return (name, event)
        })

        logger.notice("Starting configuration with \(plan.eventCount, privacy: .public) events and \(self.selection.applicationTokens.count, privacy: .public) opaque application tokens")
        do {
            try center.startMonitoring(activity, during: schedule, events: events)
            let observedCount = center.events(for: activity).count
            guard center.activities.contains(activity), observedCount == plan.eventCount else {
                center.stopMonitoring([activity])
                let code = "registered_event_count_mismatch"
                try? pulseStore.update { $0.markRegistrationFailed(id: experimentID, errorCode: code) }
                refreshExperimentState()
                lastErrorCode = code
                lastResult = "registration_not_confirmed"
                statusMessage = "监控返回成功，但系统登记的事件数与计划不符；已停止，请记录诊断。"
                return
            }
            do {
                try pulseStore.update { $0.markRegistered(id: experimentID) }
            } catch {
                center.stopMonitoring([activity])
                statusMessage = "监控已停止：实验登记状态无法保存。"
                lastResult = "shared_diagnostic_write_failed"
                refreshExperimentState()
                return
            }
            refreshExperimentState()
            lastResult = isMonitoring ? "registered_not_verified" : "registration_not_confirmed"
            statusMessage = isMonitoring
                ? "新实验已登记；这不等于已经收到使用时间回调。"
                : "登记返回成功，但系统未显示该实验正在监控；请查看脱敏诊断。"
            logger.notice("Monitoring start succeeded; includesPastActivity=false")
        } catch {
            lastErrorCode = Self.safeRegistrationErrorCode(error)
            try? pulseStore.update {
                $0.markRegistrationFailed(id: experimentID, errorCode: lastErrorCode ?? "unknown")
            }
            refreshExperimentState()
            lastResult = "registration_failed"
            statusMessage = "监控登记失败（错误代码 \(lastErrorCode ?? "未知")）。"
            logger.error("Monitoring start failed; code=\(self.lastErrorCode ?? "unknown", privacy: .public)")
        }
    }

    private static func safeRegistrationErrorCode(_ error: Error) -> String {
        guard let monitoringError = error as? DeviceActivityCenter.MonitoringError else {
            return "other_\(FoundationFeedback.safeErrorCode(error))"
        }
        switch monitoringError {
        case .excessiveActivities: return "excessive_activities"
        case .intervalTooLong: return "interval_too_long"
        case .intervalTooShort: return "interval_too_short"
        case .invalidDateComponents: return "invalid_date_components"
        case .unauthorized: return "unauthorized"
        @unknown default: return "device_activity_\(FoundationFeedback.safeErrorCode(error))"
        }
    }

    func stopMonitoring() {
        lastAction = "stop_experiment"
        lastErrorCode = nil
        refreshExperimentState()
        guard let pulseStore, let experimentID = pulseSnapshot.experimentID else {
            statusMessage = "没有可停止的当前实验。"
            lastResult = "no_current_experiment"
            return
        }
        let activity = DeviceActivityName(PulsePlan.activityName(for: experimentID))
        var stateSaved = true
        do {
            try pulseStore.update { $0.markStopped(id: experimentID) }
        } catch {
            stateSaved = false
        }
        center.stopMonitoring([activity])
        refreshExperimentState()
        let stillRegistered = center.activities.contains(activity)
        lastResult = stateSaved && !stillRegistered ? "stopped_late_callbacks_not_excluded" : "stop_unconfirmed"
        statusMessage = stateSaved && !stillRegistered
            ? "实验已停止；旧回调仍可能迟到，但不会归入新实验。"
            : "已请求停止，但状态未完全确认；请查看脱敏诊断。"
        logger.notice("Monitoring stop returned; active=\(self.isMonitoring, privacy: .public)")
    }

    private func persistSelection() -> Bool {
        do {
            let data = try PropertyListEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: selectionKey)
            guard UserDefaults.standard.data(forKey: selectionKey) == data else {
                lastErrorCode = "READBACK"
                logger.error("Selection save readback did not match")
                return false
            }
            logger.notice("Persisted opaque selection with \(self.selection.applicationTokens.count, privacy: .public) applications")
            return true
        } catch {
            lastErrorCode = FoundationFeedback.safeErrorCode(error)
            logger.error("Selection persistence failed; code=\(self.lastErrorCode ?? "unknown", privacy: .public)")
            return false
        }
    }

    private static func loadSelection(key: String) -> (
        selection: FamilyActivitySelection, message: String, result: String
    ) {
        guard let stored = UserDefaults.standard.object(forKey: key) else {
            return (FamilyActivitySelection(), "尚未保存所选 App。", "no_saved_selection")
        }
        guard let data = stored as? Data else {
            return (FamilyActivitySelection(), "保存的选择无法读取；请重新选择 App。", "selection_read_failed")
        }
        do {
            let restored = try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
            return (
                restored,
                "已从本机载入 \(restored.applicationTokens.count) 个 App；请核对数量。",
                "selection_loaded"
            )
        } catch {
            return (FamilyActivitySelection(), "保存的选择无法解码；请重新选择 App。", "selection_decode_failed")
        }
    }
}

extension DeviceActivityName {
    static let elapseDaily = DeviceActivityName("elapse.daily")
}
