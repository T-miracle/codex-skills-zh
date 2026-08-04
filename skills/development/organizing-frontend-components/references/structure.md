# 前端组件统一目录参考

## 目录

- [统一目录不变量](#统一目录不变量)
- [自动选择扩展名](#自动选择扩展名)
- [所有权层级](#所有权层级)
- [文件放置矩阵](#文件放置矩阵)
- [React 范式](#react-范式)
- [Vue 范式](#vue-范式)
- [递归拆分](#递归拆分)
- [组件提升阶梯](#组件提升阶梯)
- [边界诊断](#边界诊断)

## 统一目录不变量

每个页面和组件都使用同名目录与唯一渲染入口：

```text
<ComponentName>/
├── index.<component-extension>
├── model.<ts|js>
├── hooks.<ts|js> / use<ComponentName>.<ts|js>
├── api.<ts|js>
├── types.ts
├── <styles|rules|tests|stories|mocks|...>
└── components/
    ├── <ChildA>/
    │   ├── index.<component-extension>
    │   ├── <child-owned-model-and-logic>
    │   └── components/
    │       └── <Grandchild>/
    │           └── index.<component-extension>
    └── <ChildB>/
        └── index.<component-extension>
```

应用以下固定规则：

1. 让组件目录名表达组件名，通常使用项目既有的 PascalCase 约定。
2. 让渲染实现直接位于 `index.tsx`、`index.jsx`、`index.vue`、`index.svelte` 等框架入口中。
3. 让每个私有子组件进入直接父组件的 `components/<ChildName>/`。
4. 让每个子组件递归遵守同一目录形态。
5. 让组件私有的 `model`、hooks/composables、`api`、类型、规则、样式、测试和 mock 与 `index.*` 同级共置。
6. 让叶组件停在 `index.*` 及卫星文件；省略空的 `components/`。
7. 让 feature、领域或包级 `index.ts` 只承担非渲染聚合，不作为组件渲染入口的替代层。

因此，简单组件也使用目录：`StatusTag/index.tsx` 或 `StatusTag/index.vue`，而不是直接放置 `StatusTag.tsx` 或 `StatusTag.vue`。

## 自动选择扩展名

先在目标应用或 workspace package 内建立**语言画像（language profile）**。按以下优先级收集证据：

1. 目标页面、直接父组件和相邻组件的现有后缀。
2. `tsconfig.json`、`jsconfig.json`、Vue/Svelte 的 `lang="ts"` 以及构建配置。
3. 目标 feature 或页面目录中的主流源码后缀。
4. `package.json` 中的 TypeScript、类型检查和构建工具配置。

最近所有者的现有语言优先于仓库其他区域。monorepo 按目标 package 判断；渐进迁移项目按目标 feature/page 判断。本次结构调整保持原生语言，不同时承担 JS↔TS 迁移。

| 项目原生形态 | 组件入口 | `model` / `api` / hooks / composables | 测试示例 |
| --- | --- | --- | --- |
| React + TypeScript | `index.tsx` | `.ts` | `index.test.tsx` |
| React + JavaScript | 跟随现有 `index.jsx` 或 `index.js` | `.js`，或项目既有 `.mjs/.cjs` | 跟随现有测试后缀 |
| Vue + TypeScript | `index.vue`，脚本使用 `lang="ts"` | `.ts` | `index.test.ts` |
| Vue + JavaScript | `index.vue`，脚本使用原生 JS | `.js` | `index.test.js` |
| Svelte + TypeScript | `index.svelte`，脚本使用 `lang="ts"` | `.ts` | `index.test.ts` |
| Svelte + JavaScript | `index.svelte`，脚本使用原生 JS | `.js` | `index.test.js` |

在 JavaScript 项目中，让模型和逻辑使用 `model.js`、`api.js`、`useX.js` 等现有命名；用项目既有的 JSDoc 或运行时校验表达类型。仅当仓库已经采用独立类型声明时，沿用其 `.d.ts` 或其他既有方案。

## 所有权层级

使用“最近共同所有者”确定组件目录位于哪一层；无论位于哪一层，组件内部形态保持不变。

| 使用范围 | 推荐位置 | 证据 |
| --- | --- | --- |
| 单个组件 | `<Owner>/components/<Child>/` | 只有该组件使用 |
| 单个页面的多个组件 | `<Page>/components/<Component>/` | 消费者共享同一路由和页面状态 |
| 同一 feature 的多个页面 | `<Feature>/components/<Component>/` | 共享稳定的业务语义或用例 |
| 父级内部的另一领域能力 | 对应领域的 `components/<Component>/` | 拥有另一领域实体的模型、API 与生命周期 |
| 多个 feature | 领域共享层的组件目录 | 跨页面仍保持同一领域含义 |
| 全应用、无业务语义 | UI kit 的组件目录 | 接口通用且不依赖具体 feature |

目录名可以按仓库惯例采用 `features`、`modules`、`pages`、`views` 或其他名称；组件目录不变量保持一致。

## 文件放置矩阵

| 文件或能力 | 就近放置规则 | 提升信号 |
| --- | --- | --- |
| `types.ts` / props | 放在组件 `index.*` 旁 | 多个所有者共同依赖同一契约 |
| `api.ts` / `api.js` / request adapter | 放在发起用例的页面或组件目录 | 多页面共享稳定领域操作 |
| hooks / composables | 放在拥有状态生命周期的组件目录 | 成为无 UI 的独立领域能力 |
| store | 放在实际共享状态的最近共同所有者 | 生命周期跨页面或跨 feature |
| styles / tokens | 私有样式跟随组件目录 | 设计 token 或通用视觉原语稳定复用 |
| tests | 放在被测组件 `index.*` 旁，或沿用仓库镜像约定 | 集成测试覆盖更高所有者 |
| stories / mocks / fixtures | 跟随其描述或模拟的组件目录 | 多测试共享同一领域场景 |
| constants / utils | 放在改变它们的组件或页面目录 | 语义真正通用且消费者已出现 |
| table columns / form rules | 放在表格或表单组件目录 | 多个页面共享同一业务配置 |

领域 DTO 或自动生成客户端通常属于 feature/领域基础层。页面或组件目录只保存对这些契约的私有适配和展示模型。

## React 范式

以下目录展示 TypeScript 项目；JavaScript 项目按相邻组件把入口换为 `.jsx` 或 `.js`，并把卫星文件换为项目原生 JS 后缀：

```text
OrderList/
├── index.tsx
├── index.test.tsx
├── types.ts
├── useOrderList.ts
└── components/
    ├── StatusTag/
    │   └── index.tsx
    └── OrderTable/
        ├── index.tsx
        ├── index.test.tsx
        ├── columns.ts
        ├── types.ts
        ├── useOrderTable.ts
        └── components/
            └── ColumnSettings/
                ├── index.tsx
                └── types.ts
```

页面、简单组件、复杂组件和更深子组件都采用同一个 `目录/index.tsx` 入口。

```tsx
// 目录导入解析到 OrderTable/index.tsx。
import { OrderTable } from './components/OrderTable'
```

在组件入口中直接实现并暴露组件：

```tsx
// index.tsx 是 OrderTable 唯一的渲染入口。
export function OrderTable() {
  return <section />
}

// 只转出父级需要的稳定类型。
export type { OrderTableProps } from './types'
```

## Vue 范式

以下目录展示 TypeScript 项目；JavaScript 项目保持 `index.vue`，把卫星文件换为 `.js`：

```text
OrderList/
├── index.vue
├── index.test.ts
├── types.ts
├── useOrderList.ts
└── components/
    ├── StatusTag/
    │   └── index.vue
    └── OrderTable/
        ├── index.vue
        ├── index.test.ts
        ├── columns.ts
        ├── types.ts
        ├── useOrderTable.ts
        └── components/
            └── ColumnSettings/
                ├── index.vue
                └── types.ts
```

页面、简单组件、复杂组件和更深子组件都采用同一个 `目录/index.vue` 入口。

```ts
// 构建工具支持目录解析时，导入会落到 OrderTable/index.vue。
import OrderTable from './components/OrderTable'

// 目录解析不支持 .vue 时，显式指向同一个唯一入口。
import ExplicitOrderTable from './components/OrderTable/index.vue'
```

## 递归拆分

从 `index.*` 中提取子组件时，使用职责名创建完整目录：

```text
OrderAddDialog/
├── index.vue
├── model.ts
├── rules.ts
└── components/
    ├── ProductSelector/
    │   ├── index.vue
    │   ├── model.ts
    │   └── components/
    │       └── SkuPicker/
    │           └── index.vue
    └── AddressSelector/
        └── index.vue
```

采用以下拆分信号：

- 区域具有可命名的独立 UI 职责。
- 区域拥有自己的 props、事件或状态生命周期。
- 区域可以独立测试或替换。
- 区域拥有自己的 API、缓存或表单规则。

目录深度没有固定上限；每一级都必须表达直接所有权。若子组件已形成独立 feature 或另一领域能力，使用组件提升代替错误的父子归属。

## 组件提升阶梯

按证据逐级移动组件的完整目录：

```text
组件私有 → 页面私有 → feature 共享 → 领域共享 → 全局通用
```

采用以下证据：

1. **真实复用**：第二个消费者已存在，并依赖同一语义。
2. **独立领域身份**：即使当前只有一个消费者，也拥有稳定领域词汇、模型、API 和生命周期。
3. **独立变化节奏**：它与父组件因不同需求而变化，且可以定义窄接口。
4. **通用视觉语义**：它不依赖业务概念，适合进入设计系统。

提升时移动 `<ComponentName>/` 整个目录，包括 `index.*`、卫星文件和递归 `components/`。若消费者只共享部分行为，只提取那部分能力。

消费者位置与领域身份冲突时，领域身份优先。例如订单弹窗内部孵化的 `ProductSelector/` 一旦围绕产品搜索、SKU、库存建立独立模型与 API，就把完整目录提升到 product 领域；订单 feature 通过它的 `index.*` 消费。

## 边界诊断

| 现象 | 调整方向 |
| --- | --- |
| `components/StatusTag.tsx` 或 `components/StatusTag.vue` | 改为 `components/StatusTag/index.tsx` 或 `index.vue` |
| `OrderTable/index.ts` 再转出 `OrderTable.tsx` | 把渲染实现合并到 `OrderTable/index.tsx` |
| 子组件与父组件平铺在同一 `components/` | 把子组件目录移入直接父组件的 `components/` |
| 页面目录有 `OrderListPage.tsx` | 把页面入口改为 `OrderList/index.tsx` |
| JavaScript 页面旁新增 `model.ts`、`api.ts` 或 hook `.ts` | 按最近所有者的原生语言改用 `.js` |
| TypeScript 页面旁新增 `model.js`、`api.js` 或 hook `.js` | 按最近所有者的原生语言改用 `.ts` |
| 多处深层导入组件卫星文件 | 通过组件目录或 `index.*` 暴露最小公共表面 |
| 共享组件包含大量 feature 条件分支 | 按业务所有者拆回各自的完整组件目录 |
| 父子组件形成循环导入 | 将共同契约提升到最近共同所有者 |
| 子组件拥有另一领域的完整业务流程和 API | 把完整组件目录提升到对应领域 |

最终结构应让任意组件都能沿同一模式定位：`组件名/index.*`；其私有组件继续沿 `components/子组件名/index.*` 递归查找。
