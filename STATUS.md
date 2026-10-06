# STATUS

Updated: 2026-10-07

## 当前结论

**S00 COMPLETE — PASS_WITH_NOTES。S01 COMPLETE — PASS_WITH_NOTES。S02 COMPLETE — PASS_WITH_NOTES。S03-A IN_PROGRESS — WAITING_FOR_OWNER_VISUAL_REVIEW；S03-B / S03-C LOCKED。**

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

**[S03-A：App Store preflight, metadata and assets](prompts/S03_A_APP_STORE_PREFLIGHT.md)**

PR [#22](https://github.com/Zhangsfish/Elapse/pull/22)，分支 `codex/s03-a-app-store-preflight`。
English Pass 1 已完成真实 Release 采集、四张英文草稿、contact sheet、manifest 和像素校验。
等待持有人审英文视觉方向；**未开始最终 zh-Hans 截图，未 READY_FOR_AUDIT**。
交付/已执行检查/剩余 gate：[`reports/S03-A/round-01/DELIVERY.md`](reports/S03-A/round-01/DELIVERY.md)。
91.1 runtime 保持冻结；本轮没有新 TestFlight、App Review 或公开发布。
Support/Privacy 静态源码及部署 workflow 已准备，但公开 URL 尚 NOT_LIVE。
91.1 签名 gate 复核与 portal Assigned 确认分开；91.1 INTERNAL_ONLY 不可直接提交 App Review。

总体发布框架：
[`docs/S03_APP_STORE_RELEASE_PLAN.md`](docs/S03_APP_STORE_RELEASE_PLAN.md)

S03-A 只做上架准备，不提交审核：

1. 核 Family Controls Distribution：
   - main App；
   - DeviceActivity Monitor extension；
   - DeviceActivity Report extension。
   91.1 签名已证明 profile allowance，但仍要记录 Developer portal `Assigned` 状态；如果自动化无法查，只给持有人一个最小 portal 动作。

2. 准备公开：
   - Privacy Policy page；
   - Support page；
   - 无登录、无 analytics/remote JS。

3. 独立审 App Privacy：
   - 源码；
   - PrivacyInfo.xcprivacy；
   - 网络/SDK；
   - support email/browser；
   - 形成 App Store Connect 回答草稿。

4. 准备 English + zh-Hans：
   - App Store name/subtitle/description/keywords；
   - review notes；
   - 4 张左右截图；
   - Support/Privacy URL；
   - category 建议。

5. Region：
   - 默认建议 **United States first**；
   - China mainland 在 ICP 状态确认前标记 blocked，不自动选择；
   - storefront 最终列表必须持有人批准。

## 阶段状态

| 阶段 | 状态 | 目的 |
|---|---|---|
| S02 | COMPLETE — PASS_WITH_NOTES | functional/product candidate frozen at 91.1 |
| S03-A | **IN_PROGRESS — WAITING_FOR_OWNER_VISUAL_REVIEW** | English Pass 1 + preflight drafts; Chinese final assets gated |
| S03-B | LOCKED | App Store Connect data entry + exact build + submit to App Review |
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
