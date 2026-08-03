---
name: wayfinder
description: "规划超过单次 agent session 容量的大型工作，将其表示为 issue tracker 上的 investigation tickets 地图，并逐项解决直到路径清晰。"
---

一个松散想法出现了——它太大，无法装入一次智能体会话，并且笼罩在迷雾中：从当前位置通往**目的地（destination）**的道路尚不可见。寻路（wayfinding）的重点是找到这条路，而不是径直冲向目的地。本技能在仓库的议题跟踪器上将道路绘制成一张**共享地图（shared map）**，然后逐个处理地图中的工单，直到路线清晰。

每项工作的目的地都不相同，而为目的地命名是绘图的第一步——它决定每个工单的形态。目的地可以是一份需要交接和迭代的规格，可以是规划开始前必须锁定的决策，也可以是像数据结构迁移这样就地完成的变更。地图与领域无关（domain-agnostic）——工程工作、课程内容，或者任何符合这种形态的工作都可以使用。

## 规划，而非执行（Plan, don't do）

Wayfinder 默认用于**规划（planning）**：每个工单解决一项决策；当道路清晰时，地图即告完成——在有人真正执行工作之前，不再有任何决策需要做出。想要直接动手执行，通常意味着你已经到达地图边缘，现在该进行交接。某项工作可以在其**备注（Notes）**中覆盖这一规则——把执行本身纳入地图——但如果没有这种覆盖，就应产出决策，而不是可交付物（decisions, not deliverables）。

## 使用名称引用（Refer by name）

每张地图和每个工单都是一项议题，因此都有一个**名称（name）**——即标题。在人类阅读的所有内容中——叙述、地图的“迄今决策（Decisions-so-far）”——都使用该名称引用，绝不使用孤立的 ID、编号或 slug。满墙的 `#42, #43, #44` 无法阅读；名称则一眼可知。ID 和 URL 并不会消失——名称包裹其链接——但它们存在于名称*内部*，绝不取代名称。

## 地图（The Map）

地图是本仓库议题跟踪器上的单个议题，带有 `wayfinder:map` 标签——它是规范制品（canonical artifact）。地图中的工单都是该地图的子议题。

地图是**索引（index）**，而不是存储库。它列出已经做出的决策，并指向保存决策细节的工单；一项决策只存在于一个位置——对应工单——因此地图绝不重述决策，只提供摘要和链接。

**地图、子工单、阻塞关系和前沿查询的实际存放方式由跟踪器决定。**你应当已经获得议题跟踪器；如果没有，请运行 `/setup-matt-pocock-skills`。查阅跟踪器文档中的 “Wayfinding operations” 章节，了解_本_仓库如何表达这些内容。如果未提供跟踪器，默认使用本地 Markdown 跟踪器。

### 地图正文（The map body）

这是整张地图的低分辨率视图，每次会话只加载一次。未结工单**不会**列在其中——它们是通过查询找到的未结子议题。

```markdown
## Destination

<what reaching the end of this map looks like — the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index — one line per closed ticket: enough to judge relevance, then zoom the link for the detail the ticket holds -->

- [<closed ticket title>](link) — <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't ticket yet; graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; closed, never graduates -->
```

### 工单（Tickets）

每个工单都是地图的**子议题（child issue）**；跟踪器的议题 ID 就是其身份。工单正文是需要回答的问题，规模控制在一次 100K token 智能体会话之内：

```markdown
## Question

<the decision or investigation this ticket resolves>
```

每个工单都带有 `wayfinder:<type>` 标签——从 `research`、`prototype`、`grilling`、`task` 中选择一项（参见[工单类型](#ticket-types)）。

会话要**首先**在开展任何工作之前，把工单分配给推动地图的开发者，从而**认领（claim）**该工单，使并发会话能够跳过它。被分配者_就是_认领标记：未结且未分配的工单即为无人认领。

阻塞使用跟踪器的**原生（native）**依赖关系——这至关重要，因为它会在跟踪器自身 UI 中_可视化_呈现前沿，使人类无需打开地图就能看出哪些工单可以领取。只有缺少原生阻塞能力的跟踪器才回退到正文约定。当所有阻塞某个工单的其他工单都已关闭时，该工单就是**无阻塞的（unblocked）**；**前沿（frontier）**是所有未结、无阻塞且无人认领的子工单——即已知范围的边缘。

答案不属于正文——它会在解决工单时记录（参见[处理地图](#work-through-the-map)）。解决工单期间创建的制品从议题中链接，而不是直接粘贴进去。

## Ticket Types

每个工单要么是 **HITL（human in the loop，人类参与循环）**——与能够代表自己发言的人类*共同*处理——要么是 **AFK**，由智能体独立推动。HITL 工单只能通过实时交流解决；智能体绝不能代替人类一方作答（一个自行回答自己问题的追问智能体已经违反此规则）。

- **调研（Research）**（AFK）：阅读文档、第三方 API 或知识库等本地资源。创建 Markdown 摘要并将其作为链接制品。需要当前工作目录之外的知识时使用。
- **原型（Prototype）**（HITL）：制作廉价、粗糙但具体的制品供人反馈，从而提高讨论保真度（fidelity）——可以是大纲、初稿、存根，或者通过 /prototype 技能生成的 UI/逻辑代码。将原型作为制品链接。关键问题是“它应该是什么样”或“它应该如何表现”时使用。
- **追问（Grilling）**（HITL）：通过 /grilling 和 /domain-modeling 技能开展对话，每次一个问题。这是默认类型。
- **任务（Task）**（HITL 或 AFK）：在能够做出一项*决策*之前必须完成的手工工作——此时没有需要决定、制作原型或调研的事项，但讨论在工作完成前受到阻塞。例如注册服务以评估其 API、配置访问权限、移动数据以查看其形态。这是唯一一种侧重*执行*而不是决策的类型——它通过解除决策阻塞来证明自身价值，而不是通过交付目的地。智能体能够独立推动时就独立完成（AFK）；否则向人类提供精确检查清单（HITL）。工作完成时即告解决；答案记录完成的工作以及后续工单所依赖的事实（凭据位置、新 URL、行数）。

## 战争迷雾（Fog of war）

地图是_刻意_不完整的：不要绘制尚不可见的内容。现有工单之外是**战争迷雾（fog of war）**——你知道即将出现、却因依赖尚未解决的问题而无法准确界定的决策和调查的模糊轮廓。解决一个工单会驱散它前方的迷雾，把现在已经可以明确描述的内容提升为新工单——每次一个，直到通往目的地的道路清晰且没有剩余工单。

地图的 **Not yet specified（尚未明确）**章节用于写下这种模糊轮廓：疑似存在的问题、日后需要重新查看的区域。它是_朝向_目的地的未发现前沿——这里的一切都在范围内，只是还不够清晰，无法形成工单。根据当前可见程度，内容可以宽泛，也可以完整；它同时也是路标，让协作者看出工作正在走向何处。

**迷雾还是工单（Fog or ticket）？**判断标准是你现在能否准确陈述问题——而_不是_现在能否回答问题。

- **形成工单（Ticket）**：问题已经清晰——即使受到阻塞、目前还不能采取行动。
- **保持尚未明确（Not yet specified）**：还无法如此清晰地表述问题。不要预先把迷雾切成工单大小的碎片：迷雾比工单更粗糙；当前沿到达某片迷雾时，它可能提升为多个工单，也可能一个都没有。

**Not yet specified** 不包括已经决定的内容（Decisions so far）、已经成为现有工单的内容，以及范围外内容（见下一节）。

## 范围之外（Out of scope）

迷雾只会聚集在_朝向_目的地的方向上。目的地固定了范围，因此超出目的地的工作属于**范围之外（out of scope）**——它不是迷雾，也不属于 **Not yet specified**。地图为它设置独立的 **Out of scope** 章节：记录你有意识地排除在_本项_工作之外的内容。让内容进入这里的是范围，而不是清晰程度。

范围外工作永远不会被提升——前沿止于目的地——因此只有重新绘制目的地时它才会回来，而且会作为一项全新工作，而不是恢复旧工作。

把某项内容排除在范围外是一项范围界定行为（scoping act），而不是路线上的一步。如果某个现有工单后来被发现位于目的地之外——可能是在绘图时错误纳入，也可能因某项决议而暴露——就**关闭它**（已关闭工单明确不在前沿），并在 **Out of scope** 章节留下一行：摘要、超出范围的原因，以及指向已关闭工单的链接。不要把它放入 **Decisions so far**；后者记录实际走过的路线——范围边界并不是路线上的一步。

## 调用方式（Invocation）

有两种模式。无论哪种模式，**每次会话绝不能解决超过一个工单。**

### 绘制地图（Chart the map）

用户使用一个松散想法调用。

1. **为目的地命名（Name the destination）。**运行一次 `/grilling` 和 `/domain-modeling` 会话，确定地图正在寻找的目的地——规格、决策或变更。目的地固定范围，因此必须首先确定。
2. **绘制前沿（Map the frontier）。**再次追问，但这次采用**广度优先（breadth-first）**：向整个空间展开，而不是沿任何一个线索深入，呈现未决决策和现在可以采取的第一步。**如果没有发现迷雾**——通往目的地的道路已经清晰，整个旅程小到一次会话即可完成——就不需要地图。停止并询问用户希望如何继续。
3. **创建地图**（标签 `wayfinder:map`）：填写 Destination 和 Notes，保持 Decisions-so-far 为空，并把迷雾勾勒到 **Not yet specified** 中。
4. 把**当前已经可以明确描述的工单**创建为地图的子议题——然后在**第二遍（second pass）**连接阻塞边（议题必须先获得 ID，才能相互引用）。连接会把工单分为前沿和被阻塞项；所有尚无法明确描述的内容继续留在迷雾中——即 **Not yet specified** 章节。
5. 停止——绘制地图就是一次会话的全部工作；不要同时解决工单。

### Work through the map

用户使用地图（URL 或编号）调用。工单是**可选的**——如果没有指定，由你而不是用户选择下一项决策。

1. 加载**地图**——读取低分辨率视图，而不是每个工单的正文。
2. 选择工单。如果用户指定了工单，就使用该工单；否则按顺序选择第一个前沿工单。**认领工单（Claim it）**：开展任何工作前先把它分配给自己。
3. 解决工单——**按需放大（zoom as needed）**：按需获取任何相关或已关闭工单的完整正文；调用 `## Notes` 区块中指定的技能。如有疑问，使用 `/grilling` 和 `/domain-modeling`。
4. 记录解决结果：把答案发布为**解决评论（resolution comment）**，**关闭**议题，并向地图的 Decisions-so-far **追加上下文指针（context pointer）**。
5. 添加新出现的工单（先创建再连接）；把答案所澄清、现在已可明确描述的迷雾提升为工单，并从 **Not yet specified** 中清除每片已提升迷雾，使其只存在于新工单中。如果答案揭示某个工单——当前工单或其他工单——位于目的地之外，就将其**排除在范围外**，而不是作为路线的一部分解决。如果决策使地图的其他部分失效，就更新或删除那些工单。

用户可能并行运行无阻塞工单，因此要预期其他会话会并发编辑跟踪器。
