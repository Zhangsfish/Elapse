import DeviceActivity
import FamilyControls
import Foundation
import OSLog
import UserNotifications

@MainActor
final class ElapseModel: ObservableObject {
    @Published var selection: FamilyActivitySelection {
        didSet {
            guard selection != oldValue else { return }
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
    }
    @Published private(set) var authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @Published private(set) var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var notificationAlertSetting: UNNotificationSetting = .notSupported
    @Published private(set) var isMonitoring = false
    @Published var statusMessage: String?
    @Published private(set) var lastAction = "launch"
    @Published private(set) var lastResult = "not_run"
    @Published private(set) var lastErrorCode: String?

    private let center = DeviceActivityCenter()
    private let logger = Logger(subsystem: "com.zhangsfish.elapse", category: "setup")
    private let selectionKey = "elapse.familyActivitySelection"
    private let testNotificationID = "com.zhangsfish.elapse.s00a.ordinary-test"

    init() {
        let restored = Self.loadSelection(key: selectionKey)
        selection = restored.selection
        statusMessage = restored.message
        lastResult = restored.result
        isMonitoring = center.activities.contains(.elapseDaily)
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
        [
            "Everwhile=\(versionDescription)",
            "ScreenTime=\(authorizationDescription)",
            "NotificationAuthorization=\(notificationDescription)",
            "NotificationAlerts=\(notificationAlertDescription)",
            "SelectedApplications=\(selection.applicationTokens.count)",
            "SelectedCategories=\(selection.categoryTokens.count)",
            "SelectedWebDomains=\(selection.webDomainTokens.count)",
            "MonitorRegistration=\(isMonitoring ? "registered_not_verified" : "stopped")",
            "LastAction=\(lastAction)",
            "LastResult=\(lastResult)",
            "ErrorCode=\(lastErrorCode ?? "none")",
        ].joined(separator: "\n")
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
        isMonitoring = center.activities.contains(.elapseDaily)
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
        guard hasFamilyAuthorization else {
            statusMessage = "请先完成屏幕使用时间授权；未授权不能登记监控。"
            return
        }
        guard !selection.applicationTokens.isEmpty else {
            statusMessage = "请先选至少一个 App；类别或网站不计入本轮所选应用。"
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        let events = Dictionary(uniqueKeysWithValues: PulsePlan.thresholdMinutes.map { minutes in
            let name = DeviceActivityEvent.Name(PulsePlan.eventName(for: minutes))
            let event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                threshold: DateComponents(minute: minutes),
                includesPastActivity: false
            )
            return (name, event)
        })

        logger.notice("Starting daily monitor with \(self.selection.applicationTokens.count, privacy: .public) opaque application tokens and events: \(events.keys.map(\.rawValue).sorted().joined(separator: ","), privacy: .public)")
        do {
            try center.startMonitoring(.elapseDaily, during: schedule, events: events)
            isMonitoring = true
            statusMessage = "监控登记成功；尚未证明收到使用时间回调。"
            logger.notice("Monitoring start succeeded; includesPastActivity=false")
        } catch {
            isMonitoring = center.activities.contains(.elapseDaily)
            lastErrorCode = FoundationFeedback.safeErrorCode(error)
            statusMessage = "监控登记失败（错误代码 \(lastErrorCode ?? "未知")）。"
            logger.error("Monitoring start failed; code=\(self.lastErrorCode ?? "unknown", privacy: .public)")
        }
    }

    func stopMonitoring() {
        logger.notice("Stopping daily monitor")
        center.stopMonitoring([.elapseDaily])
        isMonitoring = center.activities.contains(.elapseDaily)
        statusMessage = isMonitoring ? "已请求停止，但监控仍显示已登记。" : "监控已停止。"
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
