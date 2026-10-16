---
name: ask-matt
description: "根据当前情境推荐合适的 skill 或工作流；作为本仓库已收录技能的路由入口。"
---

# 询问 Matt（Ask Matt）

不必记住每个技能，直接询问适合当前情境的流程。

说明某个技能的职责或建议跳过某一步骤之前，先读取该技能的 `SKILL.md`；这里的摘要仅供定位。

**流程（flow）**是一条穿过技能的路径。大多数路径沿**主流程（main flow）**前进，**入口支线（on-ramps）**汇入其中。其他技能独立运行，或提供底层词汇。

## 主流程：想法 → 交付（idea → ship）

1. **`/grill-with-docs`**：通过访谈磨砺想法。在工作目录中从这里开始，将认知保存在 `GLOSSARY.md` 和 ADR 中。没有工作目录时使用 `/grill-me`；两者都使用 `/grilling`，前者会留下书面记录。
2. **需要可运行的答案吗？**如果状态、业务逻辑或 UI 无法仅靠对话确定，就绕道 `/prototype`。原型位于独立目录，使用 `/handoff` 导出上下文，在新会话中构建原型，再把获得的认知交接回原始想法会话。
3. **这是跨会话的构建吗？**
   - **是**：使用 `/to-spec` 综合规格，再用 `/to-tickets` 按用户选择的场景拆分或曳光弹工单（tracer-bullet tickets）模式组织工单，声明**阻塞边（blocking edges）**；尚未选择时由该技能询问。随后选择一种实施方式：
     - 每个工单使用一次 `/implement`，工单之间使用 `/clear` 清空上下文。本地跟踪器在 `.scratch/<feature>/issues/` 中逐工单存放文件，按阻塞项优先顺序处理；真实跟踪器使用原生阻塞关系，任何阻塞项已完成的工单都可领取。每个工单自足，前一个工单的上下文可以丢弃。
     - 使用 `/implement-spec` 一次实施整份规格。它把工单视为任务图（task graph），在可领取前沿（frontier）并行运行实施子代理，最终汇入一条集成分支（integration branch）。适用于希望编排整次构建的情况。
   - **否**：在当前上下文中直接使用 `/implement`。

   两种方式都使用 `/tdd`，一次完成一个红绿切片，并以 `/code-review` 沿 Standards + Spec 两轴收尾。`/implement` 每项工作都测试和审查；`/implement-spec` 的各实施代理使用 TDD，最后统一审查集成分支。只有具体行为需要测试优先开发时，可单独使用 `/tdd`；需要依据固定点审查分支或 PR 时，可单独使用 `/code-review`。

   创建 PR 时使用 `/pr` 编写正文：最小图示、前后证据，以及单向门或双向门判断。它允许模型隐式调用。
4. **`/retro`**：构建后复盘会话，尤其适用于遇到波折的构建。它提出改进智能体环境的建议：导航指针、自动检查、审查规范、引导文件和工具。机械性错误转为确定性检查，判断性事项转为编码规范，让后续构建获得更好的环境。

### 上下文卫生（Context hygiene）

将追问、规格和工单保持在一个不中断的上下文窗口中：完成 `/to-tickets` 前不要压缩或清空，使它们建立在同一套推理上。随后每个 `/implement` 从新上下文开始，以工单为依据。清空前在被复盘的会话中运行 `/retro`；已经清空时，向它提供该会话日志。

限制来自[智能区（smart zone）](https://www.aihero.dev/ai-coding-dictionary/smart-zone)。上游以先进模型约 150k tokens 作为参考；实际应结合模型与当前上下文判断。若在 `/to-tickets` 前接近有效窗口上限，在最近的阶段边界使用 `/compact` 后继续，按下文的阶段边界决策树选择。

## 入口支线（On-ramps）

- **缺陷和外部请求堆积** → **`/triage`**。议题经过分诊角色，形成智能体可领取的简报，供 `/implement` 实施。只分诊未经处理的外部输入；`/to-tickets` 生成的工单已经准备好实施。
- **有东西坏了** → **`/diagnosing-bugs`**。用于棘手缺陷、间歇性失败或两个已知正确状态之间的回退。先建立已经能在当前缺陷上变红的紧密反馈循环（tight feedback loop），再用回归测试修复。修复后在同一会话运行 `/retro`，评估如何预防；若问题是缺少可锁定行为的接缝，再考虑 `/improve-codebase-architecture`。
- **大型、充满未知的工作** → **`/wayfinder`**。将未决问题绘成由决策工单（decision tickets）组成的共享地图（shared map），逐项解决直到路线清晰。它投入较高，适用于单次会话无法掌握的想法；范围已经明确的功能从主流程开始。地图清晰后交接给 `/to-spec`，将链接中的决策综合成可构建计划，再拆工单并实施。只有工作最终足够小时才直接进入 `/implement`。

## 代码库健康（Codebase health）

- **`/improve-codebase-architecture`**：寻找深化机会（deepening opportunities），按用户方向或近期改动确定范围。选中候选项后，可在 `/grill-with-docs` 处进入主流程；`/codebase-design` 提供设计候选项的词汇。

## 底层词汇（Vocabulary underneath）

- **`/domain-modeling`**：磨砺领域语言，澄清模糊或多义术语，将难以逆转的决策记录为 ADR，维护 `GLOSSARY.md`。
- **`/codebase-design`**：设计深模块（deep modules）的形态，使用 module、interface、depth、seam、adapter、leverage、locality，在清晰接缝上的小接口后放置大量行为。`/tdd` 与架构评估都使用它。

## 阶段边界（Phase boundaries）

阶段是一块完整工作，例如追问、实现、QA。在两个阶段之间按顺序选择：

- **继续（Continue）**：下一阶段需要完整推理，或当前窗口足够时，留在当前会话。
- **`/clear`**：当前上下文与下一阶段完全无关时清空。
- **`/handoff`**：更换执行工具、目录、同事，或在阶段中途分出支线时，写出可移植文件。
- **子代理（Subagent）**：范围明确且无需实时引导的任务，交给独立窗口执行并返回报告。
- **`/compact`**：前面都不适用时，压缩相关上下文，保留下一阶段需要的信息。

阅读 [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) 获取完整决策树。只在阶段边界作选择；阶段中途继续，或将可独立执行的剩余工作分给子代理。

## 独立技能（Standalone）

- **`/grill-me`**：没有工作目录时的无状态访谈，不保存本地内容；在工作目录中优先使用留下记录的 `/grill-with-docs`。
- **`/grilling`**：访谈原语，按轮次处理当前问题前沿。事实由智能体查清，决策由用户作出。多个流程在内部使用它，也可直接使用。
- **`/prototype`**：用一次性代码回答一个设计问题。将验证的决策吸收到真实代码，并把原型保存在 main 之外的 `prototype/<name>` 分支上，作为一手来源（primary source），从实现议题中链接。
- **`/research`**：由后台智能体（background agent）调查一手来源（primary sources），生成带引用的仓库 Markdown 文件；调研材料可带入 `/grill-with-docs`。
- **`/wait-what`**：上一条解释没有讲清楚时，补充背景，用简明语言和 `GLOSSARY.md` 中的领域词汇重新说明，可在任意流程中使用。
- **`/teach`**：以当前目录作为有状态工作区，跨会话学习概念。
- **`/writing-for-agents`**：编写和编辑智能体会阅读的技能、AGENTS.md 与指针文档。

本仓库另有前端组件组织、Vue 实现、API 对接、注释维护、`/git-commit` 和 `/usage-disclosure` 等本地技能，按其描述选择。`/git-commit` 使用 Conventional Commits；`/usage-disclosure` 说明回复实际使用的技能。

## 前置条件（Precondition）

首次运行工程流程前，用户运行 **`/setup-matt-pocock-skills`**，配置议题跟踪器、分诊标签和文档布局，也可指定自定义跟踪器。
