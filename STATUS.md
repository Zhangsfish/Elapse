# STATUS

Updated: 2026-10-03

## 当前结论

**S00 原型已安装，功能尚未验收。S00-A READY；其余实现阶段 LOCKED。**

Apple 接受上传与 processing VALID 是已发生的交付事实，但 build 19.1 随后收到主 App 缺 Family Controls entitlement 的 `ITMS-90897` 警告。不能再以“TestFlight delivery PASS”概括签名/功能全部通过。当前完整可用性为 **HOLD / CHANGES_REQUESTED**。

## 唯一当前任务

**[S00-A：可验收的真机基础](prompts/S00_A_DEVICE_FOUNDATION.md)**

先由 Codex 核对最终签名、修复必要基础问题，提供可读授权/选择/通知状态及普通测试通知，再在 Codex 对话中一次一步带持有人验收。**现在不要求使用目标 App 满 5/30 分钟，不启动 Today/全天报时验收。**

启动入口：[handoff/CODEX_START.md](handoff/CODEX_START.md)。协作规则：[docs/WORKFLOW.md](docs/WORKFLOW.md)。

## 基线与证据层级

| 项目 | 当前状态 | 依据与限制 |
|---|---|---|
| App + Monitor + Report 源码、编译和六个纯逻辑测试 | 已有历史 PASS | 不能代表 Screen Time 真机行为 |
| 19.1 上传 / processing | ACCEPTED / VALID | [run 37105502155](https://github.com/Zhangsfish/Elapse/actions/runs/37105502155) |
| 内部测试安装 | OWNER_REPORTED_INSTALLED | 持有人在本会话报告安装完成；没有因此推断授权成功 |
| 最终 Family Controls 签名 | **HOLD — 未关闭 Apple 警告** | 19.1 邮件 ITMS-90897；生成文件有 key 不等于最终签名声明 key |
| individual 授权 / 选择持久化 | NOT_RUN | 等 S00-A 的针对性设备证据 |
| 普通通知自检 | NOT_IMPLEMENTED / NOT_RUN | S00-A 补足，不冒充阈值通知 |
| 实际使用共享池 / 阈值回调 / 阈值通知 | NOT_RUN | S00-B/C |
| 真实 Today 报表 | NOT_RUN | S00-D |
| 全天与间隔配置 | NOT_IMPLEMENTED | S01；现有阈值只到 30 分钟 |

已装预期基线：Everwhile `0.1.0 (19.1)`，实现 SHA `60a15650d6791ef081f6d8aa402cfb48d3a03ff1`。复核时 main `afb4a61a2e62e849b5c6e831367c90d9f2983726` 与其只差三个文档。本轮重新规划也是文档变更，不会自动更新手机 App。

完整静态问题清单：[READINESS_REVIEW_2026-10-03](audits/S00/READINESS_REVIEW_2026-10-03.md)。旧 STATUS 的时间顺序记录保留在 Git 历史 `afb4a61a2e62e849b5c6e831367c90d9f2983726:STATUS.md`；旧 Next action 不再是调度指令。

## 调度表

| 阶段 | 状态 | 目的 |
|---|---|---|
| S00-A | **READY** | 最终签名、授权、选 App/保存、普通通知自检 |
| S00-B | LOCKED | 第一次真实 5 分钟共享池通知、可观察事件、同日可重试 |
| S00-C | LOCKED | 10–30 分钟连续提醒、切换/停止/迟到/重复 |
| S00-D | LOCKED | Today 的真实各 App 总量与小时汇总 |
| S01 | LOCKED | 全天、间隔配置、跨日/重启/撤权/恢复 |
| S02 | LOCKED | 轻量正式体验与回顾呈现 |
| S03 | LOCKED / OWNER_RELEASE_REQUIRED | 公开分发准备，非当前上架授权 |

阶段定义见 [docs/EXECUTION_PLAN.md](docs/EXECUTION_PLAN.md)。旧 `prompts/S00_CODEX.md` 仅保留历史，不再执行整张全量任务。

## 分工

Codex 实现、准备 build、逐步带持有人测试、修复和整理证据。云端只派任务、读 diff/代码/CI/证据、审核和合并批准 SHA。持有人只做必要的手机动作/本人账号确认；不用手动整理报告或点 Actions/merge。

Codex 等设备反馈时为 `WAITING_FOR_OWNER_TEST`；必需测试完成后为 `READY_FOR_AUDIT`。云端审核通过才解锁下一阶段，不允许因编译通过就越级。

## 不要重做

现有 Bundle IDs 与 App Store Connect record 不变：`com.zhangsfish.elapse`、`.monitor`、`.report`。现有 `APPLE_TEAM_ID` variable + 三个 `APP_STORE_CONNECT_*` secrets 继续使用；不索取私钥、不重复配置邀请/UDID/证书。若确有账号阻塞，先给精确错误和最小必要操作。

## 固定产品边界

只报时、不裁判。无 block/shield、账号、云服务、AI、广告、评分、streak。不给小时汇总伪造精确会话；不给 callbacks 伪造总量。受保护 Screen Time 数据的结构化导出和 EU-only 增强权限不属于当前基线。
