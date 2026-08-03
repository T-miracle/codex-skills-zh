# 问题跟踪器：GitHub

此仓库的问题和 PRD 都以 GitHub issue 的形式存在。所有操作都使用 `gh` CLI。

## 约定（Conventions）

- **创建问题（Create an issue）**：`gh issue create --title "..." --body "..."`。多行正文使用 heredoc。
- **读取问题（Read an issue）**：`gh issue view <number> --comments`，使用 `jq` 筛选评论，并同时获取标签。
- **列出问题（List issues）**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，并使用适当的 `--label` 和 `--state` 筛选器。
- **评论问题（Comment on an issue）**：`gh issue comment <number> --body "..."`
- **应用／移除标签（Apply / remove labels）**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭（Close）**：`gh issue close <number> --comment "..."`

从 `git remote -v` 推断仓库——在克隆目录内运行时，`gh` 会自动完成这一步。

## 将拉取请求作为分流入口

**将 PR 作为请求入口：no。** _（如果此仓库把外部 PR 视为功能请求，请设置为 `yes`；`/triage` 会读取此标志。）_

设置为 `yes` 后，PR 使用与 issue 相同的标签和状态，并采用对应的 `gh pr` 命令：

- **读取 PR（Read a PR）**：`gh pr view <number> --comments`，并用 `gh pr diff <number>` 获取差异。
- **列出待分流的外部 PR（List external PRs for triage）**：运行 `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`，然后只保留 `authorAssociation` 为 `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR` 或 `NONE` 的条目（排除 `OWNER`/`MEMBER`/`COLLABORATOR`）。
- **评论／加标签／关闭（Comment / label / close）**：`gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub 的 issue 与 PR 共用同一编号空间，因此单独的 `#42` 可能是其中任一种——先用 `gh pr view 42` 解析，失败时再尝试 `gh issue view 42`。

## 当技能要求“发布到问题跟踪器”时

创建一个 GitHub issue。

## 当技能要求“获取相关工单”时

运行 `gh issue view <number> --comments`。

## 寻路操作（Wayfinding operations）

供 `/wayfinder` 使用。**地图（map）**是一个 issue，**子项（child）** issue 则作为工单。

- **地图（Map）**：带有 `wayfinder:map` 标签的单个 issue，正文包含 Notes / Decisions-so-far / Fog。使用 `gh issue create --label wayfinder:map`。
- **子工单（Child ticket）**：以 GitHub 子问题形式关联到地图的 issue（对子问题端点使用 `gh api`）。如果未启用子问题，就把子项加入地图正文的任务列表，并在子项正文顶部写入 `Part of #<map>`。标签为 `wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。认领后，将工单分配给负责推进的开发者。
- **阻塞（Blocking）**：使用 GitHub 的**原生问题依赖（native issue dependencies）**——这是规范且在 UI 中可见的表示。使用 `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>` 添加一条边；其中 `<blocker-db-id>` 是阻塞项的数字**数据库 ID（database id）**（通过 `gh api repos/<owner>/<repo>/issues/<n> --jq .id` 获取，_不是_ `#number` 或 `node_id`）。GitHub 在 `issue_dependencies_summary.blocked_by` 中报告依赖（只包含仍开放的阻塞项——即实时门禁）。如果依赖功能不可用，则回退到子项正文顶部的 `Blocked by: #<n>, #<n>` 行。所有阻塞项关闭后，工单即解除阻塞。
- **前沿查询（Frontier query）**：列出地图中开放的子项（`gh issue list --state open`，范围限定为地图的子问题／任务列表）；排除存在开放阻塞项（`issue_dependencies_summary.blocked_by > 0`，或 `Blocked by` 行中存在开放 issue）或已有受理人的条目；按地图顺序取第一个。
- **认领（Claim）**：`gh issue edit <n> --add-assignee @me`——这是会话中的第一次写操作。
- **解决（Resolve）**：先运行 `gh issue comment <n> --body "<answer>"`，再运行 `gh issue close <n>`，随后把上下文指针（摘要 + 链接）追加到地图的 Decisions-so-far。
