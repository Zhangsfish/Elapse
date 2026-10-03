# 工作流：Codex 带测，ChatGPT 审核

Updated: 2026-10-03

本轮持有人要求采用 `Zhangsfish/lecture-asset` 的协作方式。参考该仓库 `docs/WORKFLOW.md` 与 `tasks/S00_DEVICE_ACCEPTANCE.md`；以下为 Everwhile 的当前执行规则，不是对 App 已实现能力的声明。

## 角色

- **持有人**：产品决定、本人账号/费用/法律授权、iPhone 上真实操作与观察。不负责整理工程日志、写测试报告、手动合并 PR 或反复点击 Actions。
- **Codex**：读取任务，检查实际代码，修改实现，运行 CI/签名检查，准备可安装版本；在自己的对话中一次给持有人一个小操作，接收反馈、定位、修复、复测、整理证据。不能远程操控持有人的手机，不能把没收到的观察写成 PASS。
- **ChatGPT 云端**：维护范围与任务，读取实际 diff/代码/CI/证据，写审计、合并通过审查的精确 SHA、释放下一阶段。本轮之后不再同时另开实现分支或在云端平行带测。规划/审计文档可由云端维护。

只有确实需要账号本人、安全确认或物理手机的动作才交给持有人。工具缺权限先记清具体限制，能由 Codex/CI 完成的工程操作不要交给持有人。任何 agent 都不会仅因 GitHub 更新而自动在后台工作；会话需由持有人触发。

## 唯一调度入口

`STATUS.md` 是当前调度事实源；`docs/EXECUTION_PLAN.md` 是阶段边界；`prompts/` 中仅 STATUS 指定的任务有效；`reports/` 是 Codex 交付；`audits/` 是云端审计。

旧 prompt、旧 audit 中的 Next action 是历史，不是新任务。一次只允许一个 READY/IN_PROGRESS 实现子阶段，不重建仓库、不更换现有 Bundle IDs，不覆盖别人正在做的分支。

## 一轮如何进行

1. 持有人把 `handoff/CODEX_START.md` 入口交给 Codex。
2. Codex 同步 main，确认当前 READY 任务、已有 PR、已安装 build 和 base SHA。读实际代码后才给测试操作。
3. 在一个 `codex/...` 分支完成当前子阶段。先解决静态检查/编译/权限/可观察性阻塞，再要求用户花时间测试。
4. 需要新包时，复用现有内部 TestFlight 凭据与工作流。此项目已有持续内部测试授权；不等于 App Review、公开上架、邀请其他测试者或扩大账号权限的授权。
5. Codex 给出确切可安装 version/build，并确认已分发到持有人的测试组。仅有 upload accepted / VALID 不算已分发或已安装。
6. **Codex 留在同一任务中带测**：一次一个动作，使用实际页面按钮名称；先说预期观察，再等持有人回复。出错就停在该步修复，不让用户继续后续无意义测试。等待手机观察时标记 `WAITING_FOR_OWNER_TEST`。
7. 修复只复测受影响项；新 build 不沿用未经核实的旧设备结果。无需为复测反复卸载、清空屏幕使用时间、重配密钥或长时间刷 App。
8. 通过当前子阶段必需检查后整理 PR/证据，标记 `READY_FOR_AUDIT`，停止等审。Codex 不自批、不自合并、不将下一阶段设为 READY。
9. 云端读取 diff、关键完整源码、测试代码、原始 CI 结果及设备观察；给出 PASS / PASS_WITH_NOTES / CHANGES_REQUESTED / BLOCKED_ENV / BLOCKED_OWNER。批准必须绑定 head SHA；实现变化后旧审计失效。
10. 云端合并批准 SHA 并更新 STATUS，下一阶段才解锁。

## 用户负担与证据

设备日志不可默认从 Windows/TestFlight 取出。若验收依赖扩展回调，必须先提供可实际取得的、脱敏的诊断路径；不能要求持有人打开不存在的诊断页或读取 OSLog。

用户可以自然语言回复，不必填写表格。Codex 负责转成：

```text
reports/S00-A/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
  evidence/                 仅必要的脱敏日志/截图
```

报告记录任务 ID、base/code/tested/upload SHA、PR head、version/build、环境、实际命令、CI/run URL、每项 PASS/FAIL/NOT_RUN 与来源。分别标记代码推断、自动化结果、用户口述、截图和未观察信息。时间使用相对值即可；不提交 app tokens、其他 App 通知、Apple 账号、私钥、profile、UDID。

截图不默认允许公开提交；获得持有人同意后脱敏，或只保留文字观察。签名原始资料只留在临时 CI 环境，公开输出固定检查项和布尔/错误分类。

## 不能混淆的状态

源码存在 ≠ 编译通过 ≠ 最终签名正确 ≠ Apple 上传接受 ≠ processing VALID ≠ tester 可访问 ≠ 已安装 ≠ 授权成功 ≠ 阈值回调成功 ≠ 通知请求成功 ≠ 用户看到了通知。

`startMonitoring` 返回成功只证明登记调用成功，不能证明时间计量已运行。普通测试通知不能证明 Screen Time 阈值链路。report 空白不能直接当作零使用。

P0/P1 或必需设备证据缺失时不能 PASS。账号操作必须给出具体阻塞证据和最小动作，不猜测是持有人配置错了。
