import Combine
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
    @Published private(set) var actualRegistrationPresent = false
    @Published private(set) var systemScheduleRepeatsDaily: Bool?
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
    private var authorizationCancellable: AnyCancellable?
    private var reconciliationInProgress = false

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
        authorizationCancellable = AuthorizationCenter.shared.$authorizationStatus
            .dropFirst()
            .sink { [weak self] newStatus in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.authorizationStatus = newStatus
                    self.reconcileMonitoring()
                }
            }
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
            "MonitoringDesired=\(pulseSnapshot.monitoringDesired ? "ON" : "OFF")",
            "SystemRegistrationPresent=\(actualRegistrationPresent)",
            "SystemRegistrationExact=\(isMonitoring)",
            "SystemScheduleRepeatsDaily=\(systemScheduleRepeatsDaily.map { String($0) } ?? "none")",
            "Experiment=\(pulseSnapshot.generation):\(pulseSnapshot.shortID)",
            "ExperimentPhase=\(pulseSnapshot.phase.rawValue)",
            "ExperimentSelectedApplications=\(pulseSnapshot.selectedApplicationCount)",
            "ConfiguredIntervalMinutes=\(configuredIntervalMinutes)",
            "ConfigurationID=\(pulseSnapshot.shortID)",
            "RegistrationIntervalMinutes=\(pulseSnapshot.configurationIntervalMinutes)",
            "PlannedEventCount=\(pulseSnapshot.plannedEventCount)",
            "ObservedRegisteredEventCount=\(observedRegisteredEventCount.map { String($0) } ?? "none")",
            "MaximumThresholdMinutes=\(pulseSnapshot.maximumThresholdMinutes)",
            "IntervalGeneration=\(pulseSnapshot.intervalGeneration)",
            "IntervalCycleKey=\(pulseSnapshot.intervalCycleKey ?? "none")",
            "IntervalAnchor=\(pulseSnapshot.intervalAnchor.map { ISO8601DateFormatter().string(from: $0) } ?? "none")",
            "LastIntervalStartAt=\(pulseSnapshot.lastIntervalStartAt.map { ISO8601DateFormatter().string(from: $0) } ?? "none")",
            "LastIntervalEndAt=\(pulseSnapshot.lastIntervalEndAt.map { ISO8601DateFormatter().string(from: $0) } ?? "none")",
            "LifecycleState=\(pulseSnapshot.lifecycleState.rawValue)",
            "RecoveryCount=\(pulseSnapshot.recoveryCount)",
            "LastRecoveryReason=\(pulseSnapshot.lastRecoveryReason?.rawValue ?? "none")",
            "PrematureCallbacksRejected=\(pulseSnapshot.prematureCallbackCount)",
            "UnanchoredCallbacksRejected=\(pulseSnapshot.unanchoredCallbackCount)",
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
        reconcileMonitoring()
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
        if pulseSnapshot.monitoringDesired && !hasFamilyAuthorization { return "授权阻断，未确认当前计量" }
        switch pulseSnapshot.phase {
        case .idle: return "尚未开始"
        case .starting: return "正在登记"
        case .stopped: return "已停止"
        case .failed: return "登记失败"
        case .registered:
            guard isMonitoring else { return "系统登记不完整，未确认当前计量" }
            return pulseSnapshot.lifecycleState == .active
                ? "已登记，已收到 intervalDidStart（不等于用量验证）"
                : "已登记，尚无当前 interval start 证据"
        }
    }

    var canChangeSelection: Bool {
        !pulseSnapshot.monitoringDesired && !actualRegistrationPresent
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
        pulseSnapshot.monitoringDesired || actualRegistrationPresent
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
            actualRegistrationPresent = false
            observedRegisteredEventCount = nil
            systemScheduleRepeatsDaily = nil
            return
        }
        do {
            pulseSnapshot = try pulseStore.read()
            pulseStoreStatus = "ready"
            if let id = pulseSnapshot.experimentID {
                let activity = DeviceActivityName(PulsePlan.activityName(for: id))
                actualRegistrationPresent = center.activities.contains(activity)
                observedRegisteredEventCount = actualRegistrationPresent ? center.events(for: activity).count : nil
                systemScheduleRepeatsDaily = actualRegistrationPresent ? center.schedule(for: activity)?.repeats : nil
                isMonitoring = pulseSnapshot.monitoringDesired &&
                    pulseSnapshot.isCurrentRegistration && actualRegistrationPresent &&
                    observedRegisteredEventCount == pulseSnapshot.plannedEventCount &&
                    systemScheduleRepeatsDaily == true
            } else {
                isMonitoring = false
                actualRegistrationPresent = false
                observedRegisteredEventCount = nil
                systemScheduleRepeatsDaily = nil
            }
        } catch {
            pulseStoreStatus = "read_error"
            isMonitoring = false
            actualRegistrationPresent = false
            observedRegisteredEventCount = nil
            systemScheduleRepeatsDaily = nil
        }
    }

    func reconcileMonitoring() {
        guard !reconciliationInProgress else { return }
        reconciliationInProgress = true
        defer { reconciliationInProgress = false }
        refreshExperimentState()
        guard let pulseStore, pulseStoreStatus == "ready" else { return }

        let ownedActivities = center.activities.filter {
            $0 == .elapseDaily || $0.rawValue.hasPrefix(PulsePlan.activityPrefix)
        }
        let plan = DayPulsePlan(intervalMinutes: configuredIntervalMinutes)
        let facts = PulseReconcileFacts(
            desired: pulseSnapshot.monitoringDesired,
            authorizationApproved: hasFamilyAuthorization,
            selectedApplicationsAvailable: !selection.applicationTokens.isEmpty && plan != nil,
            snapshotPhase: pulseSnapshot.phase,
            recoveryFailed: pulseSnapshot.phase == .failed && pulseSnapshot.lastRecoveryReason != nil,
            authorizationWasBlocked: pulseSnapshot.authorizationWasBlocked,
            snapshotRepeatsDaily: pulseSnapshot.scheduleRepeatsDaily,
            selectionMatchesSnapshot: pulseSnapshot.selectedApplicationCount == selection.applicationTokens.count &&
                pulseSnapshot.configurationIntervalMinutes == configuredIntervalMinutes &&
                pulseSnapshot.plannedEventCount == plan?.eventCount,
            registeredEventsMatchSelection: registeredEventsMatchSelection(plan: plan),
            activityPresent: actualRegistrationPresent,
            observedEventCount: observedRegisteredEventCount,
            plannedEventCount: pulseSnapshot.plannedEventCount,
            systemScheduleRepeats: systemScheduleRepeatsDaily
        )
        switch PulseReconciliationPolicy.decide(facts) {
        case .idle, .stopStrays:
            if !ownedActivities.isEmpty { center.stopMonitoring(ownedActivities) }
            if let id = pulseSnapshot.experimentID, pulseSnapshot.phase != .stopped {
                try? pulseStore.update { $0.markStopped(id: id) }
            }
            refreshExperimentState()
        case .blockedAuthorization:
            try? pulseStore.update { $0.markAuthorizationBlocked() }
            if !ownedActivities.isEmpty { center.stopMonitoring(ownedActivities) }
            refreshExperimentState()
            lastResult = "blocked_authorization"
            statusMessage = "屏幕使用时间授权未就绪；已停止系统登记，保留监控意图，不自动弹出授权。"
        case .blockedSelection:
            if !ownedActivities.isEmpty { center.stopMonitoring(ownedActivities) }
            if let id = pulseSnapshot.experimentID {
                try? pulseStore.update { $0.markRegistrationFailed(id: id, errorCode: "selection_unavailable") }
            }
            refreshExperimentState()
            lastResult = "blocked_selection"
            statusMessage = "所选 App 配置不可用；监控已停止，请检查选择后显式重新开始。"
        case .keepRegistration:
            if let id = pulseSnapshot.experimentID, pulseSnapshot.phase == .starting {
                try? pulseStore.update { $0.markRegistered(id: id) }
            }
            let currentName = pulseSnapshot.experimentID.map { PulsePlan.activityName(for: $0) } ?? ""
            let stray = ownedActivities.filter {
                $0.rawValue != currentName
            }
            if !stray.isEmpty { center.stopMonitoring(stray) }
            refreshExperimentState()
        case let .recover(reason):
            registerNewConfiguration(recoveryReason: reason)
        case .holdFailure:
            if !ownedActivities.isEmpty { center.stopMonitoring(ownedActivities) }
            refreshExperimentState()
            lastResult = "recovery_failed_no_retry_loop"
        }
    }

    private func registeredEventsMatchSelection(plan: DayPulsePlan?) -> Bool {
        guard actualRegistrationPresent, let plan, let id = pulseSnapshot.experimentID else { return false }
        let activity = DeviceActivityName(PulsePlan.activityName(for: id))
        let events = center.events(for: activity)
        guard events.count == plan.eventCount else { return false }
        return plan.thresholds.allSatisfy { minutes in
            guard let event = events[DeviceActivityEvent.Name(PulsePlan.eventName(for: minutes))] else {
                return false
            }
            return event.applications == selection.applicationTokens && !event.includesPastActivity
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
            reconcileMonitoring()
        } catch {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            lastErrorCode = FoundationFeedback.safeErrorCode(error)
            lastResult = "request_failed"
            statusMessage = "屏幕使用时间授权未完成（错误代码 \(lastErrorCode ?? "未知")）；当前状态：\(authorizationDescription)。"
            logger.error("Family Controls authorization failed; code=\(self.lastErrorCode ?? "unknown", privacy: .public)")
            reconcileMonitoring()
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
        lastAction = "start_monitoring"
        lastErrorCode = nil
        refreshExperimentState()
        guard !pulseSnapshot.monitoringDesired && !actualRegistrationPresent else {
            statusMessage = "已有监控意图或系统登记；请先停止监控。"
            lastResult = "already_running_or_desired"
            return
        }
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
        guard DayPulsePlan(intervalMinutes: configuredIntervalMinutes) != nil else {
            statusMessage = "提醒间隔无效；监控未启动。"
            lastResult = "invalid_interval"
            return
        }
        guard persistSelection() else {
            statusMessage = "所选 App 未能保存；监控未启动。"
            lastResult = "selection_save_failed"
            return
        }
        registerNewConfiguration(recoveryReason: nil)
    }

    private func registerNewConfiguration(recoveryReason: PulseRecoveryReason?) {
        guard let pulseStore, pulseStoreStatus == "ready",
              let plan = DayPulsePlan(intervalMinutes: configuredIntervalMinutes),
              hasFamilyAuthorization,
              !selection.applicationTokens.isEmpty else {
            statusMessage = "监控配置、授权或共享诊断不可用；没有启动新登记。"
            lastResult = "shared_diagnostic_unavailable"
            return
        }
        guard persistSelection() else {
            lastResult = "selection_save_failed"
            statusMessage = "所选 App 未能保存；没有启动新登记。"
            return
        }
        let previousActivities = center.activities.filter {
            $0 == .elapseDaily || $0.rawValue.hasPrefix(PulsePlan.activityPrefix)
        }
        let experimentID = UUID().uuidString.lowercased()
        let activity = DeviceActivityName(PulsePlan.activityName(for: experimentID))
        do {
            try pulseStore.update {
                $0.begin(
                    id: experimentID,
                    selectedApplicationCount: selection.applicationTokens.count,
                    plan: plan,
                    at: Date(),
                    repeatsDaily: true,
                    recoveryReason: recoveryReason
                )
            }
        } catch {
            statusMessage = "新配置状态无法保存；监控未启动。"
            lastResult = "shared_diagnostic_write_failed"
            refreshExperimentState()
            return
        }

        // The new identity is committed before old registrations are retired.
        // A delayed old extension callback is stale even during this handoff.
        if !previousActivities.isEmpty { center.stopMonitoring(previousActivities) }
        guard !center.activities.contains(where: { previousActivities.contains($0) }) else {
            let code = "old_monitor_still_registered"
            try? pulseStore.update { $0.markRegistrationFailed(id: experimentID, errorCode: code) }
            lastErrorCode = code
            lastResult = "recovery_failed_no_retry_loop"
            statusMessage = "旧登记未能退出；没有启动新监控。"
            refreshExperimentState()
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: PulseDailySchedule.intervalStart,
            intervalEnd: PulseDailySchedule.intervalEnd,
            repeats: PulseDailySchedule.repeats
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
            guard center.activities.contains(activity), observedCount == plan.eventCount,
                  center.schedule(for: activity)?.repeats == true else {
                center.stopMonitoring([activity])
                let code = observedCount == plan.eventCount
                    ? "registered_schedule_mismatch" : "registered_event_count_mismatch"
                try? pulseStore.update { $0.markRegistrationFailed(id: experimentID, errorCode: code) }
                refreshExperimentState()
                lastErrorCode = code
                lastResult = "registration_not_confirmed"
                statusMessage = "监控返回成功，但系统登记数或重复日程与计划不符；已停止，请记录诊断。"
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
            lastResult = isMonitoring ? "recurring_registered_interval_start_separate" : "registration_not_confirmed"
            statusMessage = isMonitoring
                ? "重复日程已登记；请另看 interval generation/anchor，登记本身不证明当前 interval 已启动。"
                : "登记返回成功，但系统未确认完整重复日程；请查看脱敏诊断。"
            logger.notice("Recurring monitoring registration succeeded; current interval evidence separate")
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
        lastAction = "stop_monitoring"
        lastErrorCode = nil
        refreshExperimentState()
        guard let pulseStore, pulseStoreStatus == "ready" else {
            statusMessage = "共享状态不可写，不能确认关闭自动恢复意图。"
            lastResult = "shared_diagnostic_unavailable"
            return
        }
        let experimentID = pulseSnapshot.experimentID
        do {
            try pulseStore.update { snapshot in
                if let experimentID { snapshot.markStopped(id: experimentID) }
            }
        } catch {
            statusMessage = "停止意图未能保存；不能声称已停止。"
            lastResult = "stop_intent_save_failed"
            return
        }
        let owned = center.activities.filter {
            $0 == .elapseDaily || $0.rawValue.hasPrefix(PulsePlan.activityPrefix)
        }
        if !owned.isEmpty { center.stopMonitoring(owned) }
        refreshExperimentState()
        let stillRegistered = center.activities.contains {
            $0 == .elapseDaily || $0.rawValue.hasPrefix(PulsePlan.activityPrefix)
        }
        lastResult = !pulseSnapshot.monitoringDesired && !stillRegistered ? "stopped_desired_off" : "stop_unconfirmed"
        statusMessage = !pulseSnapshot.monitoringDesired && !stillRegistered
            ? "监控已停止，自动恢复意图关闭；旧回调仍会被隔离。"
            : "已请求停止，但状态未完全确认；请查看脱敏诊断。"
        logger.notice("Monitoring stop returned; desired=\(self.pulseSnapshot.monitoringDesired, privacy: .public)")
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
