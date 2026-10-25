# 来源与适配

本技能选择性改写自 [rpamis/comet](https://github.com/rpamis/comet) 的 Native 工作区选择、授权沿用和 Git 收尾规则，使用 MIT License。审阅日期为 2026-10-25，分支 `master`，固定提交为 `aeb1a6598034e28ce46b8422d4dbd8785e607bd7`。

审阅文件及 GitHub 原始 UTF-8/LF 字节 SHA-256：

| 文件 | 原始 SHA-256 |
| --- | --- |
| [Native 入口](https://github.com/rpamis/comet/blob/aeb1a6598034e28ce46b8422d4dbd8785e607bd7/assets/skills-zh/comet-native/SKILL.md) | `a3482db4b019ab05b6dfddf198f64f483f268a38cb114ebb004c86dd0a1e5966` |
| [工作区与收尾参考](https://github.com/rpamis/comet/blob/aeb1a6598034e28ce46b8422d4dbd8785e607bd7/assets/skills-zh/comet-native/reference/workspace.md) | `1774f161e6464ed8ebd8ce4f3d56675324f5fccb6c75770d9f0c825416a14261` |
| [上游许可证](https://github.com/rpamis/comet/blob/aeb1a6598034e28ce46b8422d4dbd8785e607bd7/LICENSE) | `11056698cfdd79b0e8a701682ea2c647e66a7f9876c1937cac57f19fd2dead91` |

本地行为改造：

- 每个新任务首次写仓库文件前补齐工作位置和自动合并选择，适用于文档与配置，不采用上游“干净仓库默认 current”的规则。
- 沿用当前任务的有效授权，自动合并选项包含必要的本地提交；不增加上游 Shape 确认、最终结果接受及 Archive 阶段。
- 用 Git 元数据中的逐任务记录恢复选择，用共享协作锁和临时集成 worktree 串行验证、更新本地主分支。
- 不依赖 Comet CLI、SDK、Runtime、记忆或 Supervisor；不复制其状态文件与运行脚本。

这是本地行为重构，`translation_contract` 为 `false`。清单中的 `source_path` 与 `baseline_skill_sha256` 跟踪上游中文 Native 入口；工作区参考的独立变化需人工检查上表固定版本，不能仅凭入口哈希判断整个上游没有更新。
