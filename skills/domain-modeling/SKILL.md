---
name: domain-modeling
description: "构建并完善项目的 domain model；当用户要确定领域术语或 ubiquitous language、记录 ADR，或其他 skill 需要维护领域模型时使用。"
---

# 领域建模（Domain Modeling）

在设计过程中主动构建并磨砺项目的领域模型（domain model）。这是一项*主动*实践——质疑术语、构造边缘情形，并在词汇和决策一经明确时立即写入文档。（仅仅*读取* `CONTEXT.md` 获取词汇不属于本技能——那是任何技能都能做到的一行式习惯。本技能用于改变模型，而不只是使用模型。）

## 文件结构

大多数仓库只有一个上下文（context）：

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

如果根目录存在 `CONTEXT-MAP.md`，说明仓库具有多个上下文。该映射文件指出每个上下文所在的位置：

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

按需延迟创建文件——只有真正有内容可写时才创建。如果不存在 `CONTEXT.md`，就在第一个术语得到明确解释时创建；如果不存在 `docs/adr/`，就在第一次需要 ADR 时创建。

## 会话期间

### 依据词汇表提出质疑

当用户使用的术语与 `CONTEXT.md` 中的现有语言冲突时，立即指出：“你的词汇表将 ‘cancellation’ 定义为 X，但你现在似乎是指 Y——究竟是哪一个？”

### 磨砺模糊语言

当用户使用含糊或多义的术语时，提出一个精确的规范术语（canonical term）：“你说的是 ‘account’——你指的是 Customer 还是 User？它们是不同的概念。”

### 讨论具体情形

讨论领域关系时，用具体情形进行压力测试（stress-test）。构造能够探查边缘情形的场景，迫使用户准确界定概念之间的边界。

### 与代码交叉核对

当用户说明某项机制如何工作时，检查代码是否与其一致。如果发现矛盾，明确指出：“你的代码会取消整个 Order，但你刚才说可以部分取消——哪一种才是正确行为？”

### 就地更新 CONTEXT.md

术语一经明确，就立即更新 `CONTEXT.md`。不要积攒后批量处理——要在术语形成时当场记录。使用 [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) 中的格式。

`CONTEXT.md` 中完全不应包含实现细节。不要把 `CONTEXT.md` 当作规格（spec）、草稿区（scratch pad）或实现决策存储库。它只是词汇表，除此之外什么都不是。

### 谨慎建议 ADR

只有同时满足以下三项条件时，才建议创建 ADR：

1. **难以逆转（Hard to reverse）**——日后改变决定会产生显著成本
2. **缺少上下文时令人意外（Surprising without context）**——未来的读者会疑惑“为什么他们要这样做？”
3. **真实权衡的结果（Real trade-off）**——确实存在可选方案，并且你出于具体原因选择了其中一个

缺少其中任何一项，就不要创建 ADR。使用 [ADR-FORMAT.md](./ADR-FORMAT.md) 中的格式。
