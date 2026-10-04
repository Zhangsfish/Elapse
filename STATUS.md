# STATUS

Updated: 2026-10-04

## 当前结论

**S00 FUNCTIONAL ACCEPTANCE COMPLETE — PASS_WITH_NOTES。S01-A IN_PROGRESS；S01-B / S01-C / S02 / S03 LOCKED。**

S01-A 由 Codex 在 `codex/s01-a-day-range-interval` 实施；当前代码/CI/真机登记证据以 `reports/S01-A/round-01/` 为准。未完成设备验收前不得标记 PASS 或解锁 S01-B。

S00-D PR #17 的精确 head `ebaf1c7a23a9f93856428e4df5b6dba71020bf39` 已由云端独立审核并合并为 `3771b556334a5dc1b15e42287183bc9e8f1bef95`。审计见 [S00-D cloud audit](audits/S00/S00_D_AUDIT_2026-10-04.md)。

Everwhile `0.1.0 (41.1)` 现作为完整 S00 已接受基线：
- Family Controls / App Group 分发签名链通过；
- individual authorization、selected Apps 持久化、普通通知通过；
- shared selected-App pool 5–30 分钟有限序列通过；
- callback/request/stale/duplicate 诊断边界通过；
- current-user/current-iPhone Today 真实渲染通过；
- selected-App total / per-App / hourly aggregate 使用 ReportExtension 的真实 Apple report 数据；
- 不伪造 exact sessions；
- protected report data 不通过 App Group/主 App 导出。

S00 notes 保留：极少见 stale/duplicate 未在设备自然发生；Today zero/unavailable 只由 source/tests 覆盖；UI/显示精度仍有体验债务。

## 唯一当前任务

**[S01-A：日内全天范围与可配置间隔基础](prompts/S01_A_DAY_RANGE_INTERVAL.md)**

本轮只做：
- default 5 分钟 + 可配置 interval；
- 从固定六档扩展为 current-day full-range threshold plan；
- scalable diagnostics；
- interval/selection stop-first consistency；
- 在真实 iPhone 上证明默认 5-minute 大 event ladder 可以成功 registration。

**本轮不要求用户刷一整天。**

Apple 当前公开文档给出 activity 同时监控上限 20，但未公开每 activity event 数量上限。因此大 event ladder 的设备 registration 是本轮核心 gate。

## S01 拆分

| 子阶段 | 状态 | 目的 |
|---|---|---|
| S01-A | **IN_PROGRESS** | 日内全天 threshold plan、interval 配置、大 event ladder 注册可行性 |
| S01-B | LOCKED | 自动跨日 / config change / app & device restart / permission recovery |
| S01-C | LOCKED | 自然日 rollover、timezone/DST 与持续使用验收 |

只有当前子阶段可以实施。

## 已接受基线

| 项目 | 状态 | 依据 |
|---|---|---|
| S00-A | COMPLETE — PASS_WITH_NOTES | `audits/S00/S00_A_AUDIT_2026-10-03.md` |
| S00-B | COMPLETE — PASS_WITH_NOTES | `audits/S00/S00_B_AUDIT_2026-10-03.md` |
| S00-C | COMPLETE — PASS_WITH_NOTES | `audits/S00/S00_C_AUDIT_2026-10-04.md` |
| S00-D | COMPLETE — PASS_WITH_NOTES | `audits/S00/S00_D_AUDIT_2026-10-04.md` |
| accepted device build | 0.1.0 (41.1) | PR #17 / TestFlight run 37141044938 |
| Today real content | PASS — OWNER + report extension | two nonzero selected-App rows, total/hourly content |
| Today zero/unavailable | PASS — SOURCE + UNIT_TEST | device NOT_RUN |
| S01 all-day engine | NOT_IMPLEMENTED | current PulsePlan still 5–30 only |

## UX follow-up

持有人确认 41.1 Today 功能/数值可用，但视觉“像毛坯”。已记录在 `reports/S00-D/round-01/UX_FOLLOWUP.md`。

该问题不属于 S01-A；正式 report/UI 竞品研究、信息层级、图表与显示精度改进放到 **S02**。不要为了好看改写数据语义。

## 分工

Codex 负责 S01-A 实现、CI/必要 TestFlight，以及最小真机 registration/config 验收。无需长时间 usage test。等待 owner 设备反馈为 `WAITING_FOR_OWNER_TEST`；完成后 `READY_FOR_AUDIT`。

云端 ChatGPT 独立审核 exact SHA 后才 merge/unlock S01-B。

持有人只做必要 iPhone / Apple 私密账号动作，不手动 merge、不手动点 Actions、不整理报告。

## 固定产品边界

Awareness before control。只报时，不裁判。无 block/shield、评分、streak、账号、云服务、AI、广告。Pulse 不冒充 Today total；Today 不伪造 exact sessions；report protected data 不导出。
