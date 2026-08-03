# CONTEXT.md 格式

## 结构（Structure）

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## 规则（Rules）

- **做出明确取舍。** 同一概念存在多个词语时，选择最合适的一个，并把其他词列在 `_Avoid_` 下。
- **保持定义紧凑。** 最多一到两句话。定义它“是什么”，而不是它“做什么”。
- **只收录此项目上下文特有的术语。** 通用编程概念（超时、错误类型、工具模式）不属于这里，即使项目大量使用它们也是如此。添加术语前先问：这是该上下文独有的概念，还是一般编程概念？只有前者应当收录。
- **出现自然聚类时按子标题分组。** 如果所有术语都属于一个连贯领域，使用扁平列表也可以。

## 单上下文与多上下文仓库

**单上下文（大多数仓库）：**仓库根目录只有一个 `CONTEXT.md`。

**多上下文：**仓库根目录的 `CONTEXT-MAP.md` 列出各上下文、所在位置及其相互关系：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments
- [Fulfillment](./src/fulfillment/CONTEXT.md) — manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

技能会推断应采用哪种结构：

- 如果存在 `CONTEXT-MAP.md`，读取它以找到各上下文
- 如果只有根目录的 `CONTEXT.md`，则为单上下文
- 如果两者都不存在，在第一个术语得到解决时按需创建根目录 `CONTEXT.md`

存在多个上下文时，推断当前主题属于哪一个；如果无法确定，就询问用户。
