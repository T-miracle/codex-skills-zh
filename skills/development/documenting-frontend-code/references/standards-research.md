# 前端代码注释规范调研

调研日期：2026-09-04。本文只采用 JSDoc、TypeScript、TSDoc 与 Google 工程规范等一手来源，供 `documenting-frontend-code` Skill 制定规则时参考。

## 结论摘要

### 1. 区分 API 文档注释与实现注释

- 用 `/** ... */` 文档注释描述 class、函数、方法、字段等符号的用途、用法和可观察行为；用 `// ...` 描述仅与内部实现有关的原因、约束或步骤。Google TypeScript Style Guide 明确区分这两类注释，并指出文档注释可被编辑器和文档工具理解。[Google TypeScript Style Guide：Comments and documentation](https://google.github.io/styleguide/tsguide.html#comments-documentation)
- 流程注释应优先解释“为什么存在”“必须维持什么约束”，不应逐行复述“代码正在做什么”。如果实现难以读懂，应先简化代码；正则表达式、复杂算法等确有必要时再补充实现说明。[Google Engineering Practices：Comments](https://google.github.io/eng-practices/review/reviewer/looking-for.html#comments)
- 文档注释与实现注释承担不同职责：class、module、function 的文档应说明目的、如何使用以及使用时的行为；内部注释则保存代码本身无法表达的决策背景。[Google Engineering Practices：Comments](https://google.github.io/eng-practices/review/reviewer/looking-for.html#comments)

### 2. JavaScript 函数使用带类型的 JSDoc

- `@param` 的标准信息是参数名、类型和说明；可选参数、默认值、对象属性及剩余参数都有标准写法。[JSDoc：`@param`](https://jsdoc.app/tags-param)
- `@returns` 用于说明函数返回值，可同时给出返回类型和语义说明；异步函数应写出 `Promise<T>` 一类的实际返回结构。[JSDoc：`@returns`](https://jsdoc.app/tags-returns)
- `@type` 可为变量或字段提供类型表达式；复杂对象可使用 `@typedef` 与 `@property` 描述字段类型、名称和解释。[JSDoc：`@type`](https://jsdoc.app/tags-type)、[JSDoc：`@property`](https://jsdoc.app/tags-property)、[JSDoc：`@typedef`](https://jsdoc.app/tags-typedef)
- TypeScript 编译器在 JavaScript 文件中支持 `@type`、`@param`、`@returns`、`@typedef`、`@callback` 等 JSDoc 类型信息，也支持在 class 字段上显式标注类型。[TypeScript Handbook：JSDoc Reference](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html)

推荐的 JavaScript 形式：

```js
/**
 * 根据表单值创建提交参数。
 *
 * @param {UserForm} form - 已通过页面校验的用户表单。
 * @returns {UserPayload} 可直接交给保存接口的参数对象。
 */
function createUserPayload(form) {
  return { id: form.id, name: form.name }
}
```

### 3. TypeScript 使用 TSDoc 描述语义，不复制签名类型

- TSDoc 的 `@param` 形式为“参数名 + 连字符 + 说明”，`@returns` 描述返回值；类型已经由 TypeScript 函数签名表达，因此示例不会在标签中重复 `{Type}`。[TSDoc：`@param`](https://tsdoc.org/pages/tags/param/)、[TSDoc：`@returns`](https://tsdoc.org/pages/tags/returns/)
- TypeScript 官方说明：JSDoc 的类型注解主要为 JavaScript 文件提供类型信息，而 TypeScript 文件只使用其中的文档类信息；Google TypeScript Style Guide 也明确要求不要在 TypeScript 的 `@param`、`@return` 等标签中重复声明签名已有的类型。因此，`.ts`/`.tsx` 应以真实类型声明为唯一类型来源，注释负责补充业务语义、单位、范围、前置条件和副作用，避免类型改动后出现两份相互冲突的定义。[TypeScript Handbook：JSDoc Reference](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html)、[Google TypeScript Style Guide：JSDoc type annotations](https://google.github.io/styleguide/tsguide.html)
- 较长的 API 说明可将首段作为简短摘要，再用 `@remarks` 放置细节；这与 TSDoc 的摘要/详情分层一致。[TSDoc：`@remarks`](https://tsdoc.org/pages/tags/remarks/)

推荐的 TypeScript 形式：

```ts
/**
 * 根据表单值创建提交参数。
 *
 * @param form - 已通过页面校验的用户表单。
 * @returns 可直接交给保存接口的参数对象。
 */
function createUserPayload(form: UserForm): UserPayload {
  return { id: form.id, name: form.name }
}
```

### 4. class 与实体字段应记录用途和字段语义

- class 注释应让读者知道何时、如何使用该 class，以及正确使用所需的额外注意事项。[Google TypeScript Style Guide：Class comments](https://google.github.io/styleguide/tsguide.html)
- JSDoc 可用 `@class`/`@classdesc` 描述构造函数与 class，也可用 `@property {Type} name - description` 汇总简单字段。[JSDoc：`@classdesc`](https://jsdoc.app/tags-classdesc)、[JSDoc：`@property`](https://jsdoc.app/tags-property)
- 对 JavaScript 实体，字段类型可由字段上的 `@type` 或实体的 `@typedef`/`@property` 表达；对 TypeScript 实体，字段类型应保留在声明中，字段注释补充含义、单位、允许范围、默认策略、服务端约束等信息。后一条是结合 TypeScript 类型来源与 JSDoc 字段能力得出的实施结论。[TypeScript Handbook：JSDoc Reference](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html)、[JSDoc：`@property`](https://jsdoc.app/tags-property)

### 5. 注释必须随代码维护，但避免无关改写

- 代码审查时应同时检查变更前已经存在的注释，例如已完成的 TODO 或与新行为冲突的警告；行为或用户交互发生变化时，关联文档也应同步更新或删除。[Google Engineering Practices：Comments / Documentation](https://google.github.io/eng-practices/review/reviewer/looking-for.html#comments)
- Google TypeScript Style Guide 不要求仅为采用新风格而重写全部旧代码，并建议避免把与当前变更无关的大量样式调整混入同一改动。[Google TypeScript Style Guide：Consistency](https://google.github.io/styleguide/tsguide.html)
- 因此，修改函数签名、返回语义、字段含义、副作用、异常、边界条件或关键流程时，必须在同一变更中同步注释；仅做不影响契约的小型内部调整，且原注释仍完全准确时，可以保持不变。此条是对上述维护原则的直接实施化。

## 建议写入 Skill 的本地规则

以下规则有意比通用指南更严格，以满足本仓库“新生成函数和实体必须有注释”的要求，同时用“信息增量”避免无意义注释：

1. 新增的具名函数、方法、class 和实体模型必须有文档注释；函数注释覆盖全部参数与返回值，构造函数无需虚构返回值。
2. JavaScript 在 `@param`、`@returns`、`@type`/`@property` 中写类型；TypeScript 以签名类型为准，标签只写名称与有信息量的说明。
3. 实体 class 先说明整体用途和不变量；每个业务字段至少能从声明与注释组合中读出类型和含义，必要时再说明单位、范围、默认值、敏感性或接口映射。
4. 对无返回值函数也明确说明“不返回有意义值”；具体写成 `@returns {void}` 还是省略类型，应服从项目现有 JSDoc/TSDoc 工具约定。
5. 复杂流程用邻近的 `//` 注释解释阶段、原因、不变量和容易误改的边界；不逐行翻译代码，不保留被注释掉的旧实现。
6. 修改代码时先审查相邻注释。只要契约或语义变化就同步更新；微小且不影响原说明的修改不制造注释噪声。
7. 优先沿用仓库已有语言、标签、换行和 lint 规则；新增注释后运行项目已有 formatter、lint、typecheck 与相关测试。

## 一手来源索引

- [JSDoc 官方标签索引](https://jsdoc.app/)
- [TypeScript Handbook：JSDoc Reference](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html)
- [TSDoc 官方规范与标签参考](https://tsdoc.org/pages/spec/overview/)
- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- [Google Engineering Practices：What to look for in a code review](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
