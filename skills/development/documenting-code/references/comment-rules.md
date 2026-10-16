# 注释写法与前端细则

## 通用写法与格式边界

覆盖要求以 [主规范](../SKILL.md) 的覆盖表为准。以下写法适用于所有语言，后续各节保留 JavaScript、TypeScript、Vue 与 React 的专用规则。

- 沿用项目已有注释语言、术语、文档格式及校验规则；没有约定时使用目标语言的惯用形式，不把 JSDoc 标签套到所有语言。
- 函数用途、参数、泛型和结果集中写在所属声明的文档位置；变量、常量、类型与字段的说明优先紧邻定义上方。公开 API 与共享模型按实际约束补充细节。
- 解构参数沿用工具支持的属性文档写法；字段已有模型文档时可引用。泛型参数解释其角色和语义限制，不重复声明已经表达的约束。
- 采用简短职责说明，必要时补单位、范围、缺省策略、前置条件、副作用或异常。不要逐字展开类型或复述名称；项目强制要求的标签沿用其格式。
- 说明性注释与编译、lint、类型检查指令分开处理：只补必要原因，保留指令、许可证、生成标记和文档工具要求的关联位置。
- 对不允许注释的文件格式或不应手改的生成文件，报告限制；不改变文件格式、生成结果或配置来容纳注释。
- docstring 只在语言认可的文档位置维护，不改动业务字符串或为插入文档调整执行语句。模板和样式使用合法注释位置，避免改变解析或渲染。
- TODO、FIXME 与临时绕过说明原因和解除条件；关联问题、负责人等沿用项目格式。已失效的条目与被注释掉的旧实现应清理。

例如，已有类型声明的 Python 函数用项目采用的 docstring 说明语义，无需复制参数类型：

```python
def partition_ids(ids: list[str], batch_size: int) -> list[list[str]]:
    """按批次拆分标识列表，保持原顺序。

    Args:
        ids: 待处理的标识列表。
        batch_size: 每批允许的最大数量，必须大于零。

    Returns:
        拆分后的批次；空输入返回空列表。
    """
    return [ids[offset:offset + batch_size] for offset in range(0, len(ids), batch_size)]
```

## JavaScript 函数

JavaScript 需要文档承载类型时，使用 JSDoc 同时记录已确认的类型与语义。`@param` 与形参名称严格一致；可选值、默认值和 rest 参数使用项目已经支持的 JSDoc 语法。

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

/** 清除当前编辑项，恢复为未选择状态。 */
function resetEditor() {
  state.currentId = void 0
}
```

有实际结果的异步函数用 `Promise<T>` 等真实返回结构承载类型，说明 Promise resolve 后的业务值；只有函数确实抛出且调用方需要知道时才写 `@throws`。无实际返回结果时，省略单纯的“无返回值”；工具要求保留标签时按配置写最短必要形式。

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

返回 `void` 的函数省略单纯的 `@returns 无返回值。`；构造函数不写 `@returns`。返回的空值或布尔值有业务含义时，仍说明其含义和触发条件。异步完成时机影响调用方时说明完成条件。重载函数按项目工具链要求在公开重载签名或实现签名上维护一份不会冲突的说明。

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

字段已经在构造函数内初始化时，让每个 `@type` 注释紧邻既有赋值。保留原有初始化位置和语法。

## TypeScript 实体 class

字段声明是权威类型来源，不在 TypeScript 注释中使用 JSDoc `{Type}` 或“类型为……”重复类型。字段注释说明业务含义，并按需补充缺省策略、单位和重要限制。

```ts
/** 用户编辑表单模型，负责提供稳定默认值。 */
export class UserForm {
  /** 用户唯一标识；新增态为未提供。 */
  id: string | undefined = void 0

  /** 用户姓名；提交前由表单校验保证存在。 */
  name: string | undefined = void 0

  /** 已选择的角色标识集合。 */
  roleIds: string[] = []
}
```

当类型名已经足够明确时，仍需保留业务解释；字段的单位、时区、枚举来源、脱敏要求或由谁回填等备注按需补充。

## Vue 与 React

- Vue Options API 的 `methods`、computed getter 和 watcher handler 按函数规则注释；生命周期钩子如只做显然的一行调用，可用简短职责说明，存在流程时写完整文档块。
- Vue Composition API composable、事件处理器、映射函数和校验函数按函数规则注释。模板在最近的合法注释位置补必要短说明；已有 computed 或 method 的逻辑在其定义处说明，不为补注释提取或移动逻辑。
- React 组件函数说明组件职责；props 的字段含义放在 props type/interface 或 PropTypes 附近。自定义 hook 必须说明参数、返回值以及副作用或订阅清理责任。
- props、emits、响应式状态和 store 使用框架允许的注释位置；模型与事件契约字段按主规范覆盖，命名清楚的局部状态不逐个补注释。watch/effect 有时序、重复触发或清理约束时说明原因。
- 测试中的 helper、factory 和自定义 matcher 按函数规则注释；测试用例本身以清楚的用例名称表达行为，通常不额外复述步骤。

## 复杂流程注释

```ts
// 1. 请求前固定本次序号，用于识别等待期间发起的更新请求。
const requestId = ++latestRequestId
const result = await loadUsers(filters)

// 2. 只提交最新请求的结果，防止旧响应覆盖用户后续筛选。
if (requestId !== latestRequestId) return
state.users = result.items
```

这里的编号对应请求标识与提交结果两个有顺序依赖的阶段，并解释竞态不变量。单个分支或约束无需强行编号；复杂匿名回调在现有位置说明，保持代码结构。以下注释只是翻译代码，应删除：

```ts
// 请求用户列表
const result = await loadUsers(filters)
```

## 修改时的同步矩阵

| 代码变化 | 注释动作 |
| --- | --- |
| 调用方新增参数、删除参数或改名 | 同步参数文档，保证名称与顺序正确 |
| 返回值、空值、生成器或 Promise 语义变化 | 更新结果说明与相关备注 |
| 字段、变量的单位、默认值、来源或类型语义变化 | 同步有变化的语义说明；文档承载类型时同步类型，不复制已有声明 |
| 新增类型、枚举成员或共享变量 | 按主规范补充定义处说明 |
| 新增副作用、异常或前置条件 | 增加相应说明 |
| 流程顺序或不变量变化 | 重写块前流程注释 |
| 仅格式化或不改变契约的内部重构 | 原注释仍完全准确时保持不变 |
| 注释已无法证明或与代码冲突 | 查证后重写；无法查证时不要猜测 |

此表描述代码变化发生后应同步的注释；代码变化由调用方完成，本 Skill 始终只处理注释。
