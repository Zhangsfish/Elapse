# STATUS

Updated: 2026-10-06

## 当前结论

2026-10-06：持有人批准的 Lecture Asset 风格四个短动作镜头已实现：选择 App → 间隔/Start → 共享用时提醒 → Today 示例。首次可跳过、首页问号可重播，老用户不强制弹出。**69.1** 已在现有内部 TestFlight 组可用；等待一轮简短教学观察，旧版视觉结果不沿用为新版本 PASS。

**S00 COMPLETE — PASS_WITH_NOTES。S01 COMPLETE — PASS_WITH_NOTES。S02-A COMPLETE — PASS_WITH_NOTES。S02-B WAITING_FOR_OWNER_TEST；S03 LOCKED。**

S02-B [PR #21](https://github.com/Zhangsfish/Elapse/pull/21)：当前 runtime `f05df01...`，tested/prepare `e1fba3d...`，upload `9de0a20...`。58 Swift / 13 Python、unsigned archive、资源/capabilities、两项 native UI 与四段 Dynamic Type/裁切 audit PASS；首轮模拟器 boot timeout 为 NOT_RUN，重跑通过。69.1 最终三 bundle 签名/FAMILY_CONTROLS/profile allowance PASS，ACCEPTED / VALID / INTERNAL_ONLY / IN_BETA_TESTING / 现有组已分配。短教学的真机安装/视觉观察 NOT_RUN；不重做 S01、Today 或等待 pulse。详情及外观检查限制：[`reports/S02-B/round-01/DELIVERY.md`](reports/S02-B/round-01/DELIVERY.md)。

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
- 按持有人直接批准的返工方向，首次可跳过的四段短动画教学；首页问号重播，非强制 setup；
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
| S02-B | **WAITING_FOR_OWNER_TEST** | 69.1 four short animated teaching scenes delivered; brief replay observation pending |
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
