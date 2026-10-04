# STATUS

Updated: 2026-10-04

## 当前结论

**S00 COMPLETE — PASS_WITH_NOTES。S01-A COMPLETE — PASS_WITH_NOTES。S01-B READY；S01-C / S02 / S03 LOCKED。**

S01-A PR #18 exact head `e7adced2834d3a4831d9b24ff6ae7dc421df68b5` 已由云端审核并合并为 `4fbb88be370e1481ec644a5cfbf7823680f0504e`。审计见 [S01-A cloud audit](audits/S01/S01_A_AUDIT_2026-10-04.md)。

Everwhile `0.1.0 (44.1)` 现作为 S01-A accepted baseline：

- default interval 5；支持 5/10/15/30/60；
- 5m full-range candidate = 299 events / max 1495m；
- 15m = 99 / 1485m；
- config identity、stop-first interval/selection 与 stale callback isolation 已通过；
- 目标 iPhone 真实登记 5m **299/299**、15m **99/99**；
- app reopen 保持 registration（OWNER_REPORT）；
- 最终 stopped、interval 恢复 5、selected Apps 仍为 2（OWNER_REPORT）；
- 44.1 signed IPA / TestFlight / internal assignment 通过。

S01-A 只证明大 event ladder 能登记，不证明全天所有 callback 或跨日 lifecycle。

## 唯一当前任务

**[S01-B：每日重复调度与生命周期恢复](prompts/S01_B_DAILY_LIFECYCLE.md)**

本轮只做：

- daily `repeats=true`；
- interval generation / anchor；
- physically-impossible premature callback fail-closed；
- desired monitoring state 与 actual system registration 分离；
- launch/foreground reconciliation；
- app reopen / iPhone reboot 后 persistence 或自动 recovery；
- authorization revoke/regrant state machine 只做 SOURCE + UNIT_TEST。

**本轮不等午夜、不撤权、不刷全天。**

## S01 拆分

| 阶段 | 状态 | 目的 |
|---|---|---|
| S01-A | COMPLETE — PASS_WITH_NOTES | full-range interval plan + 299-event registration feasibility |
| S01-B | **READY** | repeating daily schedule、lifecycle generation、reboot/reconcile recovery |
| S01-C | LOCKED | 真实午夜 rollover、permission revoke/regrant、timezone/DST 边界 |
| S02 | LOCKED | production UI / Today 可视化研究与体验 |
| S03 | LOCKED | public distribution |

## 当前可靠性边界

Apple 官方文档支持 recurring schedule，并说明当前时间落在 interval 内时 startMonitoring 会立即触发 intervalDidStart。

同时，2026 年 iOS 26 开发者报告存在 DeviceActivity threshold 过早 callback。论坛报告不是 API contract，但 Everwhile 必须 fail closed 对待物理上不可能的 early callback；不能因为系统 callback 到了就宣称权威 usage 达标。

## 已接受基线

| 项目 | 状态 |
|---|---|
| S00 functional acceptance | COMPLETE — PASS_WITH_NOTES |
| S01-A audit | COMPLETE — PASS_WITH_NOTES |
| accepted build | 0.1.0 (44.1) |
| 5m day-range registration | PASS — 299/299 target iPhone |
| 15m registration | PASS — 99/99 target iPhone |
| all-day callback reliability | NOT_PROVEN |
| automatic midnight rollover | NOT_IMPLEMENTED |
| reboot recovery | NOT_TESTED / S01-B |
| permission recovery device test | LOCKED / S01-C |

## 产品边界

全屏 Screen Time time-limit prompt 已由持有人确认是 iPhone 系统行为，不属于 Everwhile，也不作为产品功能。

Today 视觉“毛坯”与显示精度债务仍留给 S02，不在 S01-B 改 UI。

## 分工

Codex 完成 S01-B 实现/CI/TestFlight，并只带持有人做短的 reopen + 一次 iPhone reboot 验收。无需等待 pulse 或午夜。

云端 ChatGPT 独立审核 exact SHA 后才 merge/unlock S01-C。

持有人不手动 merge、不点 Actions、不整理 reports。

## 固定原则

Awareness before control。只报时，不裁判。无 shield/block。Callback 是系统信号，不等于无条件可信的精确 usage 证明；明显过早的 callback 必须 fail closed。
