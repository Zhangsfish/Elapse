# STATUS

Updated: 2026-10-06

## 当前结论

2026-10-06：PR #21 历史 [CHANGES_REQUESTED — product polish only](https://github.com/Zhangsfish/Elapse/pull/21#issuecomment-6009677604) 的教程返工已通过后续 cloud review；69.1 / 78.1 / 81.1 保留为历史。当前不再重做教程、Today 或主体功能。

**S00 COMPLETE — PASS_WITH_NOTES。S01 COMPLETE — PASS_WITH_NOTES。S02-A COMPLETE — PASS_WITH_NOTES。S02-B WAITING_FOR_OWNER_TEST — public About & Support / DEBUG-only diagnostics；S03 LOCKED。**

2026-10-06 [cloud follow-up review](https://github.com/Zhangsfish/Elapse/pull/21#issuecomment-6011357941) 对 runtime `a21a857...` / head `e6bbd50...` 给出教程与本地化 PASS，冻结教程。持有人授权最后收口：Release 菜单只保留重播教学 / 关于与支持；诊断 UI 全部仅限 DEBUG；原生简短双语支持页。新实现已完成自动验证与 internal TestFlight 88.1 交付；81.1 是上一候选，不代替新 UI 的设备验收。只等持有人看新菜单和支持页，不再看教程 / Today，不重测 S01。

持有人指出 78.1 教程第二幕圆环容易被误读为已用时间，已确认并实现静态时钟 + 所选提醒间隔的渐显预览；只返工该幕，不动真实监控/Today。78.1 与 69.1 检查均属于历史候选，不沿用其视觉验收。

S02-B [PR #21](https://github.com/Zhangsfish/Elapse/pull/21)：当前 public-support runtime `600dea2...`，tested `e6ce828...`，upload `bc9b1f5...`（只有一次性 marker 差异）。60 Swift / 19 Python、simulator 与 unsigned Release build/archive、App/Monitor/Report 中英文资源与 capabilities PASS；[ordinary/native Release UI 37470762886](https://github.com/Zhangsfish/Elapse/actions/runs/37470762886) 两种语言真实执行并 PASS，无裁切审计豁免。[Prepare 37470755631](https://github.com/Zhangsfish/Elapse/actions/runs/37470755631) 87.1 NOT_UPLOADED。[Upload 37473140237](https://github.com/Zhangsfish/Elapse/actions/runs/37473140237) **0.1.0 (88.1)** 最终三 bundle 签名 / Family Controls / profile allowance PASS，精确审计字节 ACCEPTED，processing VALID / INTERNAL_ONLY / IN_BETA_TESTING / 现有组已分配（2026-10-06T13:50:40Z）。此前支持页的真实 textClipped 失败保留，不转写为 PASS。新菜单 / About 手机确认 NOT_RUN；先 WAITING_FOR_OWNER_TEST，实际回复后才 READY_FOR_AUDIT。同一 draft PR，不批准、不 merge、不解锁 S03；一次性 markers 已清理，报告/清理 head 的 CI 与 runtime-tested CI 分开。详情：[`reports/S02-B/round-01/DELIVERY.md`](reports/S02-B/round-01/DELIVERY.md)。

S02-A PR #20 exact head `dae485a64a20488b2253ec0f109690e114dbbc29` 已由云端独立审核并合并为 `c0eb65a2b1a40950b05270b400eb2f2e62e181af`。

正式审计：
[`audits/S02/S02_A_AUDIT_2026-10-05.md`](audits/S02/S02_A_AUDIT_2026-10-05.md)

Accepted internal baseline:
**Everwhile 0.1.0 (56.1)**

S02-A 已证明：
- 主界面已从工程控制台变为正式产品层级；
- 正常用户优先看到监控状态、提醒间隔、所选 App 数与 Today；
- config / event / lifecycle / callback / test-notification 等工程诊断下沉到 Advanced；
- Home 状态不会只凭 registration 就宣称 ON，仍要求 current interval lifecycle evidence；
- Today 保持真实 selected-App total / hourly aggregate / per-App rows；
- 小时图使用真实 bucket seconds，不伪造 session；
- 正的亚分钟使用显示为 `<1m` / `<1分钟`；
- en + zh-Hans 资源真实打包进 App 与 Report；
- 47 Swift tests / 0 failures；
- Everwhile 56.1 signed IPA / Family Controls / TestFlight / Apple processing VALID；
- 持有人已确认 56.1 duration-axis / clipping 表现“没问题，很好”。

S02-A notes：
- dark mode / Dynamic Type / VoiceOver / zh-Hans runtime inspection 未逐项真机跑；
- 最终 Start/Stop 新外观未单独再拍一轮；
- 这些进入 S02-B 做收口，不阻塞当前阶段。

## 唯一当前任务

**[S02-B：first-use guidance + bilingual product polish](prompts/S02_B_ONBOARDING_POLISH.md)**

S02-B 只做最终体验收口：

- 保持单屏渐进式 setup，不做强制多页 onboarding；
- 按持有人与云端返工方向，首次可跳过的四段连续短动画教学；首页单菜单重播，非强制 setup；
- 使用 generic UI，不暴露真实 App 身份；
- 动画尊重 Reduce Motion；
- 用户已有选择时不强制显示；
- 把真实 pulse notification 也做成 English + 简体中文；
- notification copy 保持中性、事实性，不声称 today total 或精确 wall-clock；
- 文案统一到 Everwhile 的产品声音；
- 处理 S02-A 留下的 dark/Dynamic Type/VoiceOver/locale edge；
- 不重做 Today；
- 不碰 S01 生命周期；
- 一轮很轻的 TestFlight 最终体验确认。

## 阶段状态

| 阶段 | 状态 | 目的 |
|---|---|---|
| S02-A | COMPLETE — PASS_WITH_NOTES | production home + Today |
| S02-B | **WAITING_FOR_OWNER_TEST** | PR #21 public support surface; 88.1 internal VALID; owner only checks menu + About |
| S03 | LOCKED | public distribution / App Store preparation |

## 产品边界

**Awareness before control.**

Everwhile 只让时间变得可感知，不替用户裁判。

不引入：
- Shield / block；
- streak / score / leaderboard；
- guilt / coach；
- 强制反思；
- cloud/account/analytics/ads/AI。

保护数据边界不变：
DeviceActivityReport 的 App identity / per-App usage / hourly usage 继续留在 report extension。

## 可靠性边界

S02 不扩大 S01 的技术结论：
- registration 不等于 current interval active；
- callback 不等于完美精确 usage clock；
- 47.1 自然午夜 generation rollover 仍是 residual risk；
- timezone/DST 未做人工真机操纵；
- all-day every-threshold reliability 未证明。

这些不阻塞 S02-B，除非真实回归出现。

## 分工

- Codex：执行当前唯一 S02-B，CI/TestFlight、带持有人做一轮很短的最终体验确认、整理 reports，停在 `READY_FOR_AUDIT`。
- 持有人：只做必要的 iPhone 视觉/交互确认。
- 云端 ChatGPT：独立审核 exact SHA，通过后 merge 并只解锁 S03。

持有人不手动 merge，不点 Actions，不整理 reports。
