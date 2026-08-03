---
name: improve-codebase-architecture
description: "扫描 codebase 的 deepening opportunities，生成可视化 HTML 报告，并针对选中的机会进行 grill。"
---

# 改进代码库架构（Improve Codebase Architecture）

揭示架构摩擦，并提出**深化机会（deepening opportunities）**——把浅模块（shallow modules）转变为深模块（deep modules）的重构。目标是提升可测试性（testability）和 AI 可导航性（AI-navigability）。

本命令以项目的领域模型为_依据_，并建立在共享设计词汇之上：

- 运行 `/codebase-design` 技能，获取架构词汇（**模块 module**、**接口 interface**、**深度 depth**、**接缝 seam**、**适配器 adapter**、**杠杆效应 leverage**、**局部性 locality**）及其原则（删除测试、“接口就是测试表面”“一个适配器 = 假想接缝，两个适配器 = 真实接缝”）。每项建议都必须严格使用这些术语——不要漂移到 “component”“service”“API” 或 “boundary”。
- `CONTEXT.md` 中的领域语言为良好接缝命名；`docs/adr/` 中的 ADR 记录了本命令不应重新争论的决策。

## 流程

### 1. 探索（Explore）

首先读取项目的领域词汇表（`CONTEXT.md`）以及所涉及区域的所有 ADR。

然后使用 Agent 工具，并设置 `subagent_type=Explore` 来遍历代码库。不要遵循僵化的启发式规则——自然地探索，并记录感受到摩擦的位置：

- 哪些概念需要在许多小模块之间反复跳转才能理解？
- 哪些模块是**浅的（shallow）**——接口几乎与实现一样复杂？
- 哪些纯函数只是为了可测试性而被提取，但真正的缺陷隐藏在调用方式中（缺乏**局部性 locality**）？
- 哪些紧密耦合的模块跨越接缝泄漏细节？
- 代码库中哪些部分未经测试，或者难以通过当前接口测试？

对任何疑似浅模块应用**删除测试（deletion test）**：删除它会集中复杂性，还是只会搬移复杂性？你要寻找的信号是“会集中复杂性”。

### 2. 以 HTML 报告呈现候选项

将自包含 HTML 文件写入操作系统临时目录，确保仓库中不产生文件。先从 `$TMPDIR` 解析临时目录，如果不可用则回退到 `/tmp`（Windows 上使用 `%TEMP%`），并写入 `<tmpdir>/architecture-review-<timestamp>.html`，使每次运行都生成新文件。为用户打开文件——Linux 使用 `xdg-open <path>`，macOS 使用 `open <path>`，Windows 使用 `start <path>`——并告知其绝对路径。

报告使用 **CDN 版 Tailwind** 完成布局和样式；当图、流程或序列能够可靠传达结构时，使用 **CDN 版 Mermaid** 绘图。将 Mermaid 与手工制作的 CSS/SVG 可视化混合使用——关系呈图结构（调用图、依赖、序列）时使用 Mermaid；需要更具编辑设计感的表现（质量图、剖面图、折叠动画）时使用手工 div/SVG。每个候选项都要有**改进前/改进后可视化（before/after visualisation）**。要充分视觉化。

为每个候选项渲染一张卡片，包含：

- **文件（Files）**——涉及哪些文件或模块
- **问题（Problem）**——当前架构为何产生摩擦
- **方案（Solution）**——用通俗语言说明会发生什么改变
- **收益（Benefits）**——以局部性和杠杆效应解释，并说明测试将如何改善
- **改进前/改进后图（Before / After diagram）**——并排自定义绘制，用于说明浅薄程度和深化效果
- **推荐强度（Recommendation strength）**——从 `Strong`、`Worth exploring`、`Speculative` 中选择一项，并渲染为徽章

以**首要建议（Top recommendation）**章节结束报告：说明应当首先处理哪个候选项以及原因。

**领域表述使用 CONTEXT.md 词汇，架构表述使用 `/codebase-design` 词汇。**如果 `CONTEXT.md` 定义了 “Order”，就使用“Order 接收模块”，而不是 “FooBarHandler”，也不是 “Order 服务”。

**ADR 冲突（ADR conflicts）**：如果候选项与现有 ADR 冲突，只有在摩擦真实且足以证明值得重新审视 ADR 时才提出。要在卡片中清楚标记（例如警告提示：_“与 ADR-0007 冲突——但值得重新讨论，因为……”_）。不要列出 ADR 所禁止的每一种理论重构。

完整 HTML 脚手架、图表模式和样式指南见 [HTML-REPORT.md](HTML-REPORT.md)。

此时不要提出接口方案。文件写好后询问用户：“你想探索其中哪一项？”

### 3. 追问循环（Grilling loop）

用户选定候选项后，运行 `/grilling` 技能，与用户一起沿设计树逐步深入——约束、依赖、深化后模块的形态、接缝之后放什么，以及哪些测试能够保留。

决策形成时就地处理副作用——运行 `/domain-modeling` 技能，在推进过程中持续更新领域模型：

- **要用 `CONTEXT.md` 中不存在的概念命名深化后的模块？**将该术语添加到 `CONTEXT.md`。如果文件不存在，就在此时按需创建。
- **在对话中磨砺了一个模糊术语？**立即更新 `CONTEXT.md`。
- **用户以承重理由（load-bearing reason）否决候选项？**建议创建 ADR，并这样表达：_“要我把它记录为 ADR，以免未来的架构审查再次提出同一建议吗？”_只有当未来的探索者确实需要该理由才能避免重复建议时才提出；跳过短期理由（“现在不值得”）和不言自明的理由。
- **想为深化后的模块探索备选接口？**运行 `/codebase-design` 技能，并使用其中“设计两次（design-it-twice）”的并行子智能体模式。
