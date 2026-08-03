# 问题跟踪器：本地 Markdown

此仓库的问题和规格说明（spec，也可能称为 PRD）以 Markdown 文件形式存放在 `.scratch/` 中。

## 约定（Conventions）

- 每项功能使用一个目录：`.scratch/<feature-slug>/`
- 规格说明位于 `.scratch/<feature-slug>/spec.md`
- 每张实现工单各用一个文件，路径为 `.scratch/<feature-slug>/issues/<NN>-<slug>.md`，从 `01` 开始编号——绝不能合并成单个工单文件
- 分流状态（triage state）记录在每个问题文件顶部附近的 `Status:` 行中（角色字符串见 `triage-labels.md`）
- 评论和对话历史追加到文件底部的 `## Comments` 标题下

## 当技能要求“发布到问题跟踪器”时

在 `.scratch/<feature-slug>/` 下创建新文件（如有需要，先创建目录）。

## 当技能要求“获取相关工单”时

读取引用路径处的文件。用户通常会直接提供路径或问题编号。

## 寻路操作（Wayfinding operations）

供 `/wayfinder` 使用。**地图（map）**是一个文件，每张工单对应一个**子文件（child）**。

- **地图（Map）**：`.scratch/<effort>/map.md`——正文包含 Notes / Decisions-so-far / Fog。
- **子工单（Child ticket）**：`.scratch/<effort>/issues/NN-<slug>.md`，从 `01` 开始编号，问题写在正文中。`Type:` 行记录工单类型（`research`/`prototype`/`grilling`/`task`）；`Status:` 行记录 `claimed`/`resolved`。
- **阻塞（Blocking）**：顶部附近使用 `Blocked by: NN, NN` 行。当其中列出的每个文件都是 `resolved` 时，工单解除阻塞。
- **前沿（Frontier）**：扫描 `.scratch/<effort>/issues/`，查找开放、未阻塞且无人认领的文件；编号最小者优先。
- **认领（Claim）**：开始任何工作前，设置 `Status: claimed` 并保存。
- **解决（Resolve）**：把答案追加到 `## Answer` 标题下，设置 `Status: resolved`，再把上下文指针（摘要 + 链接）追加到 `map.md` 地图的 Decisions-so-far 中。
