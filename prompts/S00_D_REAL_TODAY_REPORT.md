# S00-D — 真实 Today 报表

Task ID: S00-D  
调度状态：以 `STATUS.md` 为准。本任务只有在 STATUS 标记 READY / IN_PROGRESS 时有效。  
Branch: `codex/s00-d-real-today-report`

## 目的

完成 S00 最后一块：**让用户在 Everwhile 内看到当前用户、当前 iPhone、今天截至当前时刻的真实 selected-App 使用汇总。**

本轮必须验证：

- selected Apps 的真实总时长；
- 每个 selected App 的真实日内总时长（Apple 允许的 report 环境内）；
- 小时聚合分布；
- 当前用户 / 当前设备 / 今天截至当前时刻的范围；
- 空数据 / 无可用 report data / 正常内容的真实语义；
- 不伪造精确 session；
- 不通过 App Group 或主 App 导出受保护 report 数据。

S00-D 通过后，S00 整体验收结束，才允许进入 S01。

## 已接受基线

不要重做 S00-A/B/C：

- Family Controls / App Group 最终分发签名已通过。
- individual authorization、选择持久化、普通通知已通过。
- shared selected-App pool 5–30 分钟有限实验已通过。
- callback/request 诊断、same-day experiment identity、stale/duplicate 语义已通过。
- 当前已安装并验收的 pulse build 是 Everwhile `0.1.0 (38.1)`。
- S00-C 云端审计：`audits/S00/S00_C_AUDIT_2026-10-04.md`。

持有人刚完成的 S00-C 实验发生在 2026-10-04 00:10–00:47 左右，两个 selected Apps 都有真实使用。因此 S00-D 应优先利用已有自然日数据验收，不再安排新的 30 分钟或全天人工刷 App。

## 当前 Apple API 事实

开始前用当前 Xcode SDK 与 Apple 官方文档重新核对，不从旧笔记猜。

当前公开 API 语义：

- `DeviceActivityReport` 的 filter 决定 report extension 收到的数据。
- `DeviceActivityFilter.users == nil` 表示当前用户。
- `DeviceActivityFilter.devices == nil` 表示当前设备。
- `DeviceActivityData` 表示某个人在某台设备上的 activity data。
- `.hourly(during:)` 是小时聚合。
- `ActivitySegment.totalActivityDuration` 是该 segment 的屏幕点亮时间，**不是 selected-App 使用时间**。
- selected-App 总量应来自过滤后的 `ApplicationActivity.totalActivityDuration`。
- Apple 的 `Label(ApplicationToken)` 是 baseline 的隐私保护 App 标签方式。
- 不依赖 EU-only enhanced app-and-website data access。

官方参考：
- https://developer.apple.com/documentation/deviceactivity/deviceactivityreport
- https://developer.apple.com/documentation/deviceactivity/deviceactivityfilter
- https://developer.apple.com/documentation/deviceactivity/deviceactivitydata
- https://developer.apple.com/documentation/deviceactivity/deviceactivitydata/activitysegment/totalactivityduration
- https://developer.apple.com/documentation/deviceactivity/deviceactivitydata/applicationactivity/totalactivityduration
- https://developer.apple.com/documentation/familycontrols/displayingactivitylabels

## 读取顺序

同步最新 main 后读取：

1. `AGENTS.md`
2. `STATUS.md`
3. `docs/WORKFLOW.md`
4. `docs/EXECUTION_PLAN.md`
5. `audits/S00/S00_C_AUDIT_2026-10-04.md`
6. 本任务
7. `App/ContentView.swift`
8. `ReportExtension/ElapseReportExtension.swift`
9. `Shared/TodayInterval.swift`
10. Today 相关 tests
11. `docs/APPLE_PLATFORM_NOTES.md` / current SDK symbols as needed

先检查是否已有 S00-D PR；若有，继续同一 PR。

## 第 0 步：先审现有 Today，不猜

当前实现已经有：

- `DeviceActivityReport(.elapseToday, filter: ...)`;
- hourly filter；
- per-app aggregation；
- per-app `Label(ApplicationToken)`；
- hourly selected-App buckets；
- “not exact session”的说明。

先静态确认：

1. 当前 filter 的 users/devices 实际值是什么；
2. 当前 initializer 是否默认 current user/current device；
3. 当前 Today interval 为什么是 start-of-day → next midnight，而不是 start-of-day → now；
4. 当前 report 如何区分：
   - 没有 DeviceActivityData；
   - 有 report data，但 selected Apps 今天为 0；
   - 正常非零内容；
5. 当前 UI 在 report 加载过程中由系统如何表现，API 是否给主 App 一个可靠的 loading/error callback；
6. 当前多 `DeviceActivityData` 结果是否可能被无意聚合成“这台 iPhone”。

把 SOURCE / SDK fact / DEVICE_OBSERVED 分开。

## 第 1 步：把 Today 范围固定为“当前用户 · 当前设备 · 今天截至现在”

Baseline S00-D **不要**使用 `.all` users 或 `.all` devices。

保持/明确：

- users: nil → current user；
- devices: nil → current device；
- applications: 当前 selected application tokens。

UI 必须明确告诉持有人这是：

**当前用户 · 当前 iPhone · 今天截至现在**

不要展示成“所有 Apple 设备今天总计”。

如果 current SDK 的 initializer/默认值与上述不一致，按当前 SDK 修正并在报告中记录。

## 第 2 步：修正 Today 时间窗

当前 `TodayInterval.make` 是 start-of-day → next midnight。

S00-D 改为：

**当前 Calendar 的 startOfDay → now**

原因：

- 这是“今天截至当前时刻”，不是未来尚未发生的整天；
- 与 Apple `.hourly(during:)` 的当前日聚合语义一致；
- 避免未来小时被误解成“空数据”。

增加纯逻辑测试：

- 普通日期 start = 当地 00:00，end = supplied now；
- 不强行假设每天 24h；
- 至少覆盖一个 DST 变化日，避免 `24*60*60` 这种错误恒等式；
- timezone 使用传入 Calendar，不硬编码设备外部时区。

不要拿 monitoring experiment 的 start time 替换自然日 Today。

## 第 3 步：真实聚合必须继续留在 Report extension

保持隐私边界：

- per-app duration、hourly bucket、device/user report info 只在 DeviceActivityReport extension 内聚合/呈现；
- **禁止**把 report usage 数据写进 S00-B/C 的 App Group；
- 禁止把 tokens、App 名称、bundle ID、hourly usage 或总时长回传主 App；
- 不新增 cloud/server/export。

主 App 只负责 selection + filter + host。

这条是硬 gate。

## 第 4 步：明确三类 report 状态

不要把“空白”直接解释成 0 分钟。

在 report extension 内，至少区分：

### A. 正常内容
系统返回当前 user/device 的 report data，且 selected applications 有 activity。

显示：

- Today selected-app total；
- per-app rows；
- hourly selected-app usage；
- report last-updated time（如果 current API 提供且语义明确）。

### B. 真正的 selected-App 0 usage
系统确实返回当前 user/device report data，但过滤后的 selected Apps 没有 application activity。

显示明确的：

**今天截至目前没有可显示的所选 App 使用记录。**

不要用空白页面。

### C. 没有 report data / scope unavailable
异步结果没有提供当前 user/device 的 report data，或当前 SDK 提供可判定的 unavailable/error 状态。

显示不同于“0 usage”的说明，例如：

**当前还没有可用的屏幕使用时间报告数据。**

若 `DeviceActivityReportScene` 当前 API 无法提供可靠的主 App loading/error completion hook：

- 不发明假的 loading 完成状态；
- 记录为 `SYSTEM_MANAGED_LOADING`；
- 可在 host/report UI 给静态“报告可能需要片刻更新”的说明；
- device acceptance 记录实际加载行为。

不要用 App Group 绕 report sandbox 来做 loading handshake。

## 第 5 步：聚合正确性

现有方向正确：按过滤后的 `ApplicationActivity.totalActivityDuration` 求 selected-App 使用。

必须继续保证：

- total selected usage = per-app duration 的和；
- hourly bucket = 每个 hourly segment 内 selected application activities 的和；
- **不使用** `ActivitySegment.totalActivityDuration` 作为 selected-App 总量；
- 多个 segment 正确累加同一个 App；
- 如果意外收到多个 DeviceActivityData，必须明确它们的 user/device scope，再决定是否合并；不能静默把多设备汇总后仍标“This iPhone”。

把可测试的 aggregation/formatting/date logic 尽量抽成纯逻辑测试。

不要为了单测伪造 Apple 的 protected runtime data。

## 第 6 步：呈现边界

Today UI 至少包括：

- “今天截至现在”的 selected Apps 总时长；
- 每 App 一行，使用 Apple's opaque `Label(ApplicationToken)`；
- 每 App 时长；
- hourly aggregate；
- 明确文案：**小时汇总，不是精确打开/关闭时间线**；
- 当前 user/device scope；
- last-updated（若 API 可用且经过验证）；
- zero / unavailable 文案。

不显示：

- fabricated exact sessions；
- callback count × 5 minutes；
- productivity score；
- judgment / guilt；
- bundle identifier；
- exported usage JSON。

## 第 7 步：自动验证先于真机

在让持有人打开 Today 前先完成：

- XcodeGen / app + extensions build；
-现有 Swift/Python tests 不回退；
- TodayInterval 新测试；
-聚合/formatting 状态测试；
- Report extension compile；
- 如果只改 runtime/report code，准备新的 internal TestFlight build；
- 最终 Family Controls / App Group 签名检查仍不回退；
- processing/internal assignment 精确对应新 build。

如果主 App/Monitor App Group 没变化，不要无必要重配 Apple 后台。

## 第 8 步：最小真机验收，不再做长时间使用实验

优先利用今天已经存在的 S00-C 数据。

Codex 在同一对话中一次一个动作带测。

### 设备验收 1：正常真实内容

1. 确认精确新 version/build。
2. 保持当前两个 selected Apps。
3. 打开 Today。
4. 等待实际 system/report 加载。
5. 持有人只需自然语言确认：
   - 页面不是空白；
   - scope 明确是当前用户/当前 iPhone/今天截至现在；
   - 两个 selected App 都有可见 App label/row（不要告诉 Codex App 名称）；
   - selected total 非零；
   - hourly 区域有真实非零 bucket；
   - 00:00 左右的 bucket 与刚完成的午夜后 S00-C 使用在方向上自洽；
   - UI 明确说 hourly aggregate，不是精确 session。

不要要求总分钟数必须等于 S00-C 的 30 分钟。Report 数据可能包含今天其他使用、系统更新延迟和不同聚合边界。

### 设备验收 2：数据口径

持有人只观察页面显示的：

- total；
- 两个 per-app durations；
- 至少一个非零 hourly bucket；
- last-updated（如有）。

Codex 可以让用户报告**大致数值或截图**，但：
- 不要求公开 App 身份；
- 不把这些数据提交公共仓库，除非持有人明确同意并脱敏；
- 不要求精确手工加总到秒。

如果能通过 UI 明显确认 total 与两个 per-app 行数量级一致即可；数学一致性由代码/测试负责。

### 空 / unavailable 状态

默认不要为了测试而：

- 撤销 Screen Time 授权；
- 清空系统 Screen Time；
- 等到第二天；
- 再刷一轮长时间 App。

zero / unavailable 状态优先由 SOURCE + TEST 证明。

只有发现真实设备页面仍会“空白但不知是 0 还是失败”时，才设计一个最小额外设备步骤。

## S00-D 必需 PASS 条件

云端审核前至少满足：

1. report scope 明确 current user + current device；
2. Today interval 是当地 start-of-day → now，并有 DST-safe tests；
3. 真实 38.1 后续新 build 在设备上成功渲染 nonzero selected-App report；
4. per-app rows 使用 opaque Apple labels；
5. total/per-app/hourly aggregation 来源正确；
6. hourly UI 明确不是 exact session；
7. zero usage 与 no report data 不再都表现为空白；
8. loading 若不可由 API可靠判定，则明确 `SYSTEM_MANAGED_LOADING`，不伪造状态；
9. report data 没有通过 App Group/主 App side channel 导出；
10. CI / signed artifact / TestFlight / device build 精确对应。

## 本轮不做

不做：

- 30 分钟以上 pulse；
- all-day threshold loop；
- configurable interval；
-跨日/重启/撤权恢复；
- exact session timeline；
- structured usage export；
- EU-only enhanced data access；
- Watch；
- AI / cloud / account；
- public App Review / release。

## 交付

同一个 S00-D PR：

```text
reports/S00-D/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
  evidence/
```

记录：

- base/code/tested/upload SHA；
- version/build；
- current SDK/API findings；
- filter users/devices scope；
- Today interval；
- aggregation provenance；
- normal / zero / unavailable / loading semantics；
- CI / signed IPA / TestFlight；
- minimal owner Today observations；
- 哪些为 SOURCE / UNIT_TEST / SIGNED_ARTIFACT / APPLE_PROCESSING / OWNER_REPORT / OWNER_SCREENSHOT / SYSTEM_MANAGED / NOT_RUN。

完成后停在 `READY_FOR_AUDIT`。

不要自批、不要 merge、不要解锁 S01。
