# S00 可测试性复核与工作流重置

Date: 2026-10-03
Verdict: **CHANGES_REQUESTED — 基础功能与最终签名待验；仅 S00-A READY**

这是静态代码/流程复核，不是新的 iPhone 实验，也没有重新证明签名成功。

## 审查基线与来源

- 审查 main：`afb4a61a2e62e849b5c6e831367c90d9f2983726`。
- build 19.1 实现：`60a15650d6791ef081f6d8aa402cfb48d3a03ff1`。GitHub compare 显示至审查 main 只新增三个文档的修改，没有 App 运行代码变化。
- 已读取 `App/ContentView.swift`、`App/ElapseModel.swift`、`App/ElapseApp.swift`、`MonitorExtension/ElapseMonitorExtension.swift`、`ReportExtension/ElapseReportExtension.swift`、`Shared/PulsePlan.swift`、`Tests/PulsePlanTests.swift`、`project.yml`、现有状态/平台/任务文档及上下文中的发布脚本。
- 协作参考：`Zhangsfish/lecture-asset/AGENTS.md`、`docs/WORKFLOW.md`、`tasks/S00_DEVICE_ACCEPTANCE.md`、当前 `STATUS.md`。
- 已有发布证据：run 37105502155 的日志曾记录 `S00_TF_EXPORT_UPLOAD_ACCEPTED` 与 `S00_TF_PROCESSING_STATUS_VALID build=19.1`。这条历史事实保留。
- **持有人随后提供的 Apple 邮件截图**：Everwhile `0.1.0 (19.1)`、`ITMS-90897`，主 App `Elapse.app` 缺 `com.apple.developer.family-controls`，分别因包含 Report 与 Monitor 扩展而提示。该观察来源是会话截图，不声称已经从 CI 再现。
- 持有人已经报告安装完成；尚未报告授权、选择、阈值、普通通知或 Today 的验收结果。

## 现有实现，不等于验收

| 能力 | 静态代码情况 | 当前判定 |
|---|---|---|
| individual 授权、通知权限 | ContentView 按钮调用 ElapseModel 的真实 API | IMPLEMENTED / DEVICE_NOT_RUN |
| 系统 App picker 与本地选择保存 | FamilyActivityPicker + applicationTokens + PropertyList 编码到 UserDefaults | IMPLEMENTED / DEVICE_NOT_RUN |
| 所选池启动/停止 | 为每个阈值传入相同应用集合，调用 DeviceActivityCenter | IMPLEMENTED / DEVICE_NOT_RUN |
| 5–30 分钟通知路径 | PulsePlan 生成六个 events，Monitor 回调请求本地通知 | EXPERIMENTAL / DEVICE_NOT_RUN |
| Today 各 App 与小时条形图 | 主 App 宿主 + report 扩展聚合/标签 | IMPLEMENTED / DEVICE_NOT_RUN |
| 可配置间隔、30 分钟以上全天提醒、精确会话/结构化使用数据导出 | 当前没有实现完整产品路径 | NOT_IMPLEMENTED / NOT_BASELINE_FOR_EXPORT |

因此不能说“功能全不存在”，也不能说“已经好用”。现有源码是一套待验证原型。

## Findings

### F01 — P1：签名结论与 Apple 警告未闭环（S00-A）

`project.yml` 已有三份 `entitlements.properties`，但 19.1 仍收到主 App 缺权限警告。生成配置中有 key 或 profile 允许 key 都不足以证明最终二进制声明了 key。历史的“Family Controls 签名彻底修好”结论撤回；上传接受与 VALID 不撤回。

要求：检查生成文件、有效 CODE_SIGN_ENTITLEMENTS、最终 distribution-signed 三个主体与 profiles，并做解析器正/负例。不得把解析失败静默当 false 或 PASS。若新的 upload 会重签，说明并验证实际送交的产物，不能拿另一个导出包冒充。

Apple [TN3125](https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles) 区分 profile 的授权白名单与代码签名的实际 entitlement；[Family Controls 分发说明](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement) 要求主 App/相关扩展配置。

### F02 — P1：原清单要求看扩展日志，但此交互路径不可取得（S00-B）

Monitor 的回调/通知请求结果只有 OSLog；主 App 的 `Diagnostic` 仅显示 ElapseModel 的一个 statusMessage，未接入扩展日志。没有 App Group 或其他已实现的共享诊断路径。持有人是 Windows + iPhone/TestFlight，不能要求其读取 Mac Console/Xcode 日志或不存在的面板。

要求：在真实阈值带测之前提供本 App 脱敏事件可观察性。普通通知自检放在 S00-A，只证明通知路径，不冒充扩展回调。

### F03 — P1 静态风险：同日 stop/start 并非完整实验清零（S00-B）

`PulseDeliveryDecision.receiptKey` 仅含日期 + eventName；Monitor 用 extension 的 UserDefaults 持久去重。`stopMonitoring`/`startMonitoring` 没有清除此状态或生成实验版本。由代码推断：某阈值已请求成功后，同日新实验的相同 event 可能被旧记录抑制。尚未真机复现。

要求：用可区分的新实验/配置身份或其他可证实的最小方案修复，处理旧回调；增加同日重启及重复回调测试。旧“停止再开始等于完整清零”的带测说明不再有效。

### F04 — P1 静态风险：运行中更改选择会造成配置不一致（S00-B）

picker 没有随 isMonitoring 禁用；selection.didSet 只保存，不更新已登记 events。Today 接收当前 selection，监控却可能仍用旧集合。

要求：明确禁止运行中修改或显式重启配置，不能默默展示两套集合；真实验证后再宣称一致。

### F05 — P2：阈值通知与 Today 的时间口径不同（S00-B/D）

monitor 使用 `includesPastActivity=false`，文字却说 `...minutes today`；Today 查询自然日。S00 应将实验起点/阈值说明清楚，不把从启动起的阈值说成权威当天总计。依据：`ElapseModel.startMonitoring`、`PulseNotificationCopy.safeThresholdCopy`、`TodayReportView.filter`；Apple [includesPastActivity](https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/includespastactivity)。

### F06 — P2：全天循环尚不存在（S01）

`PulsePlan.intervalMinutes=5`、`maximumTestMinutes=30`；注册六个阈值后没有 35/40/.../120 分钟事件。不能声称“每隔五分钟全天提醒”。全天覆盖、配置间隔、重启/跨日/时区恢复留到 S01，并用真机证据定义支持范围。

### F07 — P2：保存失败提示可能被立即覆盖（S00-A）

`selection.didSet` 中 `persistSelection()` 可能设置错误，下一行又将 `statusMessage=nil`。需保留可读失败状态并给纯逻辑/针对性测试。

### F08 — P2：报表需要独立验收（S00-D）

当前有各 App 总量与小时条形图，不是假界面；但未验收实际加载。主 App 未明确限定 report 设备范围，也未实现可区分的超时/不可用状态。不能把空白当作零使用，不能凭源码宣称这台手机的真实时长已正确呈现。

## 流程修正

之前云端连续改实现、直接带持有人测完整链路，并把每次 CI 通过理解为可继续叠加，是错误的执行分工。此轮只改规划/审计/调度文档，不改 Swift、签名脚本或 workflow。

Codex 负责当前阶段实现、可安装版本和逐步带测；云端审核/派下一任务。当前先 S00-A，其他锁定。详细契约在 `docs/WORKFLOW.md`、`docs/EXECUTION_PLAN.md` 和 `prompts/S00_A_DEVICE_FOUNDATION.md`。

**当前不存在新的设备 PASS。旧发布日志是交付历史，不是完整功能验收。**
