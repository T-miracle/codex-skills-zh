---
name: setup-matt-pocock-skills
description: "为工程 skills 配置当前仓库，包括 issue tracker、triage label 词汇和 domain docs 布局；首次使用其他工程 skills 前运行一次。"
---

# 配置 Matt Pocock 技能（Setup Matt Pocock's Skills）

搭建工程技能所假定的逐仓库配置（per-repo configuration）：

- **议题跟踪器（Issue tracker）**——议题存放的位置（默认使用 GitHub；也原生支持本地 Markdown）
- **分诊标签（Triage labels）**——五个规范分诊角色所使用的字符串
- **领域文档（Domain docs）**——`CONTEXT.md` 和 ADR 的存放位置，以及读取这些文档的使用方规则

这是提示驱动技能（prompt-driven skill），而不是确定性脚本（deterministic script）。先探索，再呈现发现，向用户确认，然后写入。

## 流程

### 1. 探索（Explore）

查看当前仓库以了解其初始状态。读取实际存在的内容；不要作出假设：

- `git remote -v` 和 `.git/config`——这是 GitHub 仓库吗？是哪一个？
- 仓库根目录的 `AGENTS.md` 和 `CLAUDE.md`——其中是否有文件存在？是否已经包含 `## Agent skills` 章节？
- 仓库根目录的 `CONTEXT.md` 和 `CONTEXT-MAP.md`
- `docs/adr/` 和所有 `src/*/docs/adr/` 目录
- `docs/agents/`——本技能之前生成的内容是否已经存在？
- `.scratch/`——表示本地 Markdown 议题跟踪器约定可能已经在使用
- 是否安装了 `triage` 技能？（本技能旁边存在 `triage` 技能目录，或者可用技能中包含 `triage`。）这决定是否需要运行 B 节。
- 单仓多包信号（monorepo signals）——`pnpm-workspace.yaml`、`workspaces` 字段（位于 `package.json` 中），或者非空的 `packages/*`（具有自己的 `src/`）。这些信号只会出现在真正的大型多包仓库中；缺少这些信号意味着单上下文（single-context），几乎所有仓库都是如此。

### 2. 呈现发现并询问

总结现有内容和缺失内容。然后按顺序处理各节——一次处理一节、取得一个答案，再进入下一节。

每一节都先给出推荐答案，使用户只需一个词即可接受。只有在选择确实会产生分支时才提供一行解释；如果探索已经确定答案，就完全跳过该节（未安装 `triage` 时跳过 B 节；不存在单体仓库时跳过 C 节）。

**A 节——议题跟踪器（Issue tracker）。**

> 解释：“议题跟踪器”是本仓库保存议题的位置。`to-tickets`、`triage`、`to-spec` 和 `qa` 等技能会从中读取并向其写入——它们需要知道应当调用 `gh issue create`、在 `.scratch/` 下写入 Markdown 文件，还是遵循你描述的其他工作流。请选择你实际跟踪本仓库工作的地方。

默认立场：这些技能是为 GitHub 设计的。如果 `git remote` 指向 GitHub，就建议 GitHub。如果 `git remote` 指向 GitLab（`gitlab.com` 或自托管主机），就建议 GitLab。其他情况下（或用户另有偏好时），提供以下选项：

- **GitHub**——议题位于仓库的 GitHub Issues（使用 `gh` CLI）
- **GitLab**——议题位于仓库的 GitLab Issues（使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI）
- **本地 Markdown（Local markdown）**——议题以文件形式位于本仓库的 `.scratch/<feature>/` 下（适合个人项目或没有远程仓库的项目）
- **其他（Other）**（Jira、Linear 等）——要求用户用一个段落描述工作流；本技能将其记录为自由格式文字

将选择记录在 `docs/agents/issue-tracker.md`。GitHub 和 GitLab 模板带有“将 PR 作为请求入口（PRs as a request surface）”标志，默认为**关闭**——保持关闭且不要主动提出；希望把外部 PR 纳入分诊队列的用户以后可以在文件中切换该标志。

**B 节——分诊标签词汇（Triage label vocabulary）。**如果没有安装 `triage` 技能（探索结果会告诉你），就完全跳过本节——未安装的技能不需要标签。

如果已经安装，只问一个问题：

> 你想保留默认分诊标签吗？（推荐：**是**）

默认值是五个规范角色，每个标签字符串都等于其名称：`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`。用户回答**是**时，原样写入。只有用户回答否时——通常因为其跟踪器已经使用其他名称（例如用 `bug:triage` 表示 `needs-triage`）——才收集覆盖值，使 `triage` 应用现有标签而不是创建重复项。

**C 节——领域文档（Domain docs）。**默认采用**单上下文（single-context）**——仓库根目录放置一个 `CONTEXT.md` 和 `docs/adr/`。这适合几乎所有仓库；无需询问即可写入。

只有当探索发现单仓多包信号时，才提供**多上下文（multi-context）**选项——由根目录 `CONTEXT-MAP.md` 指向各上下文的 `CONTEXT.md` 文件。然后确认用户需要哪种布局。

### 3. 确认并编辑

向用户展示以下草稿：

- 要添加的 `## Agent skills` 区块；它应加入正在编辑的 `CLAUDE.md` 或 `AGENTS.md`（选择规则见第 4 步）
- `docs/agents/issue-tracker.md`、`docs/agents/domain.md` 和 `docs/agents/triage-labels.md` 的内容（最后一个文件仅在已安装 `triage` 时显示）

写入前允许用户编辑。

### 4. 写入

**选择要编辑的文件：**

- 如果 `CLAUDE.md` 存在，编辑它。
- 否则，如果 `AGENTS.md` 存在，编辑它。
- 如果两者都不存在，询问用户要创建哪一个——不要代替用户选择。

绝不要创建 `AGENTS.md`（当 `CLAUDE.md` 已经存在时；反之亦然）——始终编辑已经存在的文件。

如果所选文件中已经存在 `## Agent skills` 区块，就就地更新其内容，不要追加重复区块。不要覆盖用户对周边章节的编辑。

区块内容：

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

包含 `### Triage labels` 子区块并写入 `docs/agents/triage-labels.md`，但仅限已经安装 `triage` 且运行了 B 节的情况。否则两者都省略。

然后以本技能目录中的种子模板为起点写入文档文件：

- [issue-tracker-github.md](./issue-tracker-github.md)——GitHub 议题跟踪器
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md)——GitLab 议题跟踪器
- [issue-tracker-local.md](./issue-tracker-local.md)——本地 Markdown 议题跟踪器
- [triage-labels.md](./triage-labels.md)——标签映射（仅当已安装 `triage` 时）
- [domain.md](./domain.md)——领域文档使用方规则和布局

对于“其他”议题跟踪器，根据用户的描述从头编写 `docs/agents/issue-tracker.md`。

### 5. 完成

告诉用户配置已经完成，并说明哪些工程技能现在会读取这些文件。提醒用户以后可以直接编辑 `docs/agents/*.md`——只有想要切换议题跟踪器或从头重新配置时，才需要再次运行本技能。
