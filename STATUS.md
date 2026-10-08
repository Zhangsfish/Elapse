# STATUS

Updated: 2026-10-08

## 当前结论

**S00/S01/S02 COMPLETE — PASS_WITH_NOTES。S03-A COMPLETE。S03-B OWNER_REPORTED_SUBMITTED；S03-C BLOCKED — APPLE_AUTOMATED_FAMILY_CONTROLS_REVIEW，3 个 App ID Distribution Assigned 已由 owner 截图确认，等待 Apple App Review 复核。公开发布 LOCKED。**

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

**[S03-C：Apple Family Controls 自动审核阻断核查](reports/S03-C/FAMILY_CONTROLS_AUTOMATED_REVIEW_BLOCK_2026-10-08.md)**

2026-10-08 持有人转来 App Review 自动消息：检测到 Screen Time API，但声称送审包缺少 Family Controls entitlement，因此审核不能继续。这是 **OWNER_REPORTED**。已上传 92.1 的代码签名及 embedded App Store profiles 三项 Family Controls 检查全部 PASS。随后持有人提供的 Apple Portal 截图进一步确认 **App、Monitor、Report 三个 App ID 的 Family Controls (Distribution) 均为 Assigned**；Monitor、Report 信息弹窗明确包含 App Store Connect provisioning（主 App 弹窗未单独显示，但其 distribution 签名/profile 已通过）。因此现阶段应回复 Apple 要求人工复核自动判定及指出确切失败的二进制/entitlement key，**不要盲目上传新 build、变更 runtime 或重新提交**。对照证据和建议英文回信见 [审核阻断记录](reports/S03-C/FAMILY_CONTROLS_AUTOMATED_REVIEW_BLOCK_2026-10-08.md)。

### 历史 S03-B 工程交付

Review-eligible RC 已完成：**Everwhile 0.1.0 (92.1)**，ASC `VALID / APP_STORE_ELIGIBLE`。
Exact IPA SHA256：`fb3baad3ce54842122b6a6416b4334115b7754953a66dde5614b2f3801b9dade`。
RC workflow：`37580987653`。App / Monitor / Report 的 Apple Distribution、Family Controls distribution profile allowance、必要 App Group、`get-task-allow=false` 均 PASS。

S03-B 工程收口记录：[`reports/S03-B/round-01/PORTAL_CLOSEOUT.md`](reports/S03-B/round-01/PORTAL_CLOSEOUT.md)。
当前 live URLs、92.1 关联、双语 metadata/review notes 均已收口；实际检查/run/SHAs 见 DELIVERY 和 TEST_RESULTS。
历史结论（已被 2026-10-08 Apple 自动阻断推翻）：Family Controls 签名/profile gate PASS；**Portal Assigned UI 现在必须核查**，不能继续把它当作 OPTIONAL_OWNER_READBACK。
App Privacy 源码结论是 **No / Data Not Collected；tracking No**，不能冒充 ASC 私人声明已发布。
PR #25 已由 cloud 独立审核并合并。截至 2026-10-07 的提交准备已完成。2026-10-08 持有人提供自动审核阻断通知，因此现阶段要先解决 Apple entitlement 权限或自动判定问题，后续回复/再提交以 Apple 反馈为准。
审核联系人已经填齐，不需重填。92.1 没有重建；自动审核通知代表之后已尝试提交，具体 ASC 状态仍需读回；没有公开发布。

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
PR #24 / #25 均已 merged。PR #25 merge：`2bce5c0a5d3ab0f0e3c5219c7120e7d8ea4a03ab`。
Cloud audit：[`audits/S03/S03_B_PORTAL_CLOSEOUT_AUDIT_2026-10-07.md`](audits/S03/S03_B_PORTAL_CLOSEOUT_AUDIT_2026-10-07.md)，verdict **PASS — READY_FOR_OWNER_SUBMISSION**。
**READY_FOR_OWNER_SUBMISSION 是工程/云端审核通过状态，不是 Apple 审核通过，也不授权自动提交或公开发布。**

默认仍是：
- United States first；
- Free；
- iPhone-only；
- English + zh-Hans；
- manual release；
- China mainland 继续 BLOCKED_UNTIL_ICP_STATUS_CONFIRMED。

**S03-C 仅处理自动审核阻断、权限申诉和必要的最小修复。未经证据支持，不授权新 RC、再次提交或公开发布。**

## 阶段状态

| 阶段 | 状态 | 目的 |
|---|---|---|
| S02 | COMPLETE — PASS_WITH_NOTES | functional/product candidate frozen at 91.1 |
| S03-A | **COMPLETE — PASS_WITH_NOTES** | metadata/assets/preflight complete; owner/account notes carried forward |
| S03-B | OWNER_REPORTED_SUBMITTED — REVIEW_BLOCKED | 工程包已完成；2026-10-08 持有人提供 Apple 自动阻断信 |
| S03-C | **BLOCKED_APPLE_AUTOMATED_REVIEW — READY_TO_REQUEST_MANUAL_RECHECK** | 三个 App ID Assigned 已核实，等待 App Review 复核自动判定；公开发布禁止 |

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
