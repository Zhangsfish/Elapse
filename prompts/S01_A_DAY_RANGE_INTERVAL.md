# S01-A — 日内全天范围与可配置间隔基础

Task ID: S01-A
调度状态：以 `STATUS.md` 为准。本任务只有在 STATUS 标记 READY / IN_PROGRESS 时有效。
Branch: `codex/s01-a-day-range-interval`

## 目的

把 S00 的“固定 5 分钟、只到 30 分钟实验”升级为**可配置间隔的日内全天候 pulse 计划基础**，但本轮不承诺自动跨日、重启/撤权恢复或完整生产 UI。

S01-A 只回答三件事：
1. 默认 5 分钟但可配置的 interval 模型是否正确；
2. 一个 current-day monitoring registration 能否承载从 interval 开始直到整日尾部的大量 threshold events；
3. 这些大量 events 能否在真实 iPhone 上成功登记，而不要求持有人再做长时间刷 App。

本轮通过后再进入 S01-B 的自动跨日/重配/生命周期恢复。

## 已接受基线

不要重做 S00：
- S00-A/B/C/D 已全部云端审核通过。
- 当前已接受设备 build：Everwhile `0.1.0 (41.1)`。
- Family Controls / App Group / TestFlight 签名链已通过。
- shared selected-App pool、5–30 分钟 callback/request/visible pulse 已通过。
- Today current-user/current-iPhone real report 已通过。
- S00-D audit：`audits/S00/S00_D_AUDIT_2026-10-04.md`。

Today 的视觉“毛坯”和亚分钟显示精度是 S02 候选，不在 S01-A 顺手重做。

## Apple 当前约束

先用当前 SDK/官方文档复核，再实现。

已知公开约束：
- `DeviceActivityCenter.MonitoringError.excessiveActivities`：一个 app + extensions 同时最多监控 20 个 activities。
- schedule interval 最短 15 分钟。
- `DeviceActivitySchedule(repeats:)` 支持 recurring schedule。
- `DeviceActivityEvent` threshold 在 activity 的 scheduled interval 内累计指定 applications/categories/web domains。
- Apple 当前公开文档没有给出每个 activity 的 event dictionary 数量上限。

因此：不要因为只使用一个 activity 就假设 5 分钟 × 全天的大 event ladder 一定可行。必须在目标 iPhone 上证明“登记成功”。

## 阶段拆分边界

S01 现在分为：
- **S01-A**：日内全天 threshold plan + interval 配置 + 大 event ladder 注册可行性；
- **S01-B**：自动跨日 / config change / app & device restart / permission revoke-regrant 恢复；
- **S01-C**：自然日 rollover、时区/DST 与持续使用验收。

S01-A 不因为 schedule 能注册就宣称 S01 全部通过。

## 读取顺序

同步最新 main 后读取：
1. `AGENTS.md`
2. `STATUS.md`
3. `docs/WORKFLOW.md`
4. `docs/EXECUTION_PLAN.md`
5. `audits/S00/S00_D_AUDIT_2026-10-04.md`
6. 本任务
7. `Shared/PulsePlan.swift`
8. `Shared/PulseExperiment.swift` / store
9. `App/ElapseModel.swift`
10. Monitor extension
11. current tests and workflows

先检查是否已有 S01-A PR；若有，继续同一个 PR。

## 第 0 步：把“实验常量”和“产品配置”分开

当前 `PulsePlan` 写死 interval=5、maximum=30，UI/diagnostic 遍历固定六档。

不要直接把 `maximumTestMinutes = 30` 改成 1440/1500 就结束。

建立清楚的 product planning model，例如：
- configured interval；
- supported interval values / validation；
- current-day threshold ladder；
- event count；
- current configuration identity。

MVP interval 至少支持：**5 / 10 / 15 / 30 / 60 分钟**，默认仍是 **5 分钟**。

如果选择支持更细的 5-minute step（5…60），必须有同等测试；不要支持 1 分钟等未经产品确认的高频值。

interval 选择存本机 app-owned configuration；不上传云端。

## 第 1 步：生成日内全天 threshold ladder

目标是覆盖一个本地 calendar day 内的 selected-App usage，而不是只到 30 分钟。

要求：
- 同一 selected-App token set 仍是一个共享池；
- threshold 从 configured interval 递增；
- 不从 callback count 反推权威 usage；
- event name 可以可靠 round-trip 到 minutes；
- event parser 不再依赖固定六档；
- 一个配置下每个 threshold receipt 独立；
- 新 configuration identity 不继承旧 config receipts。

不要硬编码“每天恰好 24 小时”作为未来跨日真理。

S01-A 的候选 event ladder应覆盖普通日全部合理阈值，并显式分析 23h/25h DST day。

优先尝试一个 activity 内覆盖到 **25 小时边界之前的最后一个完整 interval**，例如 5-minute config 最多到 1495 分钟。

但是 Apple 没公开 event-count 上限。如果如此大的 dictionary 在 CI 或真机 registration 不可行：
- 停下来记录准确失败；
- 不要临时发明复杂 rolling re-registration 并混进本任务；
- 回云端重新设计 S01-A round 2。

## 第 2 步：诊断结构不能因为数百 event 爆炸

当前 S00-C UI 会遍历六个 threshold。

S01-A 不能在 UI 上渲染数百行。

保留 app-owned 可观察性，但改成可扩展摘要，例如：
- configured interval；
- planned threshold count；
- monitoring configuration short ID；
- current registration state；
- most recent accepted threshold；
- next planned threshold（只代表 plan，不冒充系统计量）；
- callback/request failure counters；
- stale/duplicate counters；
- 最近少量 threshold diagnostics（如需要）。

App Group 继续只保存 app-owned config/diagnostics，不得保存 selected tokens、App names/bundle IDs、Today/report usage 或 exact sessions。

## 第 3 步：interval/config 变更必须显式

S01-A 采用简单策略：**监控运行时 interval 和 selected Apps 都锁定；要修改先 Stop。**

Stop 后修改 interval/selection，再 Start 时：
- 新 configuration UUID；
- 新 threshold plan；
- 旧 callback/completion 仍按 identity fail closed；
- 不复用旧 receipt。

不要在本轮做自动热切换。

## 第 4 步：通知口径与 Today 解耦

S01-A pulse 不应声称自己等于 Today report 总量。

本轮 pulse 使用不依赖自然日总量的安全表述，例如：
- title: `15 分钟`
- body: `所选 App 使用已达到本轮的 15 分钟提醒点。`

不要写“今天总计 15 分钟”，也不要把 callback 间隔写成精确 usage。

Today 继续是自然日真实聚合的唯一权威显示。

## 第 5 步：自动验证

至少新增测试覆盖：
- interval validation / default；
- 5/10/15/30/60 threshold ladder；
- 5-minute candidate ladder 的 event count 和最大 threshold；
- event-name round trip across high thresholds；
- independent receipts across high threshold values；
- new config identity scopes/clears receipts；
- notification copy scope；
- scalable diagnostics summary；
- 25h planning 不等于“已经验证跨 DST”。

现有 S00 tests 不回退。

CI 必须继续 app + Monitor + Report build、signing helper tests、Family Controls/App Group generated entitlements，并保证 ReportExtension 不被破坏。

## 第 6 步：TestFlight 与最小真机验收

运行代码变更后准备新的 internal TestFlight build，复用现有签名/上传链。

### 本轮手机只做短操作，不刷全天

Codex 在同一对话一次一个动作。

目标设备验收：
1. 确认精确新 build。
2. 保持两个 selected Apps。
3. 选择默认 interval = 5。
4. Start。
5. UI 显示 config ID、interval=5、planned threshold count、registered、无 registration error。
6. 关闭重开 Everwhile，确认 registration/config 仍可读且没有自动创建另一个 config。
7. Stop。
8. 改成 15 分钟。
9. Start 新 config，确认 config ID 改变、planned event count 改变、registration 成功。
10. Stop，恢复默认 5 分钟，作为下一阶段基线。

**不要求等待 5/15 分钟 pulse。S00 已证明 callback 链路；本轮设备 gate 是“大 event ladder 能注册 + interval/config 状态正确”。**

如果默认 5-minute 全天 ladder 在真实设备 startMonitoring 失败：
- 记录 exact safe error；
- 不让持有人继续测试；
- 不退回 30 分钟假装成功；
- 状态改为 BLOCKED_DESIGN / CHANGES_REQUESTED，等待云端决定 chunking 方案。

## S01-A 必需 PASS 条件

云端审核前至少：
1. product interval model 与 S00 fixed test constants 分离；
2. default 5，可配置至少 5/10/15/30/60；
3. full-day candidate threshold ladder 有 DST-aware planning说明；
4. 5-minute full-day candidate 在目标 iPhone registration 成功，或明确 BLOCKED with exact error；
5. scalable diagnostics，不渲染数百行；
6. config/selection change 不静默漂移；
7. old callbacks/completions 仍 fail closed；
8. pulse 文案不冒充 Today；
9. CI / signed IPA / TestFlight / exact device build 对应；
10. 无新的 report-data privacy side channel。

## 本轮明确不做

不做：
- 自动午夜 re-arm / rollover；
- phone reboot recovery；
- authorization revoke/regrant recovery；
- timezone-change recovery；
- DST 真机跨日；
- 一整天人工刷 App；
- Today 视觉重做；
- 竞品 UI 研究；
- S02 production polish；
- public release。

## 交付

同一个 S01-A PR：

`reports/S01-A/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
  evidence/`

记录 base/code/tested/upload SHA、version/build、interval model、5-minute full-day candidate event count、max threshold、Apple limit findings、actual device registration result、5→15→5 config observations和各证据层级。

完成后停在 `READY_FOR_AUDIT`。

不要自批、不要 merge、不要解锁 S01-B。
