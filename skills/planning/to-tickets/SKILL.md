---
name: to-tickets
description: "将 plan、spec 或当前对话拆分为 tracer-bullet tickets，为每个 ticket 声明 blocking edges，并发布到已配置 tracker；本地 tracker 使用文本边，真实 tracker 使用原生阻塞链接。"
---

# 转换为工单（To Tickets）

将计划、规格或对话拆分为一组**工单（tickets）**——曳光弹式垂直切片（tracer-bullet vertical slices），每个工单都声明会**阻塞（block）**它的其他工单。

你应当已经获得议题跟踪器和分诊标签词汇；如果没有，请运行 `/setup-matt-pocock-skills`。

## 流程

### 1. 收集上下文

以对话上下文中已有的内容为基础开展工作。如果用户通过参数传入引用（规格路径、议题编号或 URL），就获取该引用并阅读其完整正文和评论。

### 2. 探索代码库（可选）

如果尚未探索代码库，就先了解代码的当前状态。工单标题和描述应当使用项目领域词汇表（domain glossary）中的词汇，并遵守所涉及区域的 ADR。

寻找预重构（prefactor）代码的机会，使实现更加容易。“先让变更变容易，再完成这个容易的变更。”

### 3. 起草垂直切片

将工作拆分为**曳光弹（tracer bullet）**工单。

<vertical-slice-rules>

- 每个切片都沿所有层（模式、API、UI、测试）切出一条狭窄但完整的路径——必须是垂直切片，而不是单层的水平切片
- 完成的切片本身可以演示或验证
- 每个切片的规模都能装入一个全新的上下文窗口
- 所有预重构都应当先完成

</vertical-slice-rules>

为每个工单指定其**阻塞边（blocking edges）**——即在它开始前必须完成的其他工单。没有阻塞项的工单可以立即开始。

**广域重构（wide refactors）是垂直切片的例外。**一次**广域重构**是一项机械变更——例如重命名列、重新定义共享符号类型——其**爆炸半径（blast radius）**扩散到整个代码库，使一次编辑同时破坏数千个调用点，因而没有垂直切片能够以绿色状态落地。不要强行把它变成曳光弹；应当按**扩展—收缩（expand–contract）**排序。首先扩展：在旧形式旁添加新形式，确保任何内容都不损坏。然后按照爆炸半径确定批次规模（按包、按目录），分批迁移调用点；每个批次都是一个被扩展工单阻塞的独立工单。由于旧形式仍然存在，每批之间都保持 CI 为绿色。最后收缩：所有调用方都迁移完毕后删除旧形式，该工单被所有迁移批次阻塞。如果连单独批次也无法保持绿色，就保留该顺序，但让它们共享一条集成分支，并全部阻塞最终的“集成并验证”工单——只在该处承诺绿色。

### 4. 询问用户

以编号列表呈现建议的拆分方案。每个工单都要显示：

- **标题（Title）**：简短的描述性名称
- **阻塞项（Blocked by）**：必须先完成哪些其他工单（如果有）
- **交付内容（What it delivers）**：该工单实现的端到端行为

询问用户：

- 粒度是否合适？（过粗或过细）
- 阻塞边是否正确——每个工单是否只依赖真正构成其门槛的工单？
- 是否应当合并某些工单或进一步拆分？

持续迭代，直到用户批准拆分方案。

### 5. 将工单发布到已配置的跟踪器

发布已经批准的工单。具体**方式**取决于 `/setup-matt-pocock-skills` 配置的跟踪器——无论哪种方式，工单本身都相同，只有阻塞边的表现形式不同：

- **本地文件（Local files）** → 在 `.scratch/<feature-slug>/issues/<NN>-<slug>.md` 下为每个工单写一个文件，并从 `01` 开始按依赖顺序编号（阻塞项优先）。每个文件的 “Blocked by” 列出它所依赖工单的编号和标题。使用下方逐工单文件模板——每个文件只放一个工单，绝不要写成单一合并文件。
- **真实议题跟踪器（GitHub、Linear 等）** → 按依赖顺序（阻塞项优先）为每个工单发布一项议题，使每个工单的阻塞边能够引用真实标识符。如果平台具有原生阻塞或子议题关系，就使用该关系；否则将每个工单的 “Blocked by” 设置为阻塞议题。除非另有指示，否则应用 `ready-for-agent` 分诊标签——这些工单按设计就可以由智能体领取。

处理**前沿（frontier）**：即所有阻塞项都已完成的任何工单。对于纯线性链，这意味着从上到下处理。

不要关闭或修改任何父议题。

<local-ticket-template>

# <NN> — <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Status:** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking ticket, or "None — can start immediately".

</issue-template>

无论采用哪种形式，都要避免具体文件路径或代码片段——它们很快就会过时。例外：如果原型生成的片段能够比文字更精确地表达某项决策（状态机、reducer、模式、类型形状），就将其内联，并简要注明它来自原型。只保留承载决策的部分——不要放入可运行演示，只保留重要内容。

使用 `/implement` 每次处理前沿中的一个工单，并在工单之间清空上下文。
