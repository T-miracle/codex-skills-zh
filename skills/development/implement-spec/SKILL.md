---
name: implement-spec
description: "将 to-spec 和 to-tickets 的产物整体实施为代码，按 task graph 并行处理工单并汇入 integration branch。"
---

你已经获得一份规格（spec）。它应当关联描述实施方式的工单（tickets）。

你应当已经获得议题跟踪器；如果没有，提醒用户运行 `/setup-matt-pocock-skills`。

目标是在一条**集成分支（integration branch）**上实现整份规格，并按议题跟踪器的规则解决每个工单。

工单不是步骤清单，而是带有阻塞关系的**任务图（task graph）**，因此始终存在一组已经可以领取的**前沿工单（frontier）**。

与子代理之间的沟通应当简洁，主要使用**上下文指针（context pointers）**指向规格、工单、调研笔记和既有提交，不重复指针已经能提供的信息。

尽可能让**实施子代理（implementer subagents）**在后台运行，以提高并发度。

## 步骤（Steps）

1. 阅读规格和工单，理解任务图。

2. 可选：使用**探索子代理（exploration subagent）**调查工单需要的代码库文件或外部文档。确保它可以保存文件，并将 Markdown 笔记存到仓库外、所有后续子代理均可访问的目录，让**实施子代理（implementer subagents）**专注实现。

3. 创建集成分支。如果跟踪器通过 PR 关闭工作，或用户要求 PR，就在第 5 步第一次合并之后创建草稿 PR，并标记它解决规格和工单；没有领先 main 的提交时无法创建 PR。

4. 使用**实施子代理（implementer subagents）**实现各工单，每个子代理拥有独立 worktree 和分支。每个实施子代理都应：
   - 开始前确认 worktree 基于集成分支，否则重置到集成分支；
   - 调用 Skill 工具加载 `tdd` 来构建工单；
   - 汇报完成前，将集成分支的最新提交合并到自身分支。

5. 一个**实施子代理（implementer subagent）**完成后，使用**合并子代理（merger subagent）**把其工作合并到集成分支。

6. 如果可领取工单的**前沿（frontier）**发生变化，启动更多**实施子代理（implementer subagents）**处理新工单，使并发度最大化。

7. 全部工单完成后，在集成分支上调用 Skill 工具加载 `code-review`。由一个**实施子代理（implementer subagent）**修复审查发现的所有问题。

8. 如果存在草稿 PR，将其标记为可以审查；否则按跟踪器规则解决每个工单，并报告集成分支。

9. 清理所有**实施子代理（implementer subagent）**的 worktree。
