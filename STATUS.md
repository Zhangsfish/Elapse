# STATUS

Updated: 2026-10-04

## 当前结论

**S00-A COMPLETE — PASS_WITH_NOTES。S00-B COMPLETE — PASS_WITH_NOTES。S00-C COMPLETE — PASS_WITH_NOTES。S00-D READY_FOR_AUDIT；S01 及之后阶段 LOCKED。**

S00-C PR #16 的精确 head `35f5102fa2ec98df0729e601663ecbdb2a5b01ce` 已由云端独立审核并合并为 `bba53845b78eb657b0daa29019abb202a29de81a`。审计见 [S00-C cloud audit](audits/S00/S00_C_AUDIT_2026-10-04.md)。

Everwhile `0.1.0 (38.1)` 现作为已接受的 S00-C 基线：

- 5/10/15/20/25/30 六档拥有独立 callback/request/error 诊断；
- legacy 32.1 shared-state 迁移与 malformed state fail-closed 已覆盖；
- duplicate/stale/invalid/out-of-order/request-failure/late-completion 语义有 SOURCE + UNIT_TEST；
- 一个真机 experiment `0cb91a51` 六档均观察到 current callback、accepted request 和 visible pulse；
- 持有人确认两个 selected Apps 至少切换两次；
- Stop 与 selection 解锁通过 owner report；
- 38.1 最终签名 / TestFlight / internal group 均通过。

六档 callback 时间戳不是权威 Screen Time 使用量或精确提醒延迟。

## 唯一当前任务

**[S00-D：真实 Today 报表](prompts/S00_D_REAL_TODAY_REPORT.md)**

Codex 的 [S00-D PR #17](https://github.com/Zhangsfish/Elapse/pull/17) 已完成源代码、自动验证和最小真机 Today 观察。新 build `0.1.0 (41.1)` 在 [upload run 37141044938](https://github.com/Zhangsfish/Elapse/actions/runs/37141044938) 中通过最终签名、上传、Apple processing `VALID` 和内部组分配。持有人在 41.1 上确认真实 Today 有内容、数值合理；截图显示当前用户 / 当前 iPhone、两个所选 App 的隐私保护标签与非零时长、非零午夜小时桶和“不是精确时间线”说明。**这是 OWNER_REPORT + OWNER_SCREENSHOT，不是 Codex 独立设备测量。** 空使用 / 无数据状态只有源码与测试，真机为 NOT_RUN；loading 由系统管理。S00-D 停在 `READY_FOR_AUDIT`，等待云端独立审核，不自行判定 PASS 或解锁 S01。证据见 [round-01](reports/S00-D/round-01/DELIVERY.md)。

本轮只解决：

- 当前用户 / 当前 iPhone；
- 今天当地 00:00 → 现在；
- selected-App 总时长；
- per-app 真实汇总；
- hourly aggregate；
- zero usage / no report data / system-managed loading 的真实语义；
- 不伪造 exact session；
- report usage 不通过 App Group 或主 App side channel 导出。

优先使用 2026-10-04 午夜后已经存在的 S00-C 真机使用数据，不再安排新的长时间刷 App。

## 已接受基线

| 项目 | 当前状态 | 证据 / 限制 |
|---|---|---|
| S00-A cloud audit | **PASS_WITH_NOTES** | `audits/S00/S00_A_AUDIT_2026-10-03.md` |
| S00-B cloud audit | **PASS_WITH_NOTES** | `audits/S00/S00_B_AUDIT_2026-10-03.md` |
| S00-C cloud audit | **PASS_WITH_NOTES** | `audits/S00/S00_C_AUDIT_2026-10-04.md` |
| 38.1 final signing / TestFlight | **PASS** | upload run 37134139991 |
| finite 5–30 pulse sequence | **PASS — OWNER + app diagnostics** | experiment `0cb91a51`;不声称精确延迟 |
| two selected-App switches | **PASS — OWNER_REPORT** | exact switch times 未记录 |
| Stop / selection unlock | **PASS — OWNER_REPORT** | 无 post-Stop copied diagnostic |
| stale/duplicate/late semantics | **PASS — SOURCE + UNIT_TEST** | 设备未自然发生 |
| real Today report | **READY_FOR_AUDIT / OWNER_REPORT + OWNER_SCREENSHOT** | 41.1 正常内容已观察；空状态真机 NOT_RUN |
| all-day / interval / lifecycle recovery | LOCKED | S01 |

## S00-C 审计 notes

- stale / duplicate / invalid / late completion 未在设备自然发生；拒绝语义不冒充 DEVICE_OBSERVED。
- 六档 timestamp 不能用来推导精确使用时长或 callback delay。
- Stop / selection unlock 只有 owner report，无 post-Stop diagnostic。
- S00-C 已完成有限 30 分钟长测；后续默认不再要求新的长时间/全天人工测试，除非有明确必要性并先说明。

## 调度表

| 阶段 | 状态 | 目的 |
|---|---|---|
| S00-A | **COMPLETE — PASS_WITH_NOTES** | 最终签名、授权、选择持久化、普通通知 |
| S00-B | **COMPLETE — PASS_WITH_NOTES** | 首个真实 5 分钟共享池、可观察诊断、同日复测 |
| S00-C | **COMPLETE — PASS_WITH_NOTES** | 5–30 分钟有限连续提醒、切换与边界语义 |
| S00-D | **READY_FOR_AUDIT** | 当前用户/设备的真实 Today、per-app 与 hourly aggregate；待云端审核 |
| S01 | LOCKED | 全天、间隔配置、跨日/重启/撤权/恢复 |
| S02 | LOCKED | 轻量正式体验与回顾呈现 |
| S03 | LOCKED / OWNER_RELEASE_REQUIRED | 公开分发准备 |

## 分工

Codex 负责 S00-D 实现、自动验证、必要的内部 TestFlight，并在同一 Codex 对话中用最小手机操作验收真实 Today。默认复用今天已有使用数据，不安排新的长时间刷 App。等待设备反馈为 `WAITING_FOR_OWNER_TEST`；完成后为 `READY_FOR_AUDIT`。

云端 ChatGPT 读取实际 diff、完整 ReportExtension 源码、CI/log、signed artifact、reports 与设备观察后给精确 SHA verdict；通过后由云端 merge 并判断 S00 整体验收是否完成，再决定是否解锁 S01。

持有人只做必要 iPhone / Apple 私密账号操作，不手动 merge、不手动点 Actions、不整理测试报告。

## 固定产品边界

只报时，不裁判。Today 只展示 Apple report 环境允许的真实聚合；不伪造 exact sessions，不从 callback 推导使用总量，不把 protected report data 通过 App Group 导出，不依赖 EU-only enhanced data access。

## 后续体验改进（非本轮实现／不解锁阶段）

持有人认为 41.1 Today 功能和数值可用，但视觉仍像“毛坯”。后续正式体验阶段应先研究优秀同类 App 的报表信息层级与可视化，再基于 Everwhile 的真实聚合数据改进图表、美感与可读性；避免为了好看伪造精确 session。具体观察与需求见 [S00-D UX follow-up](reports/S00-D/round-01/UX_FOLLOWUP.md)。该记录不构成 S02 已 READY。
