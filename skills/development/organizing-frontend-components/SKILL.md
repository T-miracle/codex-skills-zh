---
name: organizing-frontend-components
description: "以统一 index 入口和递归 components 树组织、开发或重构 React、Vue 等前端页面与组件；当创建业务页面、拆分子组件、放置私有 types/API/hooks/composables/tests、提升共享组件，或规范 feature/page/component 目录时使用。"
---

# 统一目录入口组织前端组件

把页面与组件目录视为**所有权树（ownership tree）**。每个页面和组件都独占同名目录，渲染入口固定为 `index.<框架组件扩展名>`；它拥有的子组件进入 `components/<子组件名>/`，并递归采用同一形态。

```text
<ComponentName>/
├── index.<tsx|jsx|vue|svelte|...>
├── model.ts
├── hooks.ts / use<ComponentName>.ts
├── api.ts
├── types.ts
├── <styles|rules|tests|mocks|...>
└── components/
    └── <ChildComponentName>/
        ├── index.<tsx|jsx|vue|svelte|...>
        ├── <child-owned-model-and-logic>
        └── components/
            └── ...
```

`model`、hooks/composables、`api`、类型、规则、样式、测试和 mock 等组件私有模型与逻辑，都与该组件的 `index.*` 同级共置。叶组件在 `index.*` 及这些卫星文件处终止；没有子组件时省略空的 `components/`。

## 1. 读取现状

读取仓库指令、目标页面、直接依赖、相邻页面和构建解析约定。确定框架组件扩展名、页面根目录、组件命名、目录导入能力、状态管理和测试工具。

完成标准：能够指出本次应使用的入口文件名、目标所有者和现有消费者。

## 2. 应用统一目录形态

让作用域内的每个页面和 UI 组件遵守以下不变量：

- 页面：`<PageName>/index.<组件扩展名>`。
- 组件：`<ComponentName>/index.<组件扩展名>`。
- 私有子组件：`<Owner>/components/<ChildName>/index.<组件扩展名>`。
- 更深子组件：继续进入当前组件的 `components/`，逐层递归。
- `model`、hooks/composables、`api`、样式、类型、规则、测试、story、mock 和常量：放在所属组件的 `index.*` 旁边。

把组件渲染实现直接写入 `index.tsx`、`index.jsx`、`index.vue` 等入口。将 `index.ts` 保留给 feature 等非渲染聚合层。完整范式见 [结构参考](references/structure.md#统一目录不变量)。

完成标准：作用域内每个页面和组件都能从其同名目录定位到唯一的 `index.<组件扩展名>`；每个子组件都位于直接所有者的 `components/` 下。

## 3. 确定最近所有者

为组件及其卫星文件寻找最窄所有者：

- 只有一个组件使用 → 归入该组件的 `components/`。
- 同一页面的多个组件使用 → 归入页面目录。
- 同一 feature 的多个页面使用 → 归入 feature 的 `components/`。
- 跨 feature 使用且语义稳定 → 归入领域共享层或通用 UI 层。

所有层级中的组件仍使用 `<ComponentName>/index.<组件扩展名>`。全局技术目录只承载确实跨业务共享的基础设施；放置矩阵见 [结构参考](references/structure.md#文件放置矩阵)。

完成标准：每个目录化组件及其卫星文件都有唯一最近所有者；提升到更高层的组件有真实消费者或独立领域身份作为证据。

## 4. 递归拆分职责

从当前组件的 `index.*` 中识别具有独立 UI 职责、状态生命周期或测试边界的区域，把它提取为 `components/<ChildName>/index.*`。继续对复杂子组件应用同一过程，不设置机械的最大深度。

让目录深度表达真实运行时所有权。子组件一旦形成独立 feature 或另一领域能力，按第 6 步提升，而不是继续增加错误的父子关系。

完成标准：组件树与目录树逐层对应；每一级 `components/` 只包含其直接所有的子组件目录。

## 5. 建立唯一入口

让父级通过子组件目录导入，使模块解析落到 `index.*`；跨所有权边界只使用该入口。由 `index.*` 暴露父级需要的组件、props、事件和稳定类型，其余文件保持目录私有。

仓库不支持目录解析时，显式导入 `.../<ComponentName>/index.<扩展名>`，仍保持入口形态不变。

完成标准：每个组件只有一个渲染入口；跨边界导入指向组件目录或其 `index.*`，并且没有导入组件内部卫星文件。

## 6. 逐级提升并验证

出现第二个真实消费者时，把组件完整提升到最近共同所有者。组件围绕另一领域实体形成模型、API 与生命周期时，以该领域为所有者；当前消费者只决定公开范围。提升后仍保持 `<ComponentName>/index.* + components/` 的递归形态，并同时迁移测试、样式、类型、状态逻辑和 mock。

完成实现后运行与变更相称的格式化、类型检查、测试和构建检查，并逐项确认：

- 每个页面和组件都有同名目录与唯一 `index.<组件扩展名>`。
- 每个私有子组件都位于直接所有者的 `components/<ChildName>/index.*`。
- 每个卫星文件都与其所有者共置。
- 每个跨边界导入都经过组件入口，依赖图保持无环。
- 每个提升后的组件只保留一个实现。
- 所有受影响检查均通过；未运行的检查及原因已明确报告。

这些条件全部满足后，开发或重构才完成。
