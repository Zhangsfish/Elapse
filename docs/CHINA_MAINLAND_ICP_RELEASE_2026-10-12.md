# Everwhile 中国大陆 ICP 例外申请 / 发行进度（2026-10-12）

> 证据分类：本记录来自持有人提供的 Apple Developer Support 邮件截图、App Store Connect 页面及持有人陈述（**OWNER_PROVIDED / OWNER_REPORTED**），非当前 App Store Connect API 的实时读回。此仓库 public；持有人于 2026-10-12 明确要求记录案例号。绝不上传签名图、已签正式声明、账户邮箱、身份证件、Apple 私钥、支持邮件私有上传链接。

## 独立案例与 App 识别

| 字段 | 值 |
|---|---|
| App | Everwhile |
| 内部项目仓库 | `Zhangsfish/Elapse` |
| Apple ID（App Store Connect 数字编号） | **`6818551574`** |
| Bundle ID（非数字 App ID） | `com.zhangsfish.elapse` |
| Screen Time 扩展 IDs | `com.zhangsfish.elapse.monitor`; `com.zhangsfish.elapse.report` |
| Developer Team ID | `QK73K23W9N` |
| Apple Developer Support ICP 案例编号 | **`102991507017`** |
| Apple 支持联系人 | Water |
| ICP 申请进度 | **NEEDS_FOLLOWUP / NOT_APPROVED**：Apple 要求重新提交含数字 Apple ID `6818551574` 的签名函。补全版声明已准备；最终上传和回信是否成功送达没有 Apple 回执证据；等待再核实。 |
| App Review 版本 | iOS `0.1.0 (92.1)` 已获 App Review 批准。 |
| 美国区分发 | **OWNER_REPORTED_US_LIVE**（持有人在对话中明确说明已在美区上线）；需后续用真实商店 URL / ASC readback 作独立佐证。 |
| 中国大陆分发 | **WAITING_FOR_EVERWHILE_ICP_EXCEPTION**；绝不能挪用 Lecture Asset 的批准。 |

### 经过 / 具体补件

1. Everwhile 美国区 0.1.0 已获 App Review 批准，持有人报告随后已正式在美国区发布。原先 Family Controls 自动审核阻断已被正式审核通过结果取代；不要据此反向宣称 Apple 已承认技术误判。
2. 根据 Apple “每个 App 单独申请”要求，为 Everwhile 创建 Developer Support 案例 `102991507017`，提交 ICP 备案例外申请。
3. Apple 顾问 Water 要求重新提供声明，**必须包含 App 的数字 Apple ID `6818551574`**。此前文件里有 Bundle ID `com.zhangsfish.elapse`，但漏了数字 ID；两者不能混淆。
4. 2026-10-12 完成更正后的签名 PDF：新增数字 Apple ID，保留中文法定姓名、英文拼写、完整手写签名、Team ID、例外理由和法律责任声明。**本对话只核实文档准备完毕；已上传/发送回复与否不冒充已完成。**
5. 补充上传后应回复 Water 确认提交，后续以 Apple 的批准/补件邮件为准；中国区只有获准且 App Store Connect 地区状态允许时才启用。

### 与 Lecture Asset 对照

| App | 数字 Apple ID | ICP 案例号 | 例外状态 |
|---|---|---|---|
| Lecture Asset | `6816814541` | **`102984758084`** | **已获 Apple Developer Support 批准（持有人邮件截图，2026-10-12）** |
| Everwhile | `6818551574` | **`102991507017`** | **待补件回复/继续审核；尚未批准** |

对应记录：[Lecture Asset ICP/地区发行](https://github.com/Zhangsfish/lecture-asset/blob/main/docs/CHINA_MAINLAND_ICP_RELEASE_2026-10-12.md)

### 停止条件与操作建议

- **不要**为 Everwhile 直接勾选中国大陆、虚构 ICP 备案号、将 Lecture Asset 的 ICP 批准当作本 App 的批准。
- 等待数字 Apple ID 更正声明上传与 Apple Developer Support 确认；一旦批准，再于 ASC 中的 Pricing and Availability → App Availability → Manage Availability 增加中国大陆，并确认具体地区状态；通常不需要为了添加地区主动上传新 build。
- 不更改已发布产品的监测、提醒、隐私及 Family Controls entitlement；不能把 ICP 审批当作改功能理由。
- 法律/平台状态分别记录：Apple ICP **support approval**、当地法规适用判断、ASC **region availability status**、App Review **version approved**、实际 **country storefront live** 是五件不同的事情。

### 后续资料 SOP（避免重复漏字段）

用同一字段清单逐项核验 `App name + Numeric Apple ID + Bundle ID + Team ID + Chinese printed legal name + English spelling + owner's complete handwritten signature + legal-responsibility declaration`。每次版式/签名修订后，全文字段和 PDF 图像要重验；签名、证件、支持邮件安全链接不得进入公开 GitHub。

官方帮助：
- [Apple：管理 App 地区销售范围](https://developer.apple.com/cn/help/app-store-connect/manage-your-apps-availability/manage-availability-for-your-app-on-the-app-store/)
- [Apple：App / 提交状态与 ICP 缺失](https://developer.apple.com/cn/help/app-store-connect/reference/app-information/app-and-submission-statuses/)
