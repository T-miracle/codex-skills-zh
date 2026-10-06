---
name: retro
description: "对编码会话进行 retrospective，提出智能体 environment、自动检查、规范与工具的改进建议。"
---

用户要求进行**复盘（retrospective）**。你需要提出改善编码智能体**环境（environment）**的建议，让后续运行更有效。

## 步骤（Steps）

1. 调用 Skill 工具加载 `writing-for-agents`，获取写作风格指南。

2. 阅读用户指定会话的一手来源，可能需要搜索本机会话日志。用户没有指定时，默认复盘当前会话。

3. 在以下类别中寻找改进候选项。

- **导航（Navigation）**：智能体找到正确文件是否容易？文件间是否有隐藏依赖？增加**导航指针（navigation pointer）**是否有帮助？_适用情形（Use when）_：会话花费很长时间寻找一项信息。
- **自动检查（Automated checks）**：是否存在能捕获智能体错误的 lint、类型、测试或文件系统检查？先读取仓库自己的检查命令，如 `package.json`/build-tool 中的 `lint` / `check` 脚本及 CI 工作流。如果检查已经存在却未接入或悄悄失效，这本身才是发现，不应重新发明。仓库没有**护栏（guardrail）**，即没有 pre-commit hook 或 CI 执行 lint、类型检查、测试，也是一项发现：缺少 lint 的仓库是持续错失的机会。_适用情形（Use when）_：智能体犯了自动检查能够捕获的错误，或仓库完全没有护栏。
- **编码规范（Coding standards）**：是否应为**审查代理（reviewer agent）**增加、删除或澄清规则？先分类：**机械性（mechanical）**违规，例如固定语法模式、禁用 API、导入形式、文件位置，必须采用确定性检查。结合仓库语言和既有护栏，选择成本最低的自定义 linter 规则、新 pre-commit hook 或 CI job；默认建立检查，而不是编写规则。把 `CODING_STANDARDS.md` 留给真正的**判断性决策（judgement calls）**，例如跨文件一致性、符合周边风格，以及无法由自动护栏替代的事项。_适用情形（Use when）_：审查代理漏掉了错误。
- **全局 AGENTS.md（Global AGENTS.md）**：是否有引导指令应移到编码规范或自动检查中？_适用情形（Use when）_：仓库或用户全局范围内的 AGENTS.md 特别庞大。
- **工具经济性（Tool economy）**：是否有昂贵工具调用可以简化？自定义 CLI、MCP 是否特别浪费 tokens？_适用情形（Use when）_：智能体进行了昂贵调用。
- **无效指令（No-ops）**：寻找没有改变智能体行为的引导指令。_适用情形（Use when）_：引导文件庞大而难以维护。
- **信息访问（Information access）**：寻找增加可访问信息的机会，例如保存开发服务器日志、提供第三方服务只读访问。_适用情形（Use when）_：智能体缺少关键信息。

4. 按严重程度向用户呈现这些候选项。

## 参考（Reference）

### 实现与审查（Implementation vs Review）

所有工作都经过实现与审查两个阶段。实施代理承担最大的**上下文压力（context pressure）**，需要探索、编写代码和调试失败。

审查代理压力最小：它收到差异，无需探索，通常也无需编写代码或调试。

因此，落实编码规范应由审查代理负责，而不是实施代理。

### 文件（Files）

仓库中可能有以下文件：

- `CLAUDE.md`/`AGENTS.md`：它们进入每个在仓库工作的智能体上下文，应极少使用，通常只放指向其他文件的**导航指针（navigation pointers）**。
- `CODING_STANDARDS.md`：在审查时读取，而非实现时。如果超过 1,000 行，增加指向文档目录的**导航指针（navigation pointers）**。
- 文档：把文档作为其他文件指向的参考；写新文档前先寻找已有文档。
- 技能：可用于参考文档，因为 description 会进入上下文窗口，也可用于用户主动调用的命令。遵循 `writing-for-agents` 的建议。
