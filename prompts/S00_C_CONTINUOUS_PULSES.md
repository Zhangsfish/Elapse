# S00-C — 10–30 分钟连续提醒与边界语义

Task ID: S00-C  
调度状态：以 `STATUS.md` 为准。本任务只有在 STATUS 标记 READY / IN_PROGRESS 时有效。  
Branch: `codex/s00-c-continuous-pulses`

## 目的

在已通过 S00-B 的实验身份、共享池与可观察诊断基础上，验证现有有限阈值序列：

**10 / 15 / 20 / 25 / 30 分钟。**

本轮重点不是“精确准点”，而是：

- 每个阈值属于同一个当前 experiment；
- 每个阈值最多请求一次正常 pulse；
- 两个所选 App 间切换不会重置共享累计池；
- callback 延迟或乱序时，诊断能如实记录而不是伪造精确时间；
- duplicate / stale / invalid callback 不产生额外 pulse；
- Stop 后当前 experiment 明确停止，selection 重新可改；之后若有旧 callback，只能按 stale 语义处理；
- UI 不再出现“已经收到 callback，却仍写等待真实回调”的自相矛盾。

Today / report 仍不属于本轮。

## 已接受基线

不要重做 S00-A / S00-B：

- S00-A：最终 Family Controls 分发签名、individual 授权、选择持久化、普通通知自检已通过。
- S00-B：32.1 的 App Group 最终签名已通过；experiment UUID、same-day restart、共享池第一个 5 分钟阈值、selection freeze 和 iPhone 可见诊断已通过。
- S00-B 云端审计：`audits/S00/S00_B_AUDIT_2026-10-03.md`。
- stale callback 在 S00-B 没有真机实际发生；其拒绝语义由 source + unit tests 接受。本轮也不要为了“制造 stale”去改系统时间、破坏系统状态或做不自然的设备操作。

## 读取顺序

同步最新 main 后读取：

1. `AGENTS.md`
2. `STATUS.md`
3. `docs/WORKFLOW.md`
4. `docs/EXECUTION_PLAN.md`
5. `audits/S00/S00_B_AUDIT_2026-10-03.md`
6. 本任务
7. 当前 `PulseExperiment` / `PulseExperimentStore` / `PulsePlan`
8. Monitor extension、主 App 诊断 UI 和相关 tests

先检查是否已有 S00-C PR；若存在，继续同一 PR。

## 第 0 步：确认当前事实

先静态确认：

- threshold 列表仍为 5/10/15/20/25/30；
- 所有 threshold event 使用同一 selected application token 集合；
- Monitor 对 10–30 分钟现在是否实际会请求通知；
- 当前共享诊断为什么只完整暴露 5 分钟，而不能逐阈值审核 10–30；
- duplicate / stale / request failure 对 10–30 是否与 5 分钟拥有同样 fail-closed 语义。

不要拿“代码里有六个 event”冒充真机 10–30 PASS。

## 第 1 步：把诊断从 5 分钟推广到整个有限序列

当前 S00-B 诊断只对五分钟有专门 callback/request 字段。S00-C 需要在不扩大隐私面的前提下，为 5/10/15/20/25/30 每个阈值记录最小 app-owned 状态，例如：

- threshold minutes；
- current-experiment callback 是否收到；
- callback receivedAt；
- notification request: notRequested / submitting / accepted / failed；
- request completedAt；
- safe error code。

数据结构由你决定，但要求：

- 不存 selected token；
- 不存 App 名称 / bundle ID；
- 不存 DeviceActivityReport 数据；
- 不从 callback 数量推算“权威总时长”；
- 不伪造 app-open/app-close session；
- 可跨主 App / Monitor extension 安全读写；
- app relaunch 后仍可读取当前 experiment 的诊断。

UI 应能快速看出每个 threshold 的状态。不要做复杂图表。

同时修掉 S00-B note：一旦当前实验已经收到 callback，登记状态不要继续写“等待真实回调”。

## 第 2 步：阈值独立去重与迟到/乱序语义

增加/补足纯逻辑测试，至少覆盖：

- 5 → 10 → 15 → 20 → 25 → 30 各 threshold 第一次 callback 都各自可 request；
- 同一个 threshold 重复 callback 不二次 request；
- 一个 threshold 的 receipt 不会压掉另一个 threshold；
- 新 experiment 不继承旧 experiment 的任何 threshold receipt；
- stopped / failed / 非当前 experiment callback 均 stale，不 request；
- old experiment 的 notification completion 不改写 current experiment；
- notification request failure 只影响对应 threshold，并有明确可观察状态；
- 若 callback 到达顺序与理想顺序不同，系统记录**实际收到的 threshold 身份和时间**，不据此编造精确使用时长；
- invalid event 不产生 pulse。

不要通过修改系统时钟模拟使用量。

## 第 3 步：保持通知文案克制且口径正确

每个 threshold 的文案继续表示：

“所选 App 自本次监控开始后已达到 N 分钟。”

不要使用：

- 今天总计（除非由 report 独立证明）；
- 浪费/失控/该停了；
- “过去五分钟精确用了五分钟”这类 callback 无法证明的表述。

5 分钟是实验序列的一部分，不是品牌身份。

## 第 4 步：自动验证先于长时间真机测试

在要求持有人做 30 分钟实验前，先完成：

- Simulator / feasible Release build；
- 现有 tests 不回退；
- 新逐阈值诊断 tests；
- duplicate/stale/out-of-order/request-failure tests；
- selection/config consistency 不回退；
- App Group 隐私边界不扩大；
- 若 App/Monitor entitlement 或签名相关文件有改动，重新完成生成后与最终 distribution-signed IPA 检查。

若运行代码有变化，就准备新的 internal TestFlight build，并确认精确 version/build 已在内部组可用。

不要让持有人手动点 Actions。

## 第 5 步：真机——一个连续实验完成主要验收

尽量只用**一个新的当前 experiment**完成 10–30 分钟主要验收，减少持有人负担。

### 准备

确认：

- 精确 version/build；
- Screen Time / 通知仍可用；
- exactly 2 selected Apps；
- shared diagnostic store ready；
- 当前没有旧 experiment 正在运行。

### 连续使用

开始一个新 experiment。

持有人在两个所选 App 间正常切换，使所选池累计从 0 继续到约 30 分钟。至少在实验过程中切换两次 App，避免只验证单 App。

在 10 / 15 / 20 / 25 / 30 分钟附近：

- 观察是否出现对应 pulse；
- 回到 Everwhile / 刷新诊断时，核对该 threshold：
  - current-experiment callback 是否收到；
  - notification request 是否 accepted/failed；
  - duplicate/stale 计数是否出现变化；
- 记录大致墙钟偏差即可。

**不要要求持有人精确掐秒。**  
DeviceActivity callback 可能延迟。记录真实观察，不把“约 15 分钟”写成“15:00 精确触发”。

如果某次 banner 没看到：

- 先看 callback；
- 再看 request result；
- 区分 callback 未到 / request failed / request accepted 但 banner 未观察；
- 不直接把“没看到 banner”写成“没 callback”。

### 切换语义

实验期间 selection 必须继续锁定。

App A ↔ App B 的切换不应生成新的 experiment，也不应把累计阈值从头开始。

## 第 6 步：停止 / 迟到 / 重复语义

30 分钟主要实验完成后 Stop：

- 当前 activity 不再登记；
- experiment phase 变 stopped；
- selection 恢复可改；
- Stop 不宣称 OS 永远不会再送旧 callback。

不要求持有人故意制造迟到或 duplicate callback。

如果设备自然出现：

- duplicate；
- delayed old callback；
- banner 延迟；

如实记录并验证对应诊断。

如果设备没有自然出现，duplicate/stale/late completion 的拒绝语义可以由 SOURCE + UNIT_TEST 作为本阶段证据，但报告必须明确不是 DEVICE_OBSERVED。

## S00-C 必需 PASS 条件

云端审核前至少满足：

1. 10/15/20/25/30 都有逐阈值 app-owned callback/request 诊断能力；
2. unit tests 覆盖每阈值独立 receipt、duplicate、stale、request failure 与乱序记录；
3. 一个真实当前 experiment 中，两个所选 App 间切换后，10–30 的阈值序列得到设备证据；
4. 每个阈值的 callback / request 与 visible pulse 分层记录，不把一个层级冒充另一个；
5. 不宣称秒级准点；
6. selection 在 experiment 期间不漂移；
7. Stop 后 phase / registration / selection 状态正确；
8. 若设备没有产生 stale/duplicate，报告明确写 SOURCE/UNIT_TEST only；
9. 对应运行代码、CI、TestFlight build、设备观察 SHA 精确对应。

缺必需 evidence 就不要标 READY_FOR_AUDIT。

## 本轮不做

不做：

- 30 分钟以上全天循环；
- interval 配置产品化；
- Today report 真机验收/重构；
- 精确 session timeline；
- 结构化 Screen Time 数据导出；
- Watch；
- AI；
- 账号/云端；
- App Review / 公开上架。

## 交付

同一个 S00-C PR 中提交：

```text
reports/S00-C/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
  evidence/
```

记录：

- base/code/tested/upload SHA；
- PR head；
- version/build；
- CI / TestFlight run；
- 每个 threshold 5/10/15/20/25/30 的 callback/request/visible observation；
- App 切换事实；
- Stop 结果；
- duplicate/stale/late semantics 的证据层级；
- 大致延迟，但不伪造精确 Screen Time；
- SOURCE / UNIT_TEST / SIGNED_ARTIFACT / APPLE_PROCESSING / OWNER_REPORT / OWNER_SCREENSHOT / NOT_RUN。

完成后停在 `READY_FOR_AUDIT`。

不要自批、不要 merge、不要解锁 S00-D。
