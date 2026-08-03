---
name: to-spec
description: "将当前对话综合为 spec 并发布到项目 issue tracker；不进行访谈，只整理已经讨论的内容。"
---

本技能根据当前对话上下文和对代码库的理解生成一份规格文档（spec，也称 PRD）。不要访谈用户——只综合你已经掌握的信息。

你应当已经获得议题跟踪器（issue tracker）和分诊标签词汇（triage label vocabulary）；如果没有，请运行 `/setup-matt-pocock-skills`。

## 流程

1. 如果尚未探索仓库，就先了解代码库的当前状态。在整份规格中使用项目领域词汇表（domain glossary）中的术语，并遵守所涉及区域的所有 ADR。

2. 勾勒出将用于测试该功能的接缝（seams）。优先使用现有接缝而不是新接缝，并尽可能采用最高层接缝。如果确实需要新接缝，就在尽可能高的层级提出。代码库中的接缝越少越好——理想数量是一个。

向用户确认这些接缝是否符合其预期。

3. 使用以下模板编写规格，然后发布到项目议题跟踪器。应用 `ready-for-agent` 分诊标签——无需进行其他分诊。

<spec-template>

## Problem Statement

从用户视角描述用户面临的问题。

## Solution

从用户视角描述问题的解决方案。

## User Stories

一份很长的编号用户故事（user stories）列表。每个用户故事都应采用以下格式：

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

用户故事列表应当极其详尽，并覆盖该功能的所有方面。

## Implementation Decisions

列出已经做出的实现决策，可以包括：

- 将要构建或修改的模块
- 将要修改的模块接口
- 开发者给出的技术澄清
- 架构决策
- 模式变更
- API 契约（API contracts）
- 具体交互

不要包含具体文件路径或代码片段。它们可能很快过时。

例外：如果原型生成的片段能够比文字更精确地表达某项决策（状态机、reducer、模式、类型形状），就在相关决策中内联该片段，并简要注明其来自原型。只保留承载决策的部分——不要放入可运行的演示，只保留重要内容。

## Testing Decisions

列出已经做出的测试决策，包括：

- 对良好测试的说明（只测试外部行为，不测试实现细节）
- 将要测试哪些模块
- 可供这些测试借鉴的先例（即代码库中类似类型的测试）

## Out of Scope

描述本规格范围之外的事项。

## Further Notes

关于该功能的其他说明。

</spec-template>
