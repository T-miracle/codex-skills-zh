---
name: codebase-design
description: "使用深模块（deep module）词汇设计或改进模块接口；当用户要寻找 deepening opportunities、决定 seam 位置、提升可测试性或 AI 可导航性，或其他 skill 需要该设计词汇时使用。"
---

# 代码库设计（Codebase Design）

设计**深模块（deep modules）**：把大量行为放在小型接口之后，将接口置于清晰的接缝（seam）上，并可通过该接口进行测试。凡是设计或重构代码，都使用这套语言和原则。目标是为调用方提供杠杆效应（leverage），为维护者提供局部性（locality），并为所有人提供可测试性（testability）。

## 词汇表

严格使用以下术语——不要用 “component”“service”“API” 或 “boundary” 替代。一致的语言正是这套词汇的意义所在。

**模块（Module）**——任何同时具有接口和实现的事物。刻意不限定规模：它可以是函数、类、包，也可以是跨层切片。_避免使用_：unit、component、service。

**接口（Interface）**——调用方正确使用模块所必须知道的一切：不仅包括类型签名，还包括不变量、顺序约束、错误模式、必需配置和性能特征。_避免使用_：API、signature（含义过窄——它们只指类型层面的表面）。

**实现（Implementation）**——模块内部的内容，即模块的代码主体。它不同于**适配器（Adapter）**：一个事物可以是小型适配器却有大型实现（例如 Postgres 仓储），也可以是大型适配器却有小型实现（例如内存 fake）。讨论接缝时使用 “adapter”；其他情况下使用 “implementation”。

**深度（Depth）**——接口上的杠杆效应：调用方（或测试）每学习一单位接口可以运用多少行为。当大量行为位于小型接口之后时，模块是**深的（deep）**；当接口几乎与实现一样复杂时，模块是**浅的（shallow）**。

**接缝（Seam）** _（Michael Feathers）_——无需在某处直接编辑就能改变行为的位置；也就是模块接口所在的*位置*。接缝放在哪里本身就是一项设计决策，它与接缝之后放什么是不同的问题。_避免使用_：boundary（与 DDD 的 bounded context 含义重叠）。

**适配器（Adapter）**——在接缝处满足某个接口的具体事物。它描述的是*角色*（填补哪个位置），而不是实质（内部是什么）。

**杠杆效应（Leverage）**——调用方从深度中获得的收益：每学习一单位接口即可获得更多能力。一份实现可以在 N 个调用点和 M 个测试中持续产生回报。

**局部性（Locality）**——维护者从深度中获得的收益：变更、缺陷、知识和验证集中在一个位置，而不是散布在各个调用方。一次修复，处处生效。

## 深模块与浅模块

**深模块（Deep module）** = 小型接口 + 大量实现：

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

**浅模块（Shallow module）** = 大型接口 + 少量实现（应避免）：

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

设计接口时，询问：

- 能否减少方法数量？
- 能否简化参数？
- 能否在内部隐藏更多复杂性？

## 原则

- **深度是接口的属性，而不是实现的属性。**深模块内部可以由小型、可模拟、可替换的部件组成——它们只是不属于接口。模块既可以有**内部接缝（internal seams）**（为实现私有，由自身测试使用），也可以在接口处有**外部接缝（external seam）**。
- **删除测试（deletion test）。**想象删除这个模块。如果复杂性随之消失，它只是传递层（pass-through）；如果复杂性重新出现在 N 个调用方中，它就在发挥应有价值。
- **接口就是测试表面（test surface）。**调用方和测试跨越同一个接缝。如果你想*越过*接口测试内部，模块的形态可能有问题。
- **一个适配器意味着假想接缝；两个适配器意味着真实接缝。**除非确实有事物会跨接缝发生变化，否则不要引入接缝。

## 为可测试性而设计

良好接口让测试自然而然：

1. **接收依赖，不要创建依赖（Accept dependencies, don't create them）。**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **返回结果，不要产生副作用（Return results, don't produce side effects）。**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **较小的表面积（Small surface area）。**方法越少，需要的测试越少；参数越少，测试设置越简单。

## 关系

- 一个**模块（Module）**恰好有一个**接口（Interface）**（它呈现给调用方和测试的表面）。
- **深度（Depth）**是**模块**的属性，以其**接口**为参照衡量。
- **接缝（Seam）**是**模块**的**接口**所在的位置。
- **适配器（Adapter）**位于**接缝**处并满足**接口**。
- **深度**为调用方产生**杠杆效应（Leverage）**，为维护者产生**局部性（Locality）**。

## 不采用的表述方式

- **把深度定义为实现行数与接口行数之比（Depth as ratio of implementation-lines to interface-lines）**（Ousterhout）：这会奖励填充实现。我们改用“深度即杠杆效应（depth-as-leverage）”。
- **把“接口（Interface）”理解为 TypeScript 的 `interface` 关键字或类的公共方法**：含义过窄——这里的接口包括调用方必须知道的每一项事实。
- **“边界（Boundary）”**：与 DDD 的 bounded context 含义重叠。请使用**接缝（seam）**或**接口（interface）**。

## 进一步深入

- **在给定依赖关系下深化模块簇（Deepening a cluster）**——参见 [DEEPENING.md](DEEPENING.md)：依赖类别、接缝纪律，以及“替换而非叠加（replace-don't-layer）”测试。
- **探索备选接口（Exploring alternative interfaces）**——参见 [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md)：启动并行子智能体，以若干截然不同的方式设计接口，然后比较其深度、局部性和接缝位置。
