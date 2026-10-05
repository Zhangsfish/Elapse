# STATUS

Updated: 2026-10-05

## 当前结论

**S00 COMPLETE — PASS_WITH_NOTES。S01 COMPLETE — PASS_WITH_NOTES。S02-A READY_FOR_AUDIT；S02-B / S03 LOCKED。**

S02-A PR #20 内部版 **Everwhile 0.1.0 (56.1)** 已通过普通 CI（47 个 Swift tests）、prepare、最终分发签名检查、上传与 processing VALID，并分配到原内部测试组。持有人认可 53.1 的 Today 布局；56.1 补充动态时长纵轴后，持有人在本 Codex 对话回复“没问题，很好”，记录为 OWNER_REPORTED_PASS。本轮无需追加手机操作；dark mode / Dynamic Type / VoiceOver 真机专项仍为 NOT_RUN。详见 `reports/S02-A/round-01/`。现等待云端独立审核 exact SHA；这不是自批，不可自行 merge 或解锁 S02-B。

S01-B PR #19 已由云端审核并合并；accepted internal baseline 仍为 **Everwhile 0.1.0 (47.1)**。

S01-C 已收口：
- 真实 Screen Time / Family Controls revoke 后，desired intent 保持 ON，system registration / recurring 变为未确认，状态正确 fail closed；
- 重新授权后自动创建新 config，恢复 5m、299/299、recurring YES、active interval generation/anchor；
- latest recovery reason = `authorizationReapproved`；
- 47.1 自然午夜 `generation N -> N+1` 没有为验收再次熬夜重复实测；历史午夜观察 + S01-B repeating lifecycle/source/unit tests 已覆盖主要风险，剩余项作为 residual runtime risk 接受，未来真实出现问题再修。

正式收口：
[`audits/S01/S01_C_CLOSEOUT_2026-10-05.md`](audits/S01/S01_C_CLOSEOUT_2026-10-05.md)

## 唯一当前任务

**[S02-A：production UI shell + Today redesign](prompts/S02_A_PRODUCTION_UI_TODAY.md)**

设计基线：
[`docs/S02_UX_RESEARCH_AND_DIRECTION.md`](docs/S02_UX_RESEARCH_AND_DIRECTION.md)

S02-A 只解决第一轮正式产品体验：

- 把当前“工程控制台”主界面改成安静、稀疏、普通用户可理解的产品首页；
- 主界面只优先回答：Everwhile 是否开启、提醒间隔、选了几个 App、今天时间去了哪里；
- S00/S01 标签、config UUID、299 events、generation/anchor、callback/recovery counters、普通通知自检等退出主界面，保留在 Advanced / Diagnostics；
- Today 重做为：
  - 今日所选 App 总时长 hero；
  - 真实 hourly aggregate 的紧凑柱状图；
  - 各 App duration 排名；
  - 不虚构精确 session；
- 修复正的亚分钟使用显示 `0m`：改为 `<1m` 或等价本地化表达；
- 建立简体中文 + English localization；
- light/dark、Dynamic Type、VoiceOver、颜色非唯一编码；
- 不碰 S01 监控状态机，除非真实 UI integration bug 暴露；
- 一轮很轻的 TestFlight 真机 UI 验收即可，不重复 S01 生命周期测试。

## S02 分层

| 阶段 | 状态 | 目的 |
|---|---|---|
| S02-A | **READY_FOR_AUDIT** | production shell + Today hierarchy/chart + diagnostics separation + bilingual foundation |
| S02-B | LOCKED | onboarding / “选择 App”教学 / copy-spacing-accessibility polish |
| S03 | LOCKED | public distribution |

## 产品边界

**Awareness before control.**

Everwhile 是感知工具，不是纪律工具。

不引入：
- Shield / block；
- streak / score / leaderboard；
- guilt / coach / “culprit app”；
- 强制反思；
- cloud/account/analytics/ads/AI。

保护数据边界不变：
DeviceActivityReport 的 App identity / per-App usage / hourly usage 保持在 report extension 内，不为了首页方便搬进 App Group。

## 当前可靠性边界

不会因为进入 S02 就偷偷扩大技术结论：

- registration presence / event count 不等于 current interval active；
- callback 不等于完美的精确 usage clock；
- 47.1 自然午夜 generation rollover 是 residual risk，不是 device-proven；
- timezone/DST 未做人工真机操纵；
- all-day every-threshold reliability 未证明。

这些不阻塞 UI 工作，除非真实回归出现。

## 分工

- Codex：执行当前唯一 S02-A，实现、CI/TestFlight、带持有人做一轮很短的 UI 真机验收、整理 reports，最后停在 `READY_FOR_AUDIT`。
- 持有人：只做必要的 iPhone 视觉/交互确认。
- 云端 ChatGPT：独立审核 exact SHA / diff / CI / device evidence，通过后 merge 并只解锁 S02-B。

持有人不手动 merge，不点 Actions，不整理 reports。
