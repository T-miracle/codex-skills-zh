# 前端注释规则

## 通用原则

- 注释说明职责、业务语义、约束、单位、副作用与非显然原因，不复述函数名或代码动作。
- 注释必须紧邻目标声明或流程块；公开 API 与共享模型比局部实现需要更完整的契约说明。
- 使用项目现有语言和术语；同一概念沿用同一名称。
- 不猜测接口、字段、枚举、时间单位或可空性。事实不足时先查类型、调用点、测试与契约。
- 不保留注释掉的旧代码。TODO 必须符合仓库格式，并包含可解除的条件、关联问题或负责人信息。

## JavaScript 函数

JavaScript 没有静态类型声明，使用 JSDoc 同时记录类型与语义。`@param` 与形参名称严格一致；可选值、默认值和 rest 参数使用项目已经支持的 JSDoc 语法。

```js
/**
 * 将编辑表单映射为已确认的保存请求。
 *
 * @param {UserForm} form - 已完成前端校验的用户表单。
 * @param {string} operatorId - 发起保存操作的用户标识。
 * @returns {SaveUserRequest} 可提交给用户保存接口的请求对象。
 */
export function toSaveUserRequest(form, operatorId) {
  return {
    id: form.id,
    name: form.name,
    operatorId
  }
}

/**
 * 重置当前编辑状态。
 *
 * @returns {void} 无返回值。
 */
function resetEditor() {
  state.currentId = void 0
}
```

异步函数的返回类型写成 `Promise<T>`，并说明 Promise resolve 后的业务值；只有函数确实抛出且调用方需要知道时才写 `@throws`。

## TypeScript 函数

TypeScript 签名是类型的单一事实来源。TSDoc 的 `@param` 和 `@returns` 记录参数与返回值语义，不在标签中重复 `{Type}`。

```ts
/**
 * 将用户表单映射为已确认的保存请求。
 *
 * @param form - 已完成前端校验的用户表单。
 * @param operatorId - 发起保存操作的用户标识。
 * @returns 可提交给用户保存接口的请求对象。
 */
export function toSaveUserRequest(
  form: UserForm,
  operatorId: string
): SaveUserRequest {
  return {
    id: form.id,
    name: form.name,
    operatorId
  }
}
```

返回 `void` 的函数仍写 `@returns 无返回值。`；构造函数不写 `@returns`。重载函数按项目工具链要求在公开重载签名或实现签名上维护一份不会冲突的说明。

## JavaScript 实体 class

class 注释说明整体职责，每个字段用紧邻声明的 `@type` 记录类型，并解释含义。可选字段使用项目约定的联合类型；本仓库相关 Vue 规范采用 `void 0` 作为内部“未提供”值时，类型中仍表达 `undefined`，因为 `void 0` 是值表达式而不是类型名。

```js
/**
 * 用户编辑表单模型，负责提供稳定默认值。
 */
export class UserForm {
  /** @type {string | undefined} 用户唯一标识；新增态为未提供。 */
  id = void 0

  /** @type {string | undefined} 用户姓名；提交前由表单校验保证存在。 */
  name = void 0

  /** @type {string[]} 已选择的角色标识集合。 */
  roleIds = []
}
```

如果目标构建链不支持 class fields，就在构造函数内初始化，但仍让每个 `@type` 注释紧邻对应赋值。

## TypeScript 实体 class

字段声明是权威类型来源，不在 TypeScript 注释中使用 JSDoc `{Type}` 改写编译器类型。为满足本地实体注释规则，字段文档同时写出与声明一致的可读类型备注、业务语义、缺省值与重要限制；类型声明变化时必须同步该备注。

```ts
/** 用户编辑表单模型，负责提供稳定默认值。 */
export class UserForm {
  /** 用户唯一标识；类型为 `string | undefined`，新增态为未提供。 */
  id: string | undefined = void 0

  /** 用户姓名；类型为 `string | undefined`，提交前由表单校验保证存在。 */
  name: string | undefined = void 0

  /** 已选择的角色标识集合；类型为 `string[]`。 */
  roleIds: string[] = []
}
```

当类型名已经足够明确时，仍需保留业务解释；字段的单位、时区、枚举来源、脱敏要求或由谁回填等备注按需补充。

## Vue 与 React

- Vue Options API 的 `methods`、computed getter 和 watcher handler 按函数规则注释；生命周期钩子如只做显然的一行调用，可用简短职责说明，存在流程时写完整文档块。
- Vue Composition API composable、事件处理器、映射函数和校验函数按函数规则注释。模板内部不写长解释，把复杂逻辑提取到带注释的 computed 或 method。
- React 组件函数说明组件职责；props 的字段含义放在 props type/interface 或 PropTypes 附近。自定义 hook 必须说明参数、返回值以及副作用或订阅清理责任。
- 测试中的 helper、factory 和自定义 matcher 按函数规则注释；测试用例本身以清楚的用例名称表达行为，通常不额外复述步骤。

## 复杂流程注释

```ts
// 先冻结本次请求序号；较早请求后返回时不得覆盖用户刚完成的新筛选结果。
const requestId = ++latestRequestId
const result = await loadUsers(filters)

if (requestId !== latestRequestId) return
state.users = result.items
```

好的流程注释解释竞态不变量。以下注释只是翻译代码，应删除：

```ts
// 请求用户列表
const result = await loadUsers(filters)
```

## 修改时的同步矩阵

| 代码变化 | 注释动作 |
| --- | --- |
| 新增参数、删除参数或改名 | 同步全部 `@param`，保证名称与顺序正确 |
| 返回类型、空值或 Promise 语义变化 | 更新 `@returns` 与相关备注 |
| 字段类型、单位、默认值或来源变化 | 更新字段注释；实体职责变化时同步 class 注释 |
| 新增副作用、异常或前置条件 | 增加相应说明 |
| 流程顺序或不变量变化 | 重写块前流程注释 |
| 仅格式化或不改变契约的内部重构 | 原注释仍完全准确时保持不变 |
| 注释已无法证明或与代码冲突 | 查证后重写；无法查证时不要猜测 |
