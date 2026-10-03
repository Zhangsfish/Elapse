# S00-B — 第一次真实 5 分钟共享池报时

Task ID: S00-B  
调度状态：以 `STATUS.md` 为准。本任务只有在 STATUS 标记 READY / IN_PROGRESS 时有效。  
Branch: `codex/s00-b-first-real-pulse`

## 目的

在已通过 S00-A 的 Everwhile 基础上，只证明第一条真实 Screen Time pulse：

**两个所选 App 属于同一个使用池，累计所选使用达到约 5 分钟后，系统回调链路可被实际观察，并请求一条克制的通知；同一天可以可靠地重新开始一次新的测试，不被旧去重状态或旧回调污染。**

本轮同时关闭 readiness review 已指出的三个 S00-B 阻塞：

1. 同日 stop/start 的实验身份与去重不安全；
2. 运行中修改 selection 会造成已登记监控集合与当前 UI selection 不一致；
3. Windows + iPhone/TestFlight 路径无法实际观察 extension callback / notification-request 结果。

S00-A 云端审计：`audits/S00/S00_A_AUDIT_2026-10-03.md`。

## 已接受的 S00-A 基线

不要重做 S00-A：

- Everwhile `0.1.0 (27.1)` 已由持有人安装并完成 S00-A 真机检查。
- 最终上传 IPA 已独立验证主 App、Monitor、Report 三主体 Family Controls code-signature claim 与 profile allowance。
- individual authorization PASS。
- 选择两个 App 并关闭/重开 App 后仍保留两个 PASS。
- 普通中文测试通知可见 PASS。
- 历史 19.1 的 ITMS-90897 不再作为当前 build 的未关闭签名阻塞。

持有人曾看到一次英文五分钟提醒。**不要把这条历史观察直接当作 S00-B PASS。** 本轮需要新的、结构化的共享池/可观察性/同日复测证据。

## 读取顺序

同步最新 main 后读取：

1. `AGENTS.md`
2. `STATUS.md`
3. `docs/WORKFLOW.md`
4. `docs/EXECUTION_PLAN.md`
5. `audits/S00/S00_A_AUDIT_2026-10-03.md`
6. 本任务
7. `App/ElapseModel.swift`
8. `MonitorExtension/ElapseMonitorExtension.swift`
9. `Shared/PulsePlan.swift` 与相关 tests
10. entitlement / project / workflow 文件，仅在本轮方案确实需要 capability 或签名变化时继续读取

先检查是否已有 S00-B PR。若存在，继续同一 PR，不新开平行实现。

## 第 0 步：先重现静态问题，不猜

确认当前代码实际行为：

- 当前所有阈值 event 是否使用同一个 application token 集合；
- 当前 receipt/dedup key 的组成；
- stop/start 后旧 receipt 是否仍可能抑制新的 5 分钟 event；
- selection 在 monitoring 期间是否仍可改变；
- Monitor extension 目前把 callback / notification request 结果记录在哪里；
- 持有人在 Windows + iPhone/TestFlight 条件下能否实际取得这些信息。

把 SOURCE 推断和 DEVICE_OBSERVED 分开。

## 第 1 步：建立可重复的“实验/配置身份”

同日第二次测试不能被第一次的 receipt 压掉，也不能把旧 callback 当成新实验。

选择最小、可解释的方案建立 session / experiment / configuration identity，并为以下行为增加纯逻辑测试：

- 新实验与旧实验 identity 不同；
- 同一实验的重复 callback 可去重；
- 新实验同一个 5 分钟 threshold 不被旧实验 receipt 抑制；
- 旧实验迟到 callback 不得冒充当前实验；
- app relaunch 后仍能判断哪个实验是当前实验；
- stop 后状态明确，不把“已调用 stop”写成“所有旧 callback 绝不可能再来”。

实现方式由你根据 Apple API 实际能力选择。不要用改系统时间、清全机 Screen Time、删除 App 数据等方式伪造可重复性。

如果需要 App Group，只允许共享本 App 自己的：

- current experiment/config ID；
- selected-token count / config version 等非识别性配置摘要；
- 脱敏 callback event；
- notification request 成功/失败分类。

**禁止**通过 App Group 搬运 DeviceActivityReport 的受保护使用数据、应用身份、token 或精确报告内容。

若 App Group 会引入新的 Apple 后台 capability，先完成所有可自动完成的源码/CI检查；只有自动签名/现有权限明确失败后，才向持有人提出一个最小后台动作，并给出具体 App ID / App Group / 错误。不要索取私钥、UDID 或重建现有凭据。

## 第 2 步：保证 selection 与登记配置一致

不能出现：

- UI 显示 selection B；
- DeviceActivityCenter 实际仍监控旧 selection A；
- Today 又读取 selection B。

本轮至少解决监控链路的配置一致性。

可选最小策略之一：

- monitoring 期间禁用“选择 App”，先 Stop 再改；或
- selection 改变时显式结束旧 experiment、创建新 identity 并重新登记。

无论选哪一种，UI 必须让持有人看得懂，tests 必须覆盖，不允许静默漂移。

本轮不要求重构 Today；S00-D 仍锁定。

## 第 3 步：提供持有人实际可取得的 callback / request 诊断

不能再把 extension OSLog 当验收路径。

在 iPhone/TestFlight + Windows 条件下，持有人必须能在 Everwhile 自己的 UI 或另一条明确可访问、脱敏的路径看到至少：

- current experiment/config ID 的短摘要或可区分编号；
- monitoring registration 状态；
- 5 分钟 threshold callback 是否已由 extension 收到；
- callback 对应的 event 是否属于当前 experiment；
- notification request 是 accepted 还是 failed；
- 失败时只显示安全错误分类/码。

**可见 banner 本身不能代替全部诊断。** 没看到 banner 时，必须能区分“没 callback / callback 到了但 request 失败 / request accepted 但用户没看到”。

不要显示 token、bundle ID、所选 App 名称、Apple 账号或其他 App 内容。

## 第 4 步：修正 5 分钟通知口径

当前实验使用 `includesPastActivity=false`，因此 threshold 是**从本次 monitoring experiment 开始后的所选 App 累计使用**，不是自然日 Today 总量。

本轮 5 分钟文案不得把该值写成已知的“今天总计”。

文案保持 Everwhile 原则：

- 只报时；
- 不裁判；
- 不羞耻；
- 不要求反思。

例如可以表达“所选 App 自本次开始后已达到 5 分钟”，但不要承诺 callback 恰好准点，也不要把 callback 时间差伪装成精确使用时长。

## 第 5 步：自动验证先于真机等待

在要求持有人花 5–10 分钟真实使用之前，先完成：

- Simulator / feasible iPhone Release compile；
- 现有纯逻辑测试不回退；
- 新 experiment identity / stale callback / dedup tests；
- selection/config consistency tests；
- 诊断状态 tests；
- 如 capability/signing 有变化，重新验证生成后 entitlement、有效 Release wiring、最终 distribution-signed artifact；
- 必要时准备新的 internal TestFlight build，并确认 tester 可访问。

如果没有新 build，不要谎称旧 27.1 包含本轮改动。

若需要新 build，由你完成 CI / upload / processing / internal distribution；不要让持有人手动点 Actions。

## 第 6 步：由你在同一个 Codex 对话中一步一步带真机测试

一次只给持有人一个动作。收到自然语言观察后再继续。

### A. 准备

1. 确认本轮精确 version/build。
2. 确认 Screen Time 仍授权、通知可见。
3. 确认恰好两个 App 被选中。
4. 确认当前没有旧 experiment 正在运行。

不要要求持有人公开两个 App 的身份。

### B. 共享池第一次 5 分钟

设计一个低负担的真实测试，例如：

- 启动一个新 experiment；
- 先短暂保持锁屏或使用未选 App，确认不会因此出现“所选 App 已 5 分钟”的假 pulse；
- 所选 App A 使用约 2 分钟；
- 切到所选 App B 继续约 3 分钟；
- 等待合理的系统回调延迟。

不要宣称 2:00 + 3:00 必须在墙上时钟第 5:00 秒精确触发。

必需记录：

- A/B 是同一 selected pool；
- 第一次 5 分钟 callback 是否收到；
- callback 是否属于当前 experiment；
- notification request 是否 accepted；
- 用户是否实际看到 pulse；
- 大致延迟；
- 未选 App / 锁屏没有被描述为所选使用。

### C. 同日重新开始

停止当前 experiment，启动一个**新的 identity**，在同一天再次完成一次最小 5 分钟所选使用。

目的不是再证明产品“准点”，而是证明：

- 第二次实验不会被第一次 receipt 抑制；
- 旧 experiment callback 不会冒充新 experiment；
- 新实验仍能收到当前 5 分钟 callback 并独立请求通知。

若发生迟到/重复 callback，记录事实并按设计处理，不删日志、不修改系统时间掩盖。

### D. selection/config 一致性

在 monitoring 运行期间尝试进入 selection 路径，确认当前实现的策略：

- 若禁止修改，应明确不可改；
- 若允许显式重启，应明确告诉用户会结束旧 experiment 并创建新配置。

不要求测试 Today。

## S00-B 必需 PASS 条件

云端审核前至少有：

1. shared selected-App pool 的实现与 tests；
2. A ≈2 min + B ≈3 min 的一次真实 5 分钟设备证据；
3. 可访问的 callback / current-experiment / notification-request 诊断；
4. 同日新 experiment 的第二次真实 5 分钟不被旧 receipt 抑制；
5. stale callback 有明确拒绝或隔离语义；
6. selection 与已登记监控配置不会静默漂移；
7. 5 分钟通知口径不再把 monitoring-start 累计量冒充自然日 Today 总量；
8. 相关 CI / signing / distribution 证据与设备 build 精确对应。

缺任何一项就不要标 READY_FOR_AUDIT。

## 本轮不做

不做：

- 10/15/20/25/30 分钟完整序列验收；
- 30 分钟以上全天循环；
- interval 配置产品化；
- Today report 真机验收或重构；
- 精确 app-open/app-close session；
- 结构化 Screen Time 数据导出；
- Watch；
- AI；
- 账号/云端；
- App Review / 公开上架。

这些仍由后续阶段处理。

## 交付

同一个 S00-B PR 中提交：

```text
reports/S00-B/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
  evidence/
```

记录：

- base/code/tested/upload SHA；
- PR head；
- version/build；
- CI / workflow run URL；
- experiment identity 设计与隐私边界；
- callback / request 可观察路径；
- 两轮 5 分钟设备结果；
- selection/config consistency；
- stale/duplicate behavior；
- 每一项证据来源：SOURCE / GENERATED / SIGNED_ARTIFACT / APPLE_PROCESSING / OWNER_REPORT / OWNER_SCREENSHOT / NOT_RUN。

设备截图未经持有人明确同意不要提交公开仓库。自然语言观察由你整理。

完成后停在：

`READY_FOR_AUDIT`

不要自批、不要 merge、不要解锁 S00-C。
