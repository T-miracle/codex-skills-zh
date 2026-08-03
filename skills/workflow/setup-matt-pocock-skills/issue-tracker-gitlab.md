# 问题跟踪器：GitLab

此仓库的问题和 PRD 都以 GitLab issue 的形式存在。所有操作都使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI。

## 约定（Conventions）

- **创建问题（Create an issue）**：`glab issue create --title "..." --description "..."`。多行说明使用 heredoc；传入 `--description -` 可打开编辑器。
- **读取问题（Read an issue）**：`glab issue view <number> --comments`。使用 `-F json` 获取机器可读输出。
- **列出问题（List issues）**：`glab issue list -F json`，并使用适当的 `--label` 筛选器。
- **评论问题（Comment on an issue）**：`glab issue note <number> --message "..."`。GitLab 把评论称为“notes”。
- **应用／移除标签（Apply / remove labels）**：`glab issue update <number> --label "..."` / `--unlabel "..."`。多个标签可以逗号分隔，也可以重复传入标志。
- **关闭（Close）**：`glab issue close <number>`。`glab issue close` 不接受关闭评论，因此先用 `glab issue note <number> --message "..."` 发布说明，再关闭问题。
- **合并请求（Merge requests）**：GitLab 把 PR 称为“merge requests”。使用 `glab mr create`、`glab mr view`、`glab mr note` 等——形式与 `gh pr ...` 相同，只是用 `mr` 代替 `pr`，用 `note`/`--message` 代替 `comment`/`--body`。

从 `git remote -v` 推断仓库——在克隆目录内运行时，`glab` 会自动完成这一步。

## 将合并请求作为分流入口

**将 MR 作为请求入口：no。** _（如果此仓库把外部合并请求视为功能请求，请设置为 `yes`；`/triage` 会读取此标志。）_

设置为 `yes` 后，MR 使用与 issue 相同的标签和状态，并采用对应的 `glab mr` 命令：

- **读取 MR（Read an MR）**：`glab mr view <number> --comments`，并用 `glab mr diff <number>` 获取差异。
- **列出待分流的外部 MR（List external MRs for triage）**：运行 `glab mr list -F json`，然后只保留作者不是项目成员／所有者的 MR（即贡献者提交的 MR，而不是维护者正在进行的工作）。
- **评论／加标签／关闭（Comment / label / close）**：`glab mr note`、`glab mr update --label`/`--unlabel`、`glab mr close`。

与 GitHub 不同，GitLab 分别为 issue 和 MR 编号，因此只要知道维护者指的是哪种入口，`#42` 就没有歧义。

## 当技能要求“发布到问题跟踪器”时

创建一个 GitLab issue。

## 当技能要求“获取相关工单”时

运行 `glab issue view <number> --comments`。

## 寻路操作（Wayfinding operations）

供 `/wayfinder` 使用。**地图（map）**是一个 issue，**子项（child）** issue 则作为工单。

- **地图（Map）**：带有 `wayfinder:map` 标签的单个 issue，正文包含 Notes / Decisions-so-far / Fog。使用 `glab issue create --label wayfinder:map`。（在支持原生 epic 的 GitLab 层级中，也可由 epic 承载地图；带标签的 issue 在所有层级都可用。）
- **子工单（Child ticket）**：说明顶部包含 `Part of #<map>`，并带有 `wayfinder:<type>` 标签（`research`/`prototype`/`grilling`/`task`）的 issue。认领后，将工单分配给负责推进的开发者。
- **阻塞（Blocking）**：使用 GitLab 的**原生阻塞链接（native blocking link）**——这是规范且在 UI 中可见的表示。把 `/blocked_by #<n>` 快捷操作作为 note 发布（`glab issue note <child> --message "/blocked_by #<blocker>"`），即可添加链接。原生阻塞链接属于 Premium/Ultimate 功能；在免费层级（或功能不可用时），回退到说明顶部的 `Blocked by: #<n>, #<n>` 行。所有阻塞项关闭后，工单即解除阻塞。
- **前沿查询（Frontier query）**：运行 `glab issue list -F json` 并把范围限定为地图子项；排除存在开放阻塞项——指向开放 issue 的原生 `blocked_by` 链接（`glab api projects/:id/issues/:iid/links`），或 `Blocked by` 行中的开放 issue——或已有受理人的条目；按地图顺序取第一个。
- **认领（Claim）**：`glab issue update <n> --assignee @me`——这是会话中的第一次写操作。
- **解决（Resolve）**：先运行 `glab issue note <n> --message "<answer>"`，再运行 `glab issue close <n>`，随后把上下文指针（摘要 + 链接）追加到地图的 Decisions-so-far。
