# STATUS

Updated: 2026-10-05

## 当前结论

**S00 COMPLETE — PASS_WITH_NOTES。S01-A COMPLETE — PASS_WITH_NOTES。S01-B COMPLETE — PASS_WITH_NOTES。S01-C READY；S02 / S03 LOCKED。**

S01-B PR #19 exact head `aa725b8a4a7cbd26b93b28cc286b6a36f87d7f7d` 已由云端独立审核并合并为 `60efd1622ea8b0c5148c78764bea274d51c11885`。

正式审计：
[`audits/S01/S01_B_AUDIT_2026-10-05.md`](audits/S01/S01_B_AUDIT_2026-10-05.md)

Accepted internal baseline:
**Everwhile 0.1.0 (47.1)**

S01-B 已证明：

- 产品 schedule 使用 daily `repeats=true`；
- desired monitoring intent、system registration、current interval lifecycle 三层状态分开；
- `intervalDidStart` 建立 generation / anchor，并对同一 local cycle 幂等；
- 新 interval 清空 interval-local receipts，保留当前 config；
- unanchored / stale / physically-impossible premature callback fail closed；
- launch / foreground / refresh reconciliation；
- registration missing / mismatch 自动恢复为新 config；
- authorization blocked / reapproved 状态机已通过 SOURCE + UNIT_TEST；
- 目标 iPhone 真实看到 5m、299/299、recurring YES、active interval generation / anchor；
- App reopen 与整机 reboot 后 registration 保持；
- Stop 后 reopen desired OFF，不自动复活；
- signed IPA / Family Controls / App Group / TestFlight / Apple processing VALID 全部通过。

S01-B **没有**证明：
- 自然午夜后新 interval 一定真正开始；
- 真实 revoke / regrant 已在设备通过；
- 全天每个 threshold callback 都可靠；
- timezone / DST 真机边界。

## 唯一当前任务

**[S01-C：calendar / permission 最小实证](prompts/S01_C_CALENDAR_PERMISSION_ACCEPTANCE.md)**

本轮只做两个高价值真机边界：

1. **一次真实 Screen Time revoke / regrant**
   - revoke 后 desired 保留，但 registration fail closed；
   - regrant 后自动恢复为新 config；
   - recurring YES + 299/299 + 新 generation/anchor。

2. **一次自然午夜 rollover**
   - 不 Stop / Start；
   - 不改 interval / selection；
   - 关键 PASS 证据不是“仍有 299/299”，而是同 config 下 generation 从 N -> N+1，并出现新一天 anchor。

用户要求测试适度收口：**发现真实问题再修，不为了覆盖率额外折腾手机。**

本轮不要求：
- 手动改 timezone；
- 手动改系统时间；
- 模拟 DST；
- 全天刷 App；
- 等 pulse；
- Today 重测；
- S02 UI 美化。

若 47.1 两个 gate 都通过，不需要重新出包。
只有真实发现 runtime bug 并修改源码时，才出新 internal build 并只复测受影响项。

## 阶段状态

| 阶段 | 状态 | 目的 |
|---|---|---|
| S00 | COMPLETE — PASS_WITH_NOTES | functional baseline |
| S01-A | COMPLETE — PASS_WITH_NOTES | full-day event ladder + interval |
| S01-B | COMPLETE — PASS_WITH_NOTES | repeating lifecycle + reconcile/reboot recovery |
| S01-C | **READY** | natural midnight + real permission recovery |
| S02 | LOCKED | production UI / Today hierarchy + visualization |
| S03 | LOCKED | public distribution |

## 当前可靠性边界

Apple 当前文档支持 recurring schedule，并说明 startMonitoring 时若当前时间位于 interval 内，会立即触发 `intervalDidStart`。

Everwhile 仍坚持：
**registration presence / event count 不等于当前 interval active，更不等于精确 usage。**

Callback 是系统信号，不是无条件可信的精确用量证明；明显过早 callback 必须 fail closed。

## 产品边界

Awareness before control。只报时，不裁判。

不引入：
- Shield / block；
- Screen Time 强制限制；
- streak / score；
- 羞耻 / 教练；
- cloud/account/analytics/ads/AI。

Today 视觉“毛坯”和显示精度债务继续留给 S02，不在 S01-C 顺手处理。

## 分工

- Codex：执行 S01-C，仅在必要时带持有人做一个手机动作；整理 reports；完成后停在 `READY_FOR_AUDIT`。
- 持有人：只做真实 revoke/regrant 与自然午夜观察。
- 云端 ChatGPT：独立审核 exact SHA / evidence，通过后 merge 并解锁 S02。

持有人不手动 merge，不点 Actions，不整理 reports。
