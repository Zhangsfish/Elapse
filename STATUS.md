# STATUS

Updated: 2026-10-07

## 当前结论

**S00 COMPLETE — PASS_WITH_NOTES。S01 COMPLETE — PASS_WITH_NOTES。S02 COMPLETE — PASS_WITH_NOTES。S03-A COMPLETE — PASS_WITH_NOTES；S03-B READY_FOR_OWNER_SUBMISSION（工程收口 PR #25 待 cloud audit；私人声明/最终提交仍由 owner 完成）；S03-C LOCKED。**

Everwhile 当前冻结功能候选：

- version/build: **0.1.0 (91.1)**
- functional runtime: `fab87acc8f4b863451d9c91ee7605b4c33c47789`
- tested SHA: `7fa2cae8478ec0429989be4eaf78413724b7f8b2`
- signed/internal upload SHA: `d633b5b627933d71aac221a3bb2f6aae29fd82a2`
- PR #21 final head: `080da9f7a32c0b2837bf8a08092e5bfaa9f03381`
- merged main: `8a42edc58589da0c15673acf7e83a5d045ea2818`

PR #21 已合并。91.1 的普通 CI、Release UI 双语/大字体审计、unsigned device/archive、最终三 bundle 签名、Family Controls profile allowance、App Group、TestFlight upload/processing 均通过。持有人已明确接受当前功能版本为最终功能候选。

正式 S02-B 收口：
[`audits/S02/S02_B_AUDIT_2026-10-06.md`](audits/S02/S02_B_AUDIT_2026-10-06.md)

S02 残余可靠性边界继续记录但不再扩功能：
- 47.1 自然午夜 generation rollover 未专门重复实测；
- timezone/DST 未人工真机操纵；
- all-day every-threshold callback reliability 未宣称；
- human VoiceOver / external Mail/browser 未单独 owner test。

这些不是 S03 功能开发项。

## 唯一当前任务

**[S03-B：App Store submission preparation and exact release candidate](prompts/S03_B_APP_STORE_SUBMISSION.md)**

Review-eligible RC 已完成：**Everwhile 0.1.0 (92.1)**，ASC `VALID / APP_STORE_ELIGIBLE`。
Exact IPA SHA256：`fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`。
RC workflow：`37580987653`。App / Monitor / Report 的 Apple Distribution、Family Controls distribution profile allowance、必要 App Group、`get-task-allow=false` 均 PASS。

S03-B 工程收口记录：[`reports/S03-B/round-01/PORTAL_CLOSEOUT.md`](reports/S03-B/round-01/PORTAL_CLOSEOUT.md)。
当前 live URLs、92.1 关联、双语 metadata/review notes 均已收口；实际检查/run/SHAs 见 DELIVERY 和 TEST_RESULTS。
Family Controls 发布签名/profile 实证 gate CLOSED；未读取的 Portal Assigned UI 降为 OPTIONAL_OWNER_READBACK，不再阻塞。
App Privacy 源码结论是 **No / Data Not Collected；tracking No**，不能冒充 ASC 私人声明已发布。
Owner 只需确认 exact storefront（建议 US only、排除中国大陆）及尚未完成的 legal/privacy attestation；cloud 审核 PR #25 后再亲自最终 Submit for Review。
审核联系人已经填齐，不需重填。没有生成新 RC / TestFlight，没有提交审核或公开发布。

S03-A 已由 cloud 独立审计并合并：
- PR #22 merge: `62526aeff6176895d84d6b192086d4348df07858`
- audit: [`audits/S03/S03_A_AUDIT_2026-10-07.md`](audits/S03/S03_A_AUDIT_2026-10-07.md)
- verdict: **PASS_WITH_NOTES**

已完成并冻结：
- English + zh-Hans 商店截图设计；
- owner 已在 ASC 实际上传 4+4 并确认显示正常；
- App 名称 Everwhile；
- primary language English (US)；
- primary category Utilities；
- age rating 4+；
- bilingual metadata / review notes / privacy/support page source。

Support https://zhangsfish.github.io/Elapse/ 和 Privacy https://zhangsfish.github.io/Elapse/privacy.html 均 LIVE_VERIFIED：匿名 HTTPS200、双语及交叉链接等通过；两种 ASC locale 的 URL 已保存并读回。
冻结 runtime / screenshots 不变；现有 92.1 为唯一正式 RC，不再重复制作。
PR #24 已 merged，当前小型 closeout PR #25：`codex/s03-b-portal-closeout`，仅发布工具、metadata 和 evidence。
**READY_FOR_OWNER_SUBMISSION 是工程准备状态，不是 cloud 批准/Apple 审核通过，也不授权 Codex 提交。**

默认仍是：
- United States first；
- Free；
- iPhone-only；
- English + zh-Hans；
- manual release；
- China mainland 继续 BLOCKED_UNTIL_ICP_STATUS_CONFIRMED。

**S03-B 不授权自动公开发布。S03-C 仍 LOCKED。**

## 阶段状态

| 阶段 | 状态 | 目的 |
|---|---|---|
| S02 | COMPLETE — PASS_WITH_NOTES | functional/product candidate frozen at 91.1 |
| S03-A | **COMPLETE — PASS_WITH_NOTES** | metadata/assets/preflight complete; owner/account notes carried forward |
| S03-B | **READY_FOR_OWNER_SUBMISSION — PR #25 待 cloud audit** | RC 92.1 已关联，live URLs/metadata 完成；owner 最终地区/声明/提交保留 |
| S03-C | LOCKED | review response / rejection fixes / owner-approved public release |

## S03 硬边界

S03 不是重新开发产品。

不允许因为准备上架顺手改：
- monitoring lifecycle；
- Today aggregation；
- tutorial；
- notification semantics；
- App Group/privacy architecture；
- Bundle IDs/capabilities。

只有 Apple/地区明确要求 runtime 变化时，才开最小独立修复并重新签名验证。

## 发布原则

默认：
- 免费；
- iPhone-only；
- English + zh-Hans；
- owner-controlled manual release；
- 不自动全球开放；
- 不自动提交 App Review；
- 不自动公开发布。

持有人不需要重复 S01/S02 真机测试。
