# Codex 开始入口

Repository: `Zhangsfish/Elapse`
Product: Everwhile

1. 同步最新 main，查看 AGENTS.md、STATUS.md，确认当前唯一 READY/IN_PROGRESS 任务及是否已有实现 PR。不要重做已合并的 S00 基建。
2. 读 `docs/WORKFLOW.md`、`docs/EXECUTION_PLAN.md`，再读 STATUS 指定的 task 和对应 readiness audit。
3. 当前首次进入应执行 `prompts/S00_A_DEVICE_FOUNDATION.md`；若 STATUS 已更新，以 STATUS 为准，不把本文件的初始任务名称当永久调度。
4. **你负责实现、真实 CI/分发、逐步带持有人做手机测试、修复与整理报告。云端 ChatGPT 只审核和派下一任务。**
5. 一次一个小设备操作，用实际界面文字；等待用户自然语言回复。不要只把整张测试表交给主人，也不要要求 Windows 用户取 Mac Console/extension OSLog。
6. 当前先核对 build 19.1 的 ITMS-90897 签名风险，再完成授权、选择持久化和普通通知自检。不要先让持有人刷 App 五分钟或验收 Today。
7. 现有 Apple 配置已经完成并成功上传；不要求重配 secrets/私钥/UDID/证书。工程动作由你和 CI 完成，确需本人动作再给最小步骤。
8. 必需测试未做就写 NOT_RUN；等待手机反馈用 WAITING_FOR_OWNER_TEST；完成后给 PR/SHA/build/证据并停在 READY_FOR_AUDIT。不得自合并、自批准或解锁下一阶段。

这是任务入口，不是后台自动调度。持有人触发 Codex 会话后才开始执行。
