# STATUS

Updated: 2026-10-03

## 当前结论

**S00-A READY_FOR_AUDIT；其余实现阶段 LOCKED。** Everwhile `0.1.0 (27.1)` 已完成最终分发签名核验、上传、处理与内部组分配。持有人截图确认新版已装、屏幕使用时间已授权、通知允许且提醒开启；原选中 5 个 App，随后改选为 2 个，关闭重开 Everwhile 后仍是 2 个；普通中文测试通知在顶部横幅可见，停止监控后状态改变。持有人另说明启动监控并使用一个所选 App 约五分钟后，看到英文五分钟顶部提醒；文案与阈值通知吻合，记录为持有人目击的阈值提醒出现，不冒充完整 S00-B 验收。本轮工作分支为 `codex/s00-a-device-foundation`，基线 main `b2a2e85e57d41a284d60ab5ad028662070efa203`。

历史 build 19.1 虽 VALID，却随后收到主 App 缺 Family Controls entitlement 的 `ITMS-90897`。本轮 [upload run 37120646140](https://github.com/Zhangsfish/Elapse/actions/runs/37120646140) 对实际上传的 27.1 IPA 核验了主 App、Monitor、Report 的签名声明和 profile 授权，全部为 `true`，随后上传同一 IPA，processing `VALID`。[read-only verify run 37121122810](https://github.com/Zhangsfish/Elapse/actions/runs/37121122810) 确认 `INTERNAL_ONLY`、`IN_BETA_TESTING`、已分配内部测试组。这关闭了旧版签名缺口的仓库/上传证据，不代表真机产品行为已通过。明细见 [S00-A round 01](reports/S00-A/round-01/DELIVERY.md)。

## 唯一当前任务

**[S00-A：可验收的真机基础](prompts/S00_A_DEVICE_FOUNDATION.md)**

先由 Codex 核对最终签名、修复必要基础问题，提供可读授权/选择/通知状态及普通测试通知，再在 Codex 对话中一次一步带持有人验收。**现在不要求使用目标 App 满 5/30 分钟，不启动 Today/全天报时验收。**

启动入口：[handoff/CODEX_START.md](handoff/CODEX_START.md)。协作规则：[docs/WORKFLOW.md](docs/WORKFLOW.md)。

## 基线与证据层级

| 项目 | 当前状态 | 依据与限制 |
|---|---|---|
| App + Monitor + Report 源码、编译和六个纯逻辑测试 | 已有历史 PASS | 不能代表 Screen Time 真机行为 |
| 历史 19.1 上传 / processing | ACCEPTED / VALID，随后有 ITMS-90897 | [run 37105502155](https://github.com/Zhangsfish/Elapse/actions/runs/37105502155)；不再用它证明签名 |
| 27.1 最终 Family Controls 签名 | **PASS — 交付证据** | [run 37120646140](https://github.com/Zhangsfish/Elapse/actions/runs/37120646140)；三个 bundle 签名声明和 profile 授权分别验证 |
| 27.1 内部 TestFlight 可用性 | **PASS — Apple API** | [run 37121122810](https://github.com/Zhangsfish/Elapse/actions/runs/37121122810)；VALID / INTERNAL_ONLY / IN_BETA_TESTING / 内部组分配 |
| 27.1 手机安装 | PASS — OWNER_SCREENSHOT | App 内版本 `0.1.0 (27.1)` |
| individual 授权 | PASS — OWNER_SCREENSHOT | App 内状态“已授权”；未推断阈值行为 |
| App 选择 / 重开保留 | PASS — OWNER_REPORT | 初始截图为 5 个；持有人改选为 2 个，关闭重开 App 后仍为 2 个；未测整机重启 |
| 普通通知自检 | 请求 PASS / 可见送达 PASS — OWNER_REPORT | 中文“Everwhile 测试通知”在顶部横幅出现；不计使用时间，不冒充阈值链路 |
| 停止监控 | PASS — OWNER_SCREENSHOT | 两张截图确认 Running → Stopped；停止不清空已选 App，这是预期行为，不推断停止后的阈值回调 |
| 实际使用共享池 / 阈值回调 / 阈值通知 | 英文五分钟阈值提醒外观 PASS — OWNER_REPORT；完整 Gate NOT_RUN | 持有人开启监控、使用一个所选 App 约五分钟后看到英文提醒；未核验精确计时、共享池、回调生命周期；S00-B/C 仍 LOCKED |
| 真实 Today 报表 | NOT_RUN | S00-D |
| 全天与间隔配置 | NOT_IMPLEMENTED | S01；现有阈值只到 30 分钟 |

历史已装基线：Everwhile `0.1.0 (19.1)`，实现 SHA `60a15650d6791ef081f6d8aa402cfb48d3a03ff1`。S00-A 待手机更新目标：`0.1.0 (27.1)`，上传 SHA `88697237e5d87cfe54f858053cf1e7251bcea713`。已在 Apple 内部组可用，但是否已装必须由持有人确认。

完整静态问题清单：[READINESS_REVIEW_2026-10-03](audits/S00/READINESS_REVIEW_2026-10-03.md)。旧 STATUS 的时间顺序记录保留在 Git 历史 `afb4a61a2e62e849b5c6e831367c90d9f2983726:STATUS.md`；旧 Next action 不再是调度指令。

## 调度表

| 阶段 | 状态 | 目的 |
|---|---|---|
| S00-A | **READY_FOR_AUDIT** | 工程、内部 TestFlight 与本轮必需手机行为已有证据；等待云端审核，不自行合并或解锁下一阶段 |
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
