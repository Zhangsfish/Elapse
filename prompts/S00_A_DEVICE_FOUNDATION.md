# S00-A — 可验收的真机基础

Task ID: S00-A
调度状态：以 `STATUS.md` 为准。本轮是唯一 READY 实现任务。
Branch: `codex/s00-a-device-foundation`

## 目的

把现有 Everwhile S00 原型变成持有人能实际验证的基础版本。**先证明最终签名、授权、App 选择和普通通知，再测实际使用时长。** 这不是重做项目，也不是全天报时或报表重构任务。

读取顺序：`AGENTS.md` → `STATUS.md` → `docs/WORKFLOW.md` → `docs/EXECUTION_PLAN.md` → `audits/S00/READINESS_REVIEW_2026-10-03.md` → 本任务。随后按需读取产品事实源和本任务涉及源码；不要把旧 `prompts/S00_CODEX.md` 当成新的全量开发命令。

## 已知事实与边界

- 内部/仓库名 `Elapse`，用户品牌 `Everwhile`。不改仓库、scheme、Bundle IDs。
- 已安装基线由持有人报告为当前 TestFlight 版本；预期 `0.1.0 (19.1)`。只在需要时核对版本一次，不重新折腾安装邀请。
- 19.1 对应实现 SHA `60a15650d6791ef081f6d8aa402cfb48d3a03ff1`；当时 main `afb4a61a2e62e849b5c6e831367c90d9f2983726` 只多文档。
- upload run `37105502155` 已报告 accepted 与 processing VALID；持有人随后提供 Apple 邮件：**ITMS-90897，19.1 主 App Elapse.app 缺 com.apple.developer.family-controls**。该警告未闭环，不得沿用“签名彻底修好”的结论。
- 已有 1 个 Variable `APPLE_TEAM_ID`；3 个 Secrets `APP_STORE_CONNECT_KEY_ID`、`APP_STORE_CONNECT_ISSUER_ID`、`APP_STORE_CONNECT_PRIVATE_KEY`。复用，不要求重新创建、不读取/打印值、不请求 .p8。
- Family Controls 主 App、Monitor、Report 的后台 capability 已由持有人配置；现在应先查生成配置/最终签名，而非要求用户重配后台。
- 持有人用 Windows + iPhone，不能默认可打开 Mac Console/Xcode 或读取 extension OSLog。

## 第 0 步：核对，不猜

同步最新 main，确认没有并行实现 PR，记录 base SHA。检查实际页面/状态路径及当前发布脚本：

- `App/ContentView.swift`、`App/ElapseModel.swift`、`App/ElapseApp.swift`
- `project.yml` 与三个 entitlement 文件
- `scripts/s00_testflight_release.sh`、`scripts/s00_signing_settings.py`
- `.github/workflows/s00-macos.yml`、`.github/workflows/s00-testflight.yml`

区分 SOURCE / GENERATED / SIGNED_ARTIFACT / APPLE_PROCESSING / DEVICE_OBSERVED，不将前一个层级冒充后一个。找不到原上传 IPA 就写明，不能假装检查了已安装二进制。

## 第 1 步：关闭 ITMS-90897 风险

1. 检查 XcodeGen 后三个 entitlement 文件实际保留 Family Controls；保留已有生成后断言。
2. 检查三个 target 的有效 Release `CODE_SIGN_ENTITLEMENTS` 是否指向预期文件，内容能被正确解析。
3. 用现有 CI/Apple 凭据检查实际 distribution-signed 产物的主 App、Monitor、Report。分别检查 **代码签名声明** 与 **profile 授权范围**，二者不是一回事。
4. 检查脚本本身须有正/负例：正确 true、键缺失、空文件/解析失败；解析失败输出 READ_ERROR，不能吞异常变成空字典后谎报“权限缺失”，更不能默许通过。
5. 若修复需要新包，验证要上传的最终产物。若上传过程重新导出/重签，不能用另一次导出的 IPA 冒充实际上传包证据；记录最终检查范围和对应 build/SHA，保留可追溯的安全摘要。上传成功及 VALID 仍与签名检查分开。
6. 普通 CI 不读 Apple secrets。签名资料/原始 profile/私钥/证书/JWT 不进公开日志或 artifacts；摘要仅列已知 bundle、检查布尔值/错误分类。
7. 不先发明另一套签名流程，不盲目反复上传。先按证据定位；需要最小签名修复则在同一任务完成。历史 ad-hoc 试验不是已验证方案。不能让用户注册 UDID 或改走 development/ad-hoc 安装以绕过分发问题。

官方参考（需核对当前文档及实际 runner 工具行为）：
- https://developer.apple.com/documentation/technotes/tn3125-inside-code-signing-provisioning-profiles
- https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement
- https://developer.apple.com/documentation/xcode/configuring-family-controls

若最终签名核验仍失败，停在工程修复，不让持有人去刷 App 等阈值。

## 第 2 步：最小可操作界面与诊断

复用现有 Form，不做视觉大改。持有人使用中文，可为本轮操作增加清楚的中文按钮/说明，避免强迫用户理解框架名。

- 显示 version/build、真实 Screen Time 授权状态、通知授权/提醒设置状态、所选 application token 数量和最后一次操作结果。
- 授权调用用 `.individual`；请求完成不能直接显示“已授权”，必须读实际状态。错误可读且能复制本 App 的脱敏诊断。
- 未授权时，选择/监控入口应给出明确前置条件；不显示假成功。拒绝后提供去本 App 设置的最短路径，不要求重置全机 Screen Time。
- 多 App 选择保存/重启加载必须可观察。处理系统选择器的类别/网站选择：本轮只监控 applicationTokens；若无应用 token，要明确提示，不用一个非零类别数冒充选中了 App。不要打印 token 或 bundle identity。
- 修复 `selection.didSet` 先 `persistSelection()` 再 `statusMessage=nil` 导致保存错误被覆盖的问题；保存失败与零选择不可混同。
- 加一个**明确标记的普通测试通知**入口，例如“测试通知（不计使用时间）”：单次、短延时，方便返回桌面观察，不触碰阈值状态/去重记录。使用独立 test identifier，防止重复点产生通知堆积。它只是通知自检，不得宣称 Screen Time 已跑通。
- 在用户界面和报告中明确“已登记监控”不等于“已收到回调”。本轮不添加假实时秒表、不编造累计使用值。

诊断只含本 App 状态、build、应用数量、操作类型、脱敏错误类型/码。不要导出 report 数据、所选 token、Apple 账号或其他 App 内容。扩展回调可观察性安排在 S00-B，本轮不为此增加 App Group。

## 第 3 步：先自动验，再由你带持有人验

自动：现有 app + 两个 extension 真实编译与六个纯逻辑测试不回退；为本轮可测试逻辑增加针对性测试；执行生成后 entitlement、Release wiring、最终签名检查。合成/模拟测试必须注明，不能填设备 PASS。

设备：可运行前标记 `IN_PROGRESS`。达到可带测状态后，在你与持有人的当前对话中逐步执行，不只交一张清单就结束：

1. 核对已装版本及当前屏幕。若本轮有新包，由你完成上传/测试组分发，确认后才让用户更新。不要让用户自己点 Actions。
2. 一次只让用户点“屏幕使用时间授权”；收到反馈后核实真实授权状态。失败立即停下，查看脱敏结果并修复。
3. 授权成功再选两个 App，随后单独让用户关闭重开，确认数量/选择保留；不要要求公开 App 身份。
4. 再请求通知权限，发送“普通测试通知”，请用户返回桌面观察。记录通知实际出现于手机/通知中心/Watch，或未看到；不要把 API 请求成功当成可见送达。必要时仅指导检查 Everwhile 的通知设置，不要求全局关掉专注模式等生活设置。
5. 无任何一步需要使用目标 App 满 5/30 分钟，也不要求打开 Today 验收。

**持有人自然语言回复即可，由你写报告。** 等待用户操作用 `WAITING_FOR_OWNER_TEST`，保留当前任务上下文。遇到缺按钮/页面不一致，先核对 build 和源码，不让用户继续找不存在的功能。新代码只复测影响项；失败不进入 S00-B。

## 交付与停止点

创建/更新同一 PR，并提交：

```text
reports/S00-A/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
  evidence/
```

逐项给出：签名核验、Screen Time 授权、选择持久化、普通通知请求、用户可见通知、测试与 CI。注明每项来自静态检查/运行日志/用户口述/截图，未做的写 NOT_RUN。用户截图需要公开授权和脱敏；未经允许只提交文字结果。

记录 base/code/tested/upload SHA、PR head、精确 version/build、环境、实际命令和 run URL。测试成功后为 `READY_FOR_AUDIT`，不自合并、不自批准、不改下一阶段 READY。

如果需要持有人本人操作后台，先提供不可自动解决的具体错误、哪个 App ID/字段、为什么非本人不可。不要索取私钥。普通工程错误由你修。

### 本轮不做

不做真实时长 5–30 分钟带测、全天报时、间隔设置、report 重构、结构化使用数据导出、App Group、Watch、AI、账号、付费、App Review 或公开上架。S00-B 的重启去重/配置不一致问题需保留待办，不偷渡为本轮大改。

### 返回云端的最终摘要

PR URL；code/tested/upload SHA；version/build；自动检查结果；逐项设备结果；证据路径；剩余 P0/P1 或真实阻塞；状态 READY_FOR_AUDIT 或未完成原因。

不要在工程修好但设备未验时结束整个任务。先在 Codex 对话里带持有人完成当前基础检查，再回传云端审核。
