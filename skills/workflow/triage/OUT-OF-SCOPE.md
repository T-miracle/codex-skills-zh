# 范围外知识库（Out-of-Scope Knowledge Base）

仓库中的 `.out-of-scope/` 目录用于持久记录被拒绝的功能请求。它有两个用途：

1. **组织记忆（Institutional memory）**——记录功能为何被拒绝，避免问题关闭后推理依据丢失
2. **去重（Deduplication）**——当新问题与之前的拒绝项相符时，技能可以展示先前决策，而不必再次争论

## 目录结构

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

每个**概念（concept）**使用一个文件，而不是每个 issue 一个文件。请求相同事项的多个 issue 归入同一文件。

## 文件格式

文件应采用轻松、易读的风格——更像一篇简短的设计文档，而不是数据库记录。使用段落、代码样例和示例，使推理对首次接触它的人也清晰有用。

```markdown
# Dark Mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette defined in
`ThemeConfig`. Supporting multiple themes would require:

- A theme context provider wrapping the entire component tree
- Per-component theme-aware style resolution
- A persistence layer for user theme preferences

This is a significant architectural change that doesn't align with the
project's focus on content authoring. Theming is a concern for downstream
consumers who embed or redistribute the output.

```ts
// The current ThemeConfig interface is not designed for runtime switching:
interface ThemeConfig {
  colors: ColorPalette; // single palette, resolved at build time
  fonts: FontStack;
}
```

## Prior requests

- #42 — "Add dark mode support"
- #87 — "Night theme for accessibility"
- #134 — "Dark theme option"
```

### 文件命名

使用简短且描述明确的 kebab-case 名称表示概念：`dark-mode.md`、`plugin-system.md`、`graphql-api.md`。文件名应足够易懂，让浏览目录的人无需打开文件也能知道被拒绝的内容。

### 编写理由

理由应当充分——不能只说“我们不想做”，还要说明原因。好的理由会涉及：

- 项目范围或理念（“本项目专注于 X；主题化是下游关注点”）
- 技术约束（“支持此功能需要 Y，而这与我们的 Z 架构冲突”）
- 战略决策（“我们选择 A 而不是 B，因为……”）

理由应经得起时间考验。避免引用临时情况（“我们现在太忙了”）——那不是真正的拒绝，而是推迟。

## 何时检查 `.out-of-scope/`

进行分流（步骤 1：收集上下文）时，读取 `.out-of-scope/` 中的所有文件。评估新 issue 时：

- 检查请求是否匹配已有的范围外概念
- 按概念相似性而非关键字匹配——“夜间主题”应匹配 `dark-mode.md`
- 如果匹配，向维护者说明：“这与 `.out-of-scope/dark-mode.md` 类似——我们之前因为[理由]拒绝了它。你现在仍持相同看法吗？”

维护者可能：

- **确认（Confirm）**——把新 issue 添加到现有文件的“Prior requests”列表，然后关闭
- **重新考虑（Reconsider）**——删除或更新范围外文件，并让 issue 进入正常分流流程
- **认为不同（Disagree）**——两个问题相关但并不相同，继续正常分流

## 何时写入 `.out-of-scope/`

只在某项**增强功能（enhancement）**（而不是缺陷）被以 `wontfix` 状态*拒绝*时写入。此规则对增强型 PR 与 issue 完全相同——被拒绝的 PR 要记录在这里，避免相同请求以后以全新代码的形式再次出现。

如果某项内容因**已经实现**而以 `wontfix` 关闭，**不要**写入这里。那是已构建的功能，不是被拒绝的功能；记录它会用虚假拒绝项污染去重检查。此时，应在关闭评论中指出该功能当前所在位置。

流程如下：

1. 维护者决定某项功能请求不在范围内
2. 检查是否已存在匹配的 `.out-of-scope/` 文件
3. 如果存在：把新 issue 追加到“Prior requests”列表
4. 如果不存在：使用概念名称、决策、理由和第一条既往请求创建新文件
5. 在 issue 中发表评论，解释决策并提及 `.out-of-scope/` 文件
6. 使用 `wontfix` 标签关闭 issue

## 更新或移除范围外文件

如果维护者改变了对先前被拒概念的看法：

- 删除 `.out-of-scope/` 文件
- 技能无需重新打开旧 issue——它们是历史记录
- 触发重新考虑的新 issue 继续进入正常分流流程
