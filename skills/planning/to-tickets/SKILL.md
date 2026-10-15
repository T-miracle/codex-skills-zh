---
name: to-tickets
description: "将 plan、spec 或当前对话按用户选择的场景拆分或垂直切片模式组织为 tickets，声明 blocking edges 与验收验证要求，并发布到已配置 tracker。"
---

# 转换为工单（To Tickets）

将计划、规格或对话组织为工单（tickets），由用户选择**场景拆分（user scenarios）**或**垂直切片（tracer-bullet vertical slices）**。两种模式共用验收、测试和依赖规则，均保留关键行为、异常路径和回归覆盖。

你应当已经获得议题跟踪器和分诊标签词汇；如果没有，提醒用户运行 `/setup-matt-pocock-skills`。

## 流程

### 1. 确认模式与收集上下文

用户在本次请求中已明确指定模式，或本次规划已有明确选择时，直接沿用。否则先使用可用的询问窗（如 `request_user_input_async`）提供两个选项，并等待用户选择：

| 模式 | 拆单单位与取舍 |
| --- | --- |
| 场景拆分 | 一个完整用户场景包含多个紧密相关的行为，减少重复上下文和调度成本 |
| 垂直切片 | 一条狭窄但完整的端到端路径独立成单，便于细粒度交付和验证 |

没有询问窗时用文字询问。预选项、未回复或超时均不算选择，不自动采用默认模式。等待期间可以收集上下文和探索代码库，收到选择前不进入工单起草或发布。

选择仅在本次规划内有效，多轮修改沿用；用户明确切换时，按新模式重新组织草案并保留全部需求与验证要求。新的规划重新确认模式，不从上一次规划继承。

以对话上下文中已有的内容为基础开展工作。如果用户通过参数传入引用（规格路径、议题编号或 URL），就获取该引用并阅读其完整正文和评论。

### 2. 探索代码库（可选）

如果尚未探索代码库，就先了解代码的当前状态。工单标题和描述应当使用项目领域词汇表（domain glossary）中的词汇，并遵守所涉及区域的 ADR。

识别实现当前需求所必需的预重构（prefactor），结合共享代码、现有测试和受影响的调用方判断工单边界。

### 3. 按所选模式起草工单

仅应用所选模式的粒度规则，再应用下方共用规则。小需求可以只有一张工单，不设置固定工单数量。

#### 场景拆分

每张工单围绕一个完整用户场景，可以包含多个紧密相关的操作，覆盖实现该场景所需的相关层（模式、API、UI、测试），完成后可端到端演示或验证。共享实现和上下文、共同验收的行为优先合并。

只有以下理由支持继续拆分；在方案中说明具体依据：

1. 存在真实前置依赖，需要分阶段推进。
2. 存在明确的独立交付或并行实施价值，收益超过重复上下文、调度和集成成本。
3. 场景过大，单个智能体难以在一个全新的上下文窗口中可靠完成实现和验证；以需同时理解的业务规则、共享模块或验证范围等具体证据说明容量风险。

多个按钮、接口、技术层、异常分支或测试用例本身均不构成拆单理由。没有上述依据时停止拆分。

#### 垂直切片

- 每张工单沿相关层（模式、API、UI、测试）打通一条狭窄但完整的端到端路径，以可独立交付的行为为边界。
- 每个切片完成后本身可以演示或验证，规模能装入一个全新的上下文窗口。
- 同一用户场景中的不同端到端行为可以分别成单，无需满足场景模式的合并优先及三项继续拆分条件；仍不能按技术层或单个测试用例机械拆单。

#### 共用的预重构与依赖规则

工单内仍可小步实现和测试，测试粒度不决定工单粒度。仅服务于当前工单的小范围预重构并入该工单，在依赖它的实现前完成；多张工单共同依赖的必要重构才单独作为前置工单。两种模式均不要求所有预重构统一先完成。

为每个工单指定其**阻塞边（blocking edges）**：只列开始前必须完成的其他工单，不把建议顺序写成硬依赖。没有阻塞项的工单可以立即开始。

**广域重构（wide refactors）是两种模式共用的例外。**重命名列、重新定义共享符号类型等机械变更，如果其**爆炸半径（blast radius）**使端到端切片无法独立保持 CI 通过，就按**扩展—收缩（expand–contract）**排序：先添加与旧形式兼容的新形式；再按包或目录分批迁移调用方，每批依赖扩展工单，并保持 CI 通过；最后删除旧形式，该工单依赖所有迁移批次。若单独批次仍无法保持 CI 通过，则共用集成分支，保留该顺序，并让所有批次及收缩工单阻塞最终的“集成并验证”工单，仅在该处承诺 CI 通过。

#### 共用的验收与验证

- 给验收标准编号，逐项写明可观察的预期结果和验证方式。合并工单时保留所有行为要求，适合自动化的行为使用自动化测试；需人工验证时说明操作与预期结果。
- 按风险覆盖关键行为、异常与边界路径，以及受影响的已有行为和共享调用方的回归。可复用现有测试，并让同一测试覆盖多个验收项，但须明确对应关系。
- 每张工单完成时运行受影响范围的检查并记录结果。多工单功能在承担集成交付的工单中指定跨工单验证及其阻塞项；只有存在独立集成门槛时才另建验证工单。
- 在仓库和执行技能允许的范围内合并重复验证，不为每个小行为重复启动整套测试。全量测试服从现有仓库及执行技能门禁；本技能的规划不能豁免这些要求。

完成标准：工单粒度符合用户所选模式，所有需求均有工单承接，所有验收项均有验证方式，拆分理由和真实阻塞关系明确，整体交付的验证责任已落实。

### 4. 询问用户

先标明当前所选模式，再以编号列表呈现建议的拆分方案。每个工单都要显示：

- **标题（Title）**：简短的描述性名称
- **阻塞项（Blocked by）**：必须先完成哪些其他工单（如果有）
- **交付内容（What it delivers）**：该工单实现的端到端行为
- **拆分依据（Why separate）**：多工单时说明独立成单的理由
- **验收与验证（Acceptance and verification）**：验收项与验证方式、风险覆盖及整体验证归属

询问用户：

- 粒度是否合适？（过粗或过细）
- 阻塞边是否正确：每个工单是否只依赖真正构成其门槛的工单？
- 是否应当合并某些工单或进一步拆分？
- 关键行为、异常路径和回归验证是否完整？

持续迭代，直到用户批准拆分方案。

### 5. 将工单发布到已配置的跟踪器

发布已经批准的工单。具体**方式**取决于 `/setup-matt-pocock-skills` 配置的跟踪器：无论哪种方式，工单本身都相同，只有阻塞边的表现形式不同：

- **本地文件（Local files）** → 在 `.scratch/<feature-slug>/issues/<NN>-<slug>.md` 下为每个工单写一个文件，并从 `01` 开始按依赖顺序编号（阻塞项优先）。每个文件的 “Blocked by” 列出它所依赖工单的编号和标题。使用下方逐工单文件模板：每个文件只放一个工单，绝不要写成单一合并文件。
- **真实议题跟踪器（GitHub、Linear 等）** → 按依赖顺序（阻塞项优先）为每个工单发布一项议题，使每个工单的阻塞边能够引用真实标识符。平台支持时使用原生阻塞关系；否则将每个工单的 “Blocked by” 设置为阻塞议题。如果输入来自已有议题，按跟踪器文档中的操作将每个工单关联为它的子议题。除非另有指示，否则应用 `ready-for-agent` 分诊标签：这些工单按设计就可以由智能体领取。

处理**前沿（frontier）**：即所有阻塞项都已完成的任何工单。对于纯线性链，这意味着从上到下处理。

除上述子议题关联外，不要关闭或修改任何父议题。

<local-ticket-template>

# <NN>: <Ticket title>

**What to build:** the end-to-end behaviour delivered by this ticket at the chosen granularity: a complete user scenario or a narrow vertical slice.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None (can start immediately)".

**Status:** ready-for-agent

- [ ] AC1: observable behaviour and expected result
- [ ] AC2: observable behaviour and expected result

**Verification:** map every AC to an automated test or a manual check with expected results; include risk-based error, boundary and regression coverage. State the affected checks and any assigned cross-ticket integration checks. Record results when completing the ticket; preserve repository and execution-skill test gates.

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour delivered by this ticket at the chosen granularity: a complete user scenario or a narrow vertical slice.

## Acceptance criteria

- [ ] AC1: observable behaviour and expected result
- [ ] AC2: observable behaviour and expected result

## Verification

Map every AC to an automated test or a manual check with expected results; include risk-based error, boundary and regression coverage. State the affected checks and any assigned cross-ticket integration checks. Record results when completing the ticket; preserve repository and execution-skill test gates.

## Blocked by

- A reference to each blocking ticket, or "None (can start immediately)". Omit this section when blockers were set as native edges.

</issue-template>

无论采用哪种形式，都要避免具体文件路径或代码片段：它们很快就会过时。例外：如果原型生成的片段能够比文字更精确地表达某项决策（状态机、reducer、模式、类型形状），就将其内联，并简要注明它来自原型。只保留承载决策的部分：不要放入可运行演示，只保留重要内容。
