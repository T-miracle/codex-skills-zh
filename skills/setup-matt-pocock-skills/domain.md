# 领域文档（Domain Docs）

工程类技能探索代码库时，应按以下方式使用此仓库的领域文档。

## 探索前先阅读

- 仓库根目录的 **`CONTEXT.md`**；或者
- 如果根目录存在 **`CONTEXT-MAP.md`**，则读取它——该文件会为每个上下文指向一个 `CONTEXT.md`。阅读其中所有与当前主题相关的文件。
- **`docs/adr/`**——阅读涉及即将处理区域的 ADR。在多上下文仓库中，还要检查 `src/<context>/docs/adr/` 中限定于该上下文的决策。

如果其中任何文件不存在，**静默继续（proceed silently）**。不要指出缺失，也不要预先建议创建。`/domain-modeling` 技能（通过 `/grill-with-docs` 和 `/improve-codebase-architecture` 触达）会在术语或决策真正得到解决时按需创建它们。

## 文件结构

单上下文仓库（大多数仓库）：

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

多上下文仓库（根目录存在 `CONTEXT-MAP.md`）：

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← system-wide decisions
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← context-specific decisions
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## 使用术语表词汇

当输出中要命名某个领域概念时（例如问题标题、重构提案、假设或测试名称），使用 `CONTEXT.md` 中定义的术语。不要漂移到术语表明确要求避免的同义词。

如果所需概念尚未出现在术语表中，这就是一个信号——要么你正在创造项目没有使用的语言（应重新考虑），要么确实存在缺口（记录下来交给 `/domain-modeling`）。

## 标记 ADR 冲突

如果输出与现有 ADR 矛盾，应明确揭示冲突，而不是静默覆盖：

> _与 ADR-0007（事件溯源订单）矛盾——但值得重新讨论，因为……_
