# S01-C — calendar / permission 最小实证

Task ID: S01-C
调度状态：仅当 `STATUS.md` 标记 READY / IN_PROGRESS 时有效。
Branch: `codex/s01-c-calendar-permission`

## 目的

S01-B 的实现已经通过云端审核。S01-C **不再扩功能**，只用最小真机实证确认两个最值得确认的边界：

1. repeating schedule 在一次真实自然午夜后，确实产生新的 interval generation / anchor，而不是只有 registration 仍在；
2. Screen Time 授权真实撤销再重新授权时，Everwhile 能 fail closed 并按 S01-B 状态机恢复。

用户明确要求测试适度收口：**发现真实问题再修，不为了覆盖率折腾手机。**

## 基线

Accepted runtime/build:
- S01-B runtime: `2479f48efa62d26ca0d2972aaa56af7b96540766`
- internal build: Everwhile `0.1.0 (47.1)`
- S01-B audit: `audits/S01/S01_B_AUDIT_2026-10-05.md`

如果 47.1 的两个实测都通过，**不需要为了 S01-C 重新出包**。
只有发现 runtime bug 并修改源码时，才需要新 build + 受影响项复测。

## Gate A — 一次真实 revoke / regrant

Codex 一次只带持有人做一个手机动作。

起点：
- 两个 selected Apps；
- interval 5m；
- monitoring ON；
- recurring YES；
- 299/299；
- 当前 config / generation / anchor 记录下来。

然后真实撤销 Everwhile 的 Screen Time / Family Controls 授权。

回到 Everwhile 后，只要求确认：

- desired intent 仍为 ON；
- App 不再宣称 monitoring active；
- system registration 被停止/不再完整；
- lifecycle 显示 authorization blocked 或等价安全状态；
- 不自动弹授权 sheet、不发提醒冒充正常监控。

再通过 Everwhile 的授权入口重新授权。

重新 approved 后只要求确认：

- desired 仍为 ON；
- 自动恢复为**新 config UUID**；
- recurring YES；
- 299/299；
- 新 interval generation / anchor 能建立；
- recovery reason 能解释 authorization reapproved；
- 旧 config 不复活。

不要求刷 5 分钟 pulse。

## Gate B — 一次自然午夜 rollover

只做**自然时间流逝**，不改系统时间、不切 timezone。

午夜前监控保持 ON，记录：

- config ID；
- interval generation = N；
- 当前 anchor；
- recurring YES；
- 299/299。

不要 Stop / Start / 改 interval / 改 selection。

自然跨过午夜后，打开 Everwhile 并刷新一次诊断。

PASS 的关键不是“还显示 299/299”，而是：

- config ID 仍是同一配置；
- interval generation 变为 **N + 1**；
- interval anchor / last interval start 已变成新一天；
- recurring YES；
- 299/299；
- 没有无故 recovery/new UUID。

`intervalDidEnd` 是否恰好在截图前出现不是硬门槛；不要从缺少 end callback 推导失败。

不等待 pulse，不刷全天 App。

## timezone / DST

本轮**不要求**：
- 手动改 timezone；
- 手动改系统时间；
- 模拟 DST；
- 为此重新打包。

保留现有 Calendar-based source/unit-test 证据，并把真实 timezone/DST 作为已知残余边界记录。以后真实遇到问题再修。

## 若发现问题

只有 Gate A 或 Gate B 真失败时：
- 先记录实际现象；
- 只修对应状态机/生命周期问题；
- 跑相关测试 + 普通 CI；
- 若 runtime 变化，再出一个新 internal TestFlight build；
- 只复测受影响 gate。

不要顺手做 S02 UI。

## 交付

同一个 S01-C PR：

```text
reports/S01-C/round-01/
  DELIVERY.md
  TEST_RESULTS.json
  DEVICE_OBSERVATIONS.md
```

证据可以以 OWNER_REPORT 为主；只有关键状态难以说清时再要截图。不要公开上传包含 App 身份/使用数据的私密截图。

如果两项都通过，标记 `READY_FOR_AUDIT` 后停下：
- 不自批；
- 不 merge；
- 不解锁 S02。
