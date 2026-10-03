# STATUS

Updated: 2026-10-03

## 当前结论

**S00-A COMPLETE — PASS_WITH_NOTES。S00-B COMPLETE — PASS_WITH_NOTES。S00-C IN_PROGRESS；S00-D 及之后阶段 LOCKED。**

S00-C 实现分支：`codex/s00-c-continuous-pulses`，基于 `3fcaa287217399449b3dd2b10e6adba8280ebf2e`。当前正在完成六档诊断、边界测试与新的内部 TestFlight 准备；10–30 分钟真机序列尚未执行。进展见 `reports/S00-C/round-01/`。

S00-B PR #15 的精确 head `ee51be3d6e4b76246d5aecc85934c0e53fe33207` 已由云端独立审核并合并为 `0386ee9d35cf3046192a4b2f14d7f2243ebab08d`。审计见 [S00-B cloud audit](audits/S00/S00_B_AUDIT_2026-10-03.md)。

Everwhile `0.1.0 (32.1)` 现作为已接受的 S00-B 基线：

- main App + Monitor 的 App Group 最终签名 claim/profile allowance 已验证；
- Family Controls 最终签名仍通过；
- Apple processing `VALID / INTERNAL_ONLY / IN_BETA_TESTING`，已分配内部组；
- 每次 Start 使用独立 experiment UUID；
- stale / duplicate callback 及旧 experiment completion 具有 fail-closed 隔离语义；
- selection 在 experiment 运行时冻结，Stop 后恢复；
- App Group 只保存 app-owned 实验/诊断元数据，不保存 tokens、App 身份或 report 数据；
- 真机第一轮跨两个 selected App 在约五分钟累计后收到当前 experiment callback、accepted request 与 visible pulse；
- 同日新的第二个 experiment 也独立收到 callback/request/visible pulse，没有被旧 receipt 抑制。

持有人的 2:18 + 1:44 + 约 1 分钟仅作为近似观察，不是权威 Screen Time 秒级数据。

## 唯一当前任务

**[S00-C：10–30 分钟连续提醒与边界语义](prompts/S00_C_CONTINUOUS_PULSES.md)**

本轮只验证：

- 10 / 15 / 20 / 25 / 30 分钟当前 experiment threshold；
- 每个 threshold 的 callback / request 分层诊断；
- 两个 selected App 间切换时共享累计池不断裂；
- duplicate / stale / delayed / request-failure 的安全语义；
- Stop 与 selection 解锁；
- 不宣称系统秒级准点。

Today / S00-D 仍 LOCKED。

Codex 启动仍从 [handoff/CODEX_START.md](handoff/CODEX_START.md) 进入，并以本 STATUS 为调度权威。

## 已接受基线

| 项目 | 当前状态 | 证据 / 限制 |
|---|---|---|
| S00-A cloud audit | **PASS_WITH_NOTES** | `audits/S00/S00_A_AUDIT_2026-10-03.md` |
| S00-B cloud audit | **PASS_WITH_NOTES** | `audits/S00/S00_B_AUDIT_2026-10-03.md` |
| 32.1 App Group + Family Controls 最终签名 | **PASS** | upload run 37128996204 |
| 32.1 Apple processing / internal availability | **PASS** | VALID / INTERNAL_ONLY / IN_BETA_TESTING / internal group assigned |
| shared App pool first 5-minute threshold | **PASS — OWNER + app diagnostics** | experiment `5c520eb7`;近似时长，不声称秒级精度 |
| same-day fresh experiment | **PASS — OWNER + app diagnostics** | experiment `722d1c70` |
| stale callback rejection | **PASS — SOURCE + UNIT_TEST** | 设备测试中未自然发生 stale callback |
| selection/config consistency | **PASS** | running 时锁定 selection；Stop 后恢复 |
| 10–30 minute sequence | **NOT_RUN / S00-C** | 当前唯一 READY stage |
| Today real report | LOCKED | S00-D |
| all-day / configurable interval / recovery | LOCKED | S01 |

## S00-B 审计 notes

- 设备上没有自然出现 delayed stale callback；旧 callback / old completion 隔离由 SOURCE + UNIT_TEST 支持，不冒充 DEVICE_OBSERVED。
- 设备未记录 pulse 的精确文案；neutral monitoring-start copy 由 source + unit test 支持。
- 当前登记状态文案在 callback 已收到后仍可能显示“等待真实回调”；S00-C 扩展逐阈值诊断时一并清理。
- 设备墙钟用时都是近似值，不得写成权威 Screen Time 秒级用量或 callback 准点证明。

## 调度表

| 阶段 | 状态 | 目的 |
|---|---|---|
| S00-A | **COMPLETE — PASS_WITH_NOTES** | 最终签名、授权、选 App/保存、普通通知自检 |
| S00-B | **COMPLETE — PASS_WITH_NOTES** | 首个真实 5 分钟共享池、可观察诊断、同日可重试、配置一致性 |
| S00-C | **IN_PROGRESS** | 10–30 分钟连续提醒、切换、停止、迟到/重复语义 |
| S00-D | LOCKED | Today 的真实各 App 总量与小时汇总 |
| S01 | LOCKED | 全天、间隔配置、跨日/重启/撤权/恢复 |
| S02 | LOCKED | 轻量正式体验与回顾呈现 |
| S03 | LOCKED / OWNER_RELEASE_REQUIRED | 公开分发准备，非当前上架授权 |

## 分工

Codex 负责 S00-C 实现、自动验证、必要的内部 TestFlight，并在同一 Codex 对话中一次一个动作带持有人完成有限的 10–30 分钟真机验收。等待设备反馈为 `WAITING_FOR_OWNER_TEST`；必需证据完成后为 `READY_FOR_AUDIT`。

云端 ChatGPT 读取实际 diff、完整关键源码、CI/log、reports 和设备观察后给精确 SHA verdict；通过后由云端 merge 并只解锁 S00-D。

持有人只做必要 iPhone / Apple 私密账号动作，不手动 merge、不手动点 Actions、不整理测试报告。

## 固定产品边界

只报时，不裁判。无 block/shield、账号、云服务、AI、广告、评分、streak。不给 callback 条数伪造权威总量；不给小时桶伪造精确 session；不把 monitoring-start 累计量写成未经证明的自然日 Today 总量。
