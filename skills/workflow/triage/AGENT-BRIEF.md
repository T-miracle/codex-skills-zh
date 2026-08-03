# 编写代理简报（Agent Briefs）

代理简报是在 GitHub issue 或 PR 转入 `ready-for-agent` 状态时发布的一条结构化评论。它是 AFK agent 开展工作的权威规格说明。原始正文和讨论只是上下文——代理简报才是契约。

简报说明**代理应该做什么**，并覆盖两种入口：对于 issue，是从零构建变更；对于 PR，则是说明*现有差异*还需要完成什么——完成实现、补齐缺口、处理审查意见。两者遵循相同原则；下方 PR 示例展示了这种差别。

## 原则（Principles）

### 持久性胜于精确性

issue 可能会在 `ready-for-agent` 状态停留数天乃至数周，其间代码库会发生变化。编写简报时，应确保即使文件被重命名、移动或重构，它仍然有用。

- **应该（Do）**描述接口、类型和行为契约
- **应该（Do）**指出代理应查找或修改的具体类型、函数签名或配置结构
- **不要（Don't）**引用文件路径——它们会过时
- **不要（Don't）**引用行号
- **不要（Don't）**假设当前实现结构会保持不变

### 描述行为，而非过程

描述系统应该**做什么**，而不是**如何**实现。代理会重新探索代码库，并自行作出实现决策。

- **好（Good）：**“`SkillConfig` 类型应接受一个可选 `schedule` 字段，其类型为 `CronExpression`”
- **坏（Bad）：**“打开 src/types/skill.ts，在第 42 行添加 schedule 字段”
- **好（Good）：**“当用户运行不带参数的 `/triage` 时，应看到需要关注的问题摘要”
- **坏（Bad）：**“在主处理函数中添加 switch 语句”

### 完整的验收标准

代理需要知道何时才算完成。每份代理简报都必须包含具体、可测试的验收标准。每项标准都应能独立验证。

- **好（Good）：**“运行 `gh issue list --label needs-triage` 会返回已完成初步分类的问题”
- **坏（Bad）：**“分流应该正确工作”

### 明确的范围边界

明确说明哪些内容不在范围内。这能防止代理过度完善，或对相邻功能擅作假设。

## 模板（Template）

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** one-line description of what needs to happen

**Current behavior:**
Describe what happens now. For bugs, this is the broken behavior.
For enhancements, this is the status quo the feature builds on.

**Desired behavior:**
Describe what should happen after the agent's work is complete.
Be specific about edge cases and error conditions.

**Key interfaces:**
- `TypeName` — what needs to change and why
- `functionName()` return type — what it currently returns vs what it should return
- Config shape — any new configuration options needed

**Acceptance criteria:**
- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3

**Out of scope:**
- Thing that should NOT be changed or addressed in this issue
- Adjacent feature that might seem related but is separate
```

## 示例（Examples）

### 优秀代理简报（缺陷）

```markdown
## Agent Brief

**Category:** bug
**Summary:** Skill description truncation drops mid-word, producing broken output

**Current behavior:**
When a skill description exceeds 1024 characters, it is truncated at exactly
1024 characters regardless of word boundaries. This produces descriptions
that end mid-word (e.g. "Use when the user wants to confi").

**Desired behavior:**
Truncation should break at the last word boundary before 1024 characters
and append "..." to indicate truncation.

**Key interfaces:**
- The `SkillMetadata` type's `description` field — no type change needed,
  but the validation/processing logic that populates it needs to respect
  word boundaries
- Any function that reads SKILL.md frontmatter and extracts the description

**Acceptance criteria:**
- [ ] Descriptions under 1024 chars are unchanged
- [ ] Descriptions over 1024 chars are truncated at the last word boundary
      before 1024 chars
- [ ] Truncated descriptions end with "..."
- [ ] The total length including "..." does not exceed 1024 chars

**Out of scope:**
- Changing the 1024 char limit itself
- Multi-line description support
```

### 优秀代理简报（增强）

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** Add `.out-of-scope/` directory support for tracking rejected feature requests

**Current behavior:**
When a feature request is rejected, the issue is closed with a `wontfix` label
and a comment. There is no persistent record of the decision or reasoning.
Future similar requests require the maintainer to recall or search for the
prior discussion.

**Desired behavior:**
Rejected feature requests should be documented in `.out-of-scope/<concept>.md`
files that capture the decision, reasoning, and links to all issues that
requested the feature. When triaging new issues, these files should be
checked for matches.

**Key interfaces:**
- Markdown file format in `.out-of-scope/` — each file should have a
  `# Concept Name` heading, a `**Decision:**` line, a `**Reason:**` line,
  and a `**Prior requests:**` list with issue links
- The triage workflow should read all `.out-of-scope/*.md` files early
  and match incoming issues against them by concept similarity

**Acceptance criteria:**
- [ ] Closing a feature as wontfix creates/updates a file in `.out-of-scope/`
- [ ] The file includes the decision, reasoning, and link to the closed issue
- [ ] If a matching `.out-of-scope/` file already exists, the new issue is
      appended to its "Prior requests" list rather than creating a duplicate
- [ ] During triage, existing `.out-of-scope/` files are checked and surfaced
      when a new issue matches a prior rejection

**Out of scope:**
- Automated matching (human confirms the match)
- Reopening previously rejected features
- Bug reports (only enhancement rejections go to `.out-of-scope/`)
```

### 优秀代理简报（PR）

对于 PR，“Current behavior”描述差异的当前状态，而简报要求代理完成或修正现有工作，不是从头构建。

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** Finish the contributor's `--json` output flag for `triage list`

**Current behavior:**
The PR adds a `--json` flag that serializes the issue list to JSON. The happy
path works and the diff matches the project's command structure. Two gaps
remain: errors are still printed as human text (not JSON), and the new flag has
no test coverage.

**Desired behavior:**
With `--json`, all output — including errors — is well-formed JSON on stdout,
and the command's exit codes are unchanged. The existing human-readable output
is untouched when the flag is absent.

**Key interfaces:**
- The command's error path should emit `{ "error": string }` under `--json`
  instead of the plain-text error
- Reuse the existing serializer the PR already added; don't introduce a second

**Acceptance criteria:**
- [ ] `triage list --json` emits valid JSON for both success and error cases
- [ ] Exit codes match the non-JSON command
- [ ] A test covers the `--json` success output and one error case
- [ ] Default (non-JSON) output is byte-for-byte unchanged

**Out of scope:**
- Adding `--json` to any other command
- Changing the JSON shape of the success payload the PR already defined
```

### 糟糕的代理简报

```markdown
## Agent Brief

**Summary:** Fix the triage bug

**What to do:**
The triage thing is broken. Look at the main file and fix it.
The function around line 150 has the issue.

**Files to change:**
- src/triage/handler.ts (line 150)
- src/types.ts (line 42)
```

它的问题在于：
- 没有类别
- 描述含糊（“分流的东西坏了”）
- 引用了会过时的文件路径和行号
- 没有验收标准
- 没有范围边界
- 没有描述当前行为与期望行为
