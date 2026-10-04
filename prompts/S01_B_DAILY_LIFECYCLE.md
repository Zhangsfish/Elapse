# S01-B — 每日重复调度与生命周期恢复

Task ID: S01-B
调度状态：以 `STATUS.md` 为准。本任务只有在 STATUS 标记 READY / IN_PROGRESS 时有效。
Branch: `codex/s01-b-daily-lifecycle`

## 目的

把 S01-A 已证明“能登记 299 个 events”的单日候选，升级成一个**不需要用户每天重新点 Start 的重复日程状态机**。

S01-B 只解决：

1. daily schedule 使用 `repeats=true`；
2. 每个 scheduled interval 有明确、可观察、幂等的 interval generation / anchor；
3. App 关闭重开与 iPhone reboot 后，监控状态不会静默漂移；
4. “用户希望保持监控”与“系统当前是否真的登记”分开保存；
5. authorization 变化时 fail closed，并保留可恢复意图；
6. 对物理上不可能过早到达的 threshold callback fail closed。

**本轮不要求等到午夜，也不要求全天刷 App。**
真正的自然午夜 rollover、permission revoke/regrant 实测、timezone/DST 实测留给 S01-C。

## 已接受基线

不要重做 S00 / S01-A：

- S00-A/B/C/D 已完成。
- S01-A cloud audit：`audits/S01/S01_A_AUDIT_2026-10-04.md`。
- Everwhile 44.1 已在目标 iPhone 上证明 5m 299/299、15m 99/99 events 可真实登记。
- interval 支持 5/10/15/30/60，默认 5。
- config identity、stop-first interval/selection、old callback/completion fail-closed 已通过。
- Today/report privacy boundary 不变。

## 当前 Apple API 事实

开始前用当前 SDK/Apple 官方文档再核对。

已确认的公开语义：

- `DeviceActivitySchedule(repeats: true)` 表示 schedule 递归。
- 如果调用 startMonitoring 时当前时间已位于 intervalStart/intervalEnd 之间，系统会立即调用 `intervalDidStart(for:)`。
- `DeviceActivityEvent` 的 threshold 是在 activity 的 scheduled interval 内累计。
- `AuthorizationCenter.authorizationStatus` 是可观察状态；系统可以因 Settings 等外部事件改变它。

官方参考：

- https://developer.apple.com/documentation/deviceactivity/deviceactivityschedule/init(intervalstart:intervalend:repeats:warningtime:)
- https://developer.apple.com/documentation/deviceactivity/deviceactivityevent/init(applications:categories:webdomains:threshold:includespastactivity:)
- https://developer.apple.com/documentation/familycontrols/authorizationcenter/authorizationstatus

当前 iOS 26 开发者社区存在“threshold callback 明显过早”的报告。论坛报告不是 API contract，但足以要求 Everwhile 对**物理上不可能的早到 callback fail closed**，不能把每个 callback 都当成权威 usage 证明。

## 阶段边界

S01-B = **实现 daily repeat + recovery machinery，并做短生命周期设备测试。**

S01-C 才做：
- 一个真实自然午夜 rollover；
- permission revoke/regrant 的真实设备验证；
- timezone/DST 行为与残余边界；
- 必要时的有限 callback sanity。

不要在 S01-B 偷跑 S01-C。

## 读取顺序

同步最新 main 后读取：

1. `AGENTS.md`
2. `STATUS.md`
3. `docs/WORKFLOW.md`
4. `docs/EXECUTION_PLAN.md`
5. `audits/S01/S01_A_AUDIT_2026-10-04.md`
6. 本任务
7. `Shared/PulsePlan.swift`
8. `Shared/PulseExperiment.swift`
9. `Shared/PulseExperimentStore.swift`
10. `App/ElapseModel.swift`
11. Monitor extension
12. lifecycle/plan tests

先检查是否已有 S01-B PR；若有，继续同一 PR。

## 第 0 步：先定义“用户意图”与“系统登记”两层状态

新增 app-owned desired state，例如：

- `monitoringDesired = true/false`
- configured interval
- selected-App count
- current config UUID
- lifecycle/recovery status

规则：

- 用户 Start 成功后：desired = true；
- 用户 Stop：desired = false；
- desired=false 时 App 不得偷偷自启；
- desired=true 不等于 system registered；
- UI 必须分别显示 desired state 和 actual DeviceActivity registration。

不要用“snapshot phase=registered”冒充系统里真的还有 activity。

## 第 1 步：daily repeating schedule

将产品级监控 schedule 改为 daily recurring：

- local 00:00 → 23:59:59；
- `repeats=true`；
- events 仍使用当前 interval 的 full-range ladder；
- `includesPastActivity=false` 保持。

S00 legacy fixtures 可保留用于迁移/测试，但产品路径必须使用 recurring schedule。

不要宣称 repeats=true 本身已经证明 midnight rollover；S01-C 真机再验。

## 第 2 步：interval lifecycle generation

在 App Group 的 app-owned snapshot 中加入最小生命周期状态，例如：

- current interval generation；
- current local-cycle key；
- interval anchor/start timestamp；
- last intervalDidStart timestamp；
- last intervalDidEnd timestamp；
- recovery count / last recovery reason；
- premature callback rejection count。

Monitor extension 覆盖：

- `intervalDidStart(for:)`
- `intervalDidEnd(for:)`

要求：

### intervalDidStart

只接受当前 config activity。

同一个 local-cycle key 重复收到 start callback 时必须幂等，不能重复清空状态或 generation++。

进入一个新的 scheduled interval 时：

- generation +1；
- 清空**本 interval** threshold diagnostics / receipt keys；
- 保留 config UUID / interval / plan；
- 记录 anchor；
- cumulative safety counters可以保留；
- UI 能看到新的 interval generation 与 anchor。

初次 Start 如果当前时间已经位于 interval 内，Apple 文档说 intervalDidStart 会立即调用；处理 main-app startMonitoring 与 extension callback 的竞争条件，不能因为 callback 比主 App markRegistered 更早就破坏状态。

### intervalDidEnd

只记录真实收到的 interval-end 状态。

不要把 intervalDidEnd 写成“下一天一定已经成功开始”。

## 第 3 步：物理下界 guard，拒绝不可能的早到 callback

对当前 interval 的 threshold N：

在发通知前除了现有 config/event/receipt 检查，还要求：

- 当前 interval anchor 已知；
- callback 到达时间不能早于 anchor + N 分钟的物理下界（允许一个很小、明确的 clock/callback tolerance）。

如果不满足：

- classified as `premature` / safe equivalent；
- 计数；
- **不发通知**；
- 不把它写成 accepted threshold；
- 不用 callback 条数推导 usage。

注意：

这只能防止“明显过早”或旧 interval 的早到残留，不是对 DeviceActivity 精确性的完整修复。非常晚到的旧 callback 仍可能在理论上无法区分，必须在报告中保留这个 OS ambiguity。

**不要**在本轮看到 early callback 后临时实现 rolling re-registration / local timer usage accounting；若真机自然出现 premature callback，记录并回云端审计。

## 第 4 步：reconcile 状态，解决 reboot / registration 丢失

当前代码存在一个必须关闭的边界：

snapshot 可能仍写 `registered`，但系统 activity 已不存在；此时 UI 不能永久锁死，也不能假装仍在监控。

实现一个清晰的 reconcile 流程，在 launch / foreground / explicit refresh 使用。

### desired=false

- Everwhile 不自动开始新 config；
- 清理属于 Everwhile 的 stray product monitoring activity（若有）；
- 状态显示 stopped。

### desired=true + authorization approved + exact system registration present

核对：

- current activity exists；
- event count == plannedEventCount；
- config identity / interval snapshot一致。

全部一致：保持同一 config，不创建新 UUID。

### desired=true + authorization approved + system registration missing/mismatched

自动恢复：

- retire old snapshot/config；
- 用本机已保存 selection + configured interval 创建**新 config UUID**；
- register recurring schedule；
- 再读回 activity/events count；
- 记录 recovery reason；
- 不声称恢复前那段使用被追溯补算，因为 `includesPastActivity=false`。

恢复失败则 fail closed，展示 safe error，不循环疯狂重试。

## 第 5 步：authorization 状态变化

使用 Apple 当前可观察 authorization status。

主 App 至少在 launch / foreground / status publisher change 时 reconcile。

当 authorization 从 approved/approvedWithDataAccess 变成 denied/notDetermined：

- 不再宣称 monitoring active；
- fail closed；
- 停止/退休可见的 Everwhile registration（能安全做到时）；
- 保留 desired intent，状态显示 `blocked_authorization` 或等价；
- 不自动弹授权 sheet；
- 不请求用户私密账号信息。

当以后重新 approved：

- 如果 desired=true，可按 reconcile 规则恢复成新 config；
- 如果 desired=false，不自动启动。

**S01-B 只用 SOURCE + UNIT_TEST 覆盖 revoke/regrant state machine。真实 revoke/regrant 设备测试留给 S01-C。**

## 第 6 步：诊断/UI

保持轻量，不做 S02 美化。

至少显示：

- desired monitoring on/off；
- current config short ID；
- interval；
- planned / system registered event count；
- recurring schedule yes/no；
- interval generation；
- interval anchor；
- last interval start/end；
- lifecycle state；
- recovery count / reason；
- premature callbacks rejected；
- registration safe error。

不要显示数百 threshold rows。

Today UI 继续不动。

## 第 7 步：自动测试

至少覆盖：

- repeats=true product schedule；
- initial intervalDidStart；
- duplicate intervalDidStart same cycle idempotent；
- new cycle resets interval receipts but preserves config；
- intervalDidEnd records but does not invent next start；
- premature 5/15/high-threshold callback rejected；
- callback at/after physical lower bound follows normal receipt logic；
- old config callback still stale；
- desired=false never auto-recovers；
- desired=true + exact registration keeps same config；
- desired=true + missing registration produces one recovery/new UUID；
- event-count mismatch recovery fail closed；
- authorization blocked / reapproved state transitions；
- no recovery loop on repeated refresh；
- legacy S00/S01-A snapshot migration remains readable。

现有 28+ tests 不回退。

## 第 8 步：TestFlight + 最小设备验收

运行代码变化后准备新 internal TestFlight build。

手机只做短生命周期测试，不等待使用阈值：

1. 确认精确 build。
2. 两个 selected Apps、interval=5。
3. Start。
4. 确认 299/299、desired=ON、recurring=YES、interval generation/anchor 已出现。
5. 关闭重开 Everwhile：同一 config ID，不应偷偷新建 config。
6. **重启 iPhone 一次**。
7. 重启后打开 Everwhile：
   - 如果系统 registration 仍存在：应保持同一 config + 299/299；
   - 如果系统 registration 丢失：应自动生成一个新 config，并明确显示 recovery reason + 299/299。
   两种都可 PASS，但必须如实记录实际路径。
8. Stop。
9. 确认 desired=OFF，interval 仍是 5，两个 selected Apps 保留。
10. 再关闭重开 App，确认不会因为旧 snapshot 自动复活 monitoring。

不需要等待 pulse。
不需要改系统时间。
不需要等午夜。
不需要撤销授权。

## S01-B 必需 PASS 条件

1. recurring daily schedule 已实现；
2. interval lifecycle generation/anchor 可观察、幂等；
3. premature callback fail-closed；
4. desired state 与 actual registration 分离；
5. launch/foreground reconcile 不漂移；
6. reboot 后 registration persistence 或自动 recovery 真实设备通过；
7. Stop 后不会自复活；
8. authorization recovery state machine 有 SOURCE + UNIT_TEST；
9. 44.1 已通过的大 ladder 能力不回退；
10. CI / signed IPA / TestFlight / exact device build 对应；
11. report privacy boundary 不变化。

## 本轮不做

不做：

- 等午夜真实 rollover；
- permission revoke/regrant 真机；
- timezone change 真机；
- DST 真机；
- 全天刷 App；
- Today 视觉重做；
- Shield/ManagedSettings；
- App 自动前台弹出；
- cloud/account/AI；
- public release。

## 交付

同一个 S01-B PR：

```text
reports/S01-B/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
  evidence/
```

记录 exact SHAs、version/build、schedule repeats、interval generation、premature guard、desired/reconcile state machine、reboot 实际路径、CI/TestFlight 和证据层级。

完成后停在 `READY_FOR_AUDIT`。

不要自批、不要 merge、不要解锁 S01-C。
