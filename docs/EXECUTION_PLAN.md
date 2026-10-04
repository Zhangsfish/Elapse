# Everwhile 实现与验收顺序

Updated: 2026-10-03

目标不变：**让时间流逝被感知，不阻止、不裁判。** 保留当前 SwiftUI + FamilyControls + DeviceActivity + UserNotifications 实现，不重写产品。

当前已接受的完整 S00 基线为 Everwhile `0.1.0 (41.1)`。S00-A/B/C/D 均已完成云端 exact-SHA 审核并给出 PASS_WITH_NOTES；S00 functional acceptance 完成。S00-D 合并 commit 为 `3771b556334a5dc1b15e42287183bc9e8f1bef95`：current-user/current-iPhone Today、selected-App total/per-app/hourly aggregate 与 privacy boundary 已通过。当前由 `STATUS.md` 只解锁 S01-A。

## 顺序与门槛

当前状态只以 `STATUS.md` 为准。本表定义任务边界，不自动解锁后续工作。

| 子阶段 | 只解决什么 | 必需验收 | 后续解锁条件 |
|---|---|---|---|
| **S00-A：真机基础** | 最终签名权限核验；授权、App 选择持久化；普通通知自检；可读诊断 | 三个最终签名主体权限检查；真实 individual 授权；选择并重启保留；用户可见的明确标记测试通知 | 云端审计 PASS 后 S00-B |
| **S00-B：第一次真实报时** | 一个共享 App 池；5 分钟阈值；可取得的回调/请求诊断；可重复测试 | A 约 2 分钟 + B 约 3 分钟；未选 App/锁屏不冒充所选使用；同日重试不被旧去重记录抑制；用户观察可见通知 | 云端审计 PASS 后 S00-C |
| **S00-C：有限范围连续提醒** | 验证现有 10/15/20/25/30 分钟；切换、迟到、重复与停止行为 | 顺序/去重/停止及错误语义；记录实际偏差，不宣称系统精确准点 | 云端审计 PASS 后 S00-D |
| **S00-D：真实 Today** | 在 report 扩展内显示每日各 App 时长与小时汇总 | 明确设备/用户范围；真实数据渲染；区分加载/空数据/不可用；不伪造会话；解释与监控起点的口径差异 | S00 整体验收 PASS 后 S01 |
| **S01-A：日内全天范围 + interval** | 从固定 5–30 扩展到 current-day full-range threshold plan；default 5、可配置 interval；验证大 event ladder registration | 默认 5；至少 5/10/15/30/60；真实 iPhone 5-minute full-day candidate registration；无长时间刷 App | 云端审计后 S01-B |
| **S01-B：每日重复调度与生命周期恢复** | repeats=true、interval generation/anchor、premature callback guard、desired-vs-registration reconciliation、app/device restart recovery | 不需每天手动 Start；短 reopen + reboot 设备测试；authorization recovery source/tests | 云端审计后 S01-C |
| **S01-C：calendar / permission 实证** | 真实午夜 rollover、permission revoke/regrant、timezone/DST 边界与残余 ambiguity | 最小真实 rollover + permission recovery；timezone/DST 以可验证证据分层 | S01 整体验收后 S02 |
| **S02：轻量体验与回顾** | 稀疏明确的正式界面、中文/英文文案、报表可读性、诊断与用户界面分层 | 使用流程短；保留事实边界；默认不弹课程/打分/反思；不以美化代替可靠性 | S02 单独审计后 S03 |
| **S03：公开分发准备** | 固化内部交付；隐私/支持资料、商店文案、区域合规与外部测试 | 精确候选 build、明确区域与持有人发布授权 | 未授权不得 App Review/公开上架 |

后续每个子阶段只有在解锁时才写完整执行任务，避免一次性大 prompt 让 Codex 顺手做完整个产品。

## S00-B 已关闭问题（历史依据）

- 现有 `PulseDeliveryDecision.receiptKey` 只含日期与 event；同日 stop/start 没有独立实验 ID。不能再把 stop/start 无条件称作“完整清零”。选择可复测的会话/配置版本策略并测试旧回调，不用系统时间伪造使用量。
- 主 App 的 selection 改变后不会自动替换已登记 events。必须选择并明确实现“运行中禁止修改”或“显式重新开始并固定新配置”，不可让监控集合与 Today 所选集合悄悄不同。
- Monitor 的详细回调与请求结果只在 OSLog，主 App 看不到，当前 TestFlight/Windows 流程不能据此验收。先提供可观察诊断。若确需 App Group，只共享本 App 配置/实验 ID/脱敏回调事件；不得搬运受保护 report 数据。新增 capability 先用现有授权工具配置/验证，账号本人动作才最小化交给用户。
- `includesPastActivity=false` 是“启动后的所选使用”实验，不能把对应阈值通知写成已知的“今天总计”。阈值到达、回调接收、通知请求、实际看到通知四者分开。

## S00-D / S01 不能悄悄承诺的事

- 现有 Today 是当天小时汇总；不是 App 打开/关闭的精确时间线。
- 同一个 report 的设备范围必须明确；不能在默认查询多设备时把和称作“这台 iPhone”。
- 现有阈值只到 30 分钟；把常量改大不是已验证的全天方案。扩展前核实当前 API 限制与真实设备行为。
- 所选使用时间不是墙上时钟；用 Timer 每 5 分钟推一条通知不能替代 Screen Time 计量。
- 不能从 `回调条数 × 间隔` 得到权威总时长，不能把未看到 banner 判定为没有 callback。
- 结构化导出、精确会话、Watch、云端/AI 仍为后续独立需求；不把 EU-only 数据访问作为默认依赖，不用 App Group 绕过 report 沙箱。

## 每阶段的用户交互

Codex 先使这个阶段可测试，再逐项带持有人执行。每次只给一个实际存在的按钮/观察动作。用户回复自然语言即可；Codex 整理结果、修复并复测。云端只在交付/返工节点审核及布置下一任务。

S00-A 不要求刷 App；S00-B 才开始第一轮真实 5 分钟使用；S00-C 才要求延长到 30 分钟。后续的长期测试只在必要时安排，不让用户为未通的底层链路重复付出等待时间。
