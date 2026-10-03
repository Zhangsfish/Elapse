# STATUS

Updated: 2026-10-03

## 当前结论

**S00-A COMPLETE — PASS_WITH_NOTES。S00-B WAITING_FOR_OWNER_TEST；S00-C 及之后阶段 LOCKED。**

PR #14 的精确 head `bf5530e22a338150dd45408e4702651bc4711064` 已由云端独立审核并合并为 `044841658fb990324c13224cb592402f0540c80a`。审计见 [S00-A cloud audit](audits/S00/S00_A_AUDIT_2026-10-03.md)。

Everwhile `0.1.0 (27.1)` 现作为已接受的 S00-A 设备基础：最终上传 IPA 的主 App、Monitor、Report 三主体均验证了有效 distribution code signature、Family Controls signature claim=true、embedded profile allowance=true；Apple processing VALID / INTERNAL_ONLY / IN_BETA_TESTING；持有人完成 individual 授权、两个 App 的 app-relaunch 持久化、普通测试通知可见及 Running → Stopped 基础操作。

旧 build 19.1 的 ITMS-90897 不再作为 27.1 的未关闭签名阻塞。

## 唯一当前任务

**[S00-B：第一次真实 5 分钟共享池报时](prompts/S00_B_FIRST_REAL_PULSE.md)**

目标只到：

- 两个所选 App 的同一共享池；
- 第一个真实 5 分钟 threshold；
- Windows + iPhone/TestFlight 可取得的 callback / notification-request 脱敏诊断；
- 同日新的 experiment 可再次测试，不被旧 receipt 抑制；
- stale callback 不冒充当前 experiment；
- selection 与已登记监控配置一致；
- 修正 `includesPastActivity=false` 与“today”文案口径。

**持有人之前看到的一次英文五分钟提醒只是历史观察，不构成 S00-B PASS。**

Codex 启动仍从 [handoff/CODEX_START.md](handoff/CODEX_START.md) 进入，并以本 STATUS 为当前调度权威。

## 已接受基线

| 项目 | 当前状态 | 证据 / 限制 |
|---|---|---|
| S00-A cloud audit | **PASS_WITH_NOTES** | `audits/S00/S00_A_AUDIT_2026-10-03.md` |
| 27.1 最终 Family Controls 签名 | **PASS** | upload run 37120646140；三主体 claim + profile allowance 均 TRUE |
| 27.1 Apple processing / internal availability | **PASS** | VALID / INTERNAL_ONLY / IN_BETA_TESTING / internal group assigned |
| 27.1 真机安装 | **PASS — OWNER** | App 内版本 0.1.0 (27.1) |
| individual authorization | **PASS — OWNER** | S00-A device evidence |
| 两 App 选择 + app relaunch 保留 | **PASS — OWNER** | S00-A device evidence |
| 普通通知自检 | **PASS — OWNER visible banner** | 与 Screen Time threshold 分开 |
| monitor Running → Stopped | **PASS — OWNER** | 不推断停止后的迟到 callback |
| 共享池 5 分钟完整 gate | **NOT_RUN / S00-B** | 历史英文五分钟 banner 不足以通过 |
| 10–30 分钟连续 pulse | LOCKED | S00-C |
| Today 真实报告 | LOCKED | S00-D |
| 全天 / interval 配置 / 恢复 | LOCKED | S01 |

## S00-A 审计 notes

- `reports/S00-A/round-01/evidence/SIGNING_AND_TESTFLIGHT.md` 是签名时点的 scoped snapshot，末句关于设备 NOT_RUN 已被后续 `DEVICE_OBSERVATIONS.md` 更新；不要把那句旧状态当当前调度。
- Codex S00-A 分支从 merge-base `b2a2e85...` 分出，比当时 main 少一个纯 handoff 文档 commit `c703d87...`；merge 后该 handoff 已保留，无运行代码丢失。
- 普通 CI 中 helper 的 READ_ERROR / FAIL 行是负例测试输出，不是最终分发失败。

## 调度表

| 阶段 | 状态 | 目的 |
|---|---|---|
| S00-A | **COMPLETE — PASS_WITH_NOTES** | 最终签名、授权、选 App/保存、普通通知自检 |
| S00-B | **WAITING_FOR_OWNER_TEST** | PR #15：`0.1.0 (32.1)` 普通 CI、最终 App Group 签名/profile、TestFlight `VALID`/内部组分配 PASS；两轮真实 5 分钟和设备诊断仍 NOT_RUN。证据见 `reports/S00-B/round-01/` |
| S00-C | LOCKED | 10–30 分钟连续提醒、切换/停止/迟到/重复 |
| S00-D | LOCKED | Today 的真实各 App 总量与小时汇总 |
| S01 | LOCKED | 全天、间隔配置、跨日/重启/撤权/恢复 |
| S02 | LOCKED | 轻量正式体验与回顾呈现 |
| S03 | LOCKED / OWNER_RELEASE_REQUIRED | 公开分发准备，非当前上架授权 |

## 分工

Codex 负责 S00-B 实现、真实 CI/必要的内部 TestFlight、在同一个 Codex 对话中一次一个动作带持有人完成所需真机测试、修复并整理 `reports/S00-B/`。等待设备反馈时为 `WAITING_FOR_OWNER_TEST`；完成必需证据后为 `READY_FOR_AUDIT`。

云端 ChatGPT 读取实际 diff、完整关键源码、CI/log、reports 和设备证据后给精确 SHA verdict；通过后由云端 merge 并解锁 S00-C。

持有人只做确实需要本人的 iPhone / Apple 私密账号动作，不手动 merge、不手动点 Actions、不整理测试报告。

## 固定产品边界

只报时，不裁判。无 block/shield、账号、云服务、AI、广告、评分、streak。不给 callback 条数伪造权威总量；不给小时桶伪造精确 session；不把 monitoring-start 累计量写成未经证明的自然日 Today 总量。
