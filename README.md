# codex-skills-zh

一个面向个人使用的中文 Codex Skills 精选仓库。这里可以同时收录自行编写的技能，
以及从不同仓库挑选、审阅并调整后适合自己工作方式的技能。每个技能独立记录来源，
整个集合不绑定任何单一上游。

## 按使用场景分类

仓库中的技能按主要使用场景存放在 `skills/<category>/<skill-name>/`。分类以用户
何时会寻找该 skill 为准；每个 skill 仅归入一个主场景。安装到 Codex 后仍会保持
扁平的 skill 名称入口，详见下方安装说明。

| 目录 | 中文含义 | Skills |
| --- | --- | --- |
| `development` | 开发实施：直接实现、试验或测试代码 | `implement`、`integrating-frontend-apis`、`organizing-frontend-components`、`prototype`、`tdd` |
| `planning` | 需求与方案：形成模型、规格、工单或设计决策 | `codebase-design`、`domain-modeling`、`grill-with-docs`、`to-spec`、`to-tickets` |
| `quality` | 质量保障：审查、诊断、架构评估与冲突解决 | `code-review`、`diagnosing-bugs`、`improve-codebase-architecture`、`resolving-merge-conflicts` |
| `knowledge` | 研究与学习：沉淀事实、知识和技能写作方法 | `research`、`teach`、`writing-great-skills` |
| `workflow` | 协作与流程：选择工作流、追问、交接、初始化与分流 | `ask-matt`、`grilling`、`grill-me`、`handoff`、`setup-matt-pocock-skills`、`triage`、`wayfinder` |

元数据和本地化正文采用“中文主描述 + 英文关键触发词／行为锚点”的写法；固定模板、
代码和工具协议则保留原始语义。

> English summary: A personal, Chinese-first Codex skills collection combining
> self-authored workflows with selectively adapted skills from multiple sources,
> while preserving per-skill provenance, licenses, behavior anchors, and
> cross-machine installation.

## 这种本地化会影响 Codex 吗？

影响很小，并且主要发生在“是否选中技能”这一步，而不是技能被选中后的推理能力：

- 中文主描述提高中文请求的语义匹配率。
- `debug`、`TDD`、`code review`、`ADR` 等英文触发词保留了英文和中英混合请求的匹配能力。
- `SKILL.md` 及其配套 Markdown 参考文档均以中文表达，同时保留 `seam`、
  `feedback loop`、`tracer bullet`、`HITL` 等关键英文行为锚点。
- 固定输出模板、代码、命令、路径、标签值和技能名保留原文，避免改变生成格式或工具行为。
- 代码块、内联代码、链接目标、标题层级、列表结构和 HTML 注释由翻译契约冻结，
  防止本地化意外改变命令、模板或工作流结构。
- 需要用户主动决定的工作流通过 `agents/openai.yaml` 禁止隐式调用，避免仅因描述相似而误触发。

技能描述是 Codex 的初始匹配线索，不会单独决定模型的整体“思考能力”。相比纯英文版，
本方案对纯英文请求可能有极小的匹配差异，但保留的英文关键词、行为锚点和测试用例
已将风险控制在较低水平。

## 为什么安装到 `.agents/skills`

当前 Codex 官方文档把个人技能目录定义为
[`$HOME/.agents/skills`](https://developers.openai.com/codex/skills)。
`.codex/skills` 仍可能包含 Codex 自带系统技能或旧安装数据，因此安装脚本不会改动
`.codex/skills/.system`。

仓库本身可以放在任意绝对路径。安装脚本从自己的 `$PSScriptRoot` 动态推导仓库位置，
再为每个技能创建 NTFS Junction。仓库内的场景目录不会出现在安装目标中：例如
`skills/development/tdd` 会安装为 `.agents/skills/tdd`，以保持 Codex 的稳定发现
入口。因此下面两台电脑都能使用同一套脚本：

- 笔记本：`C:\Project\Me\skills`
- 台式机：`C:\项目\Me\skills`

链接记录的是各自电脑上的实际路径，不要求不同电脑使用相同目录名，也支持中文路径。

## 安装

### Windows（推荐）

先克隆到任意目录，然后在仓库根目录运行：

```powershell
# 预览将要创建的链接，不修改文件。
.\scripts\install.ps1 -WhatIf

# 按清单为当前全部技能创建逐项 Junction。
.\scripts\install.ps1

# 同时验证仓库和实际安装链接。
.\scripts\verify.ps1 -CheckInstallation
```

安装脚本默认写入 `%USERPROFILE%\.agents\skills`。它不会覆盖普通目录；如果遇到指向
其他位置的链接，会报告冲突。确认后可用 `-Repair` 只修复错误链接：

```powershell
# 仅替换目标错误的 Junction 或 SymbolicLink。
.\scripts\install.ps1 -Repair
```

若希望测试自定义目录，可传入 `-DestinationRoot`。

### Linux / macOS

当前仓库以 Windows 自动化为主。可以手动为每个技能建立符号链接：

```bash
# 在仓库根目录执行；仓库路径可以包含空格或中文。
mkdir -p "$HOME/.agents/skills"
for skill_dir in "$PWD"/skills/*/*; do
  ln -sfn "$skill_dir" "$HOME/.agents/skills/$(basename "$skill_dir")"
done
```

## 验证、卸载与更新检查

```powershell
# 验证元数据、调用策略、翻译契约、链接、用例、脚本语法和敏感信息。
.\scripts\verify.ps1

# 检查所有已登记外部来源的 SKILL.md；只报告，不修改本地文件。
.\scripts\check-sources.ps1

# 预览卸载，再删除仅指向当前仓库的链接。
.\scripts\uninstall.ps1 -WhatIf
.\scripts\uninstall.ps1
```

卸载脚本只移除已验证目标的 Junction/SymbolicLink，不会删除仓库内容、普通目录或外来链接。

## 技能来源与调用策略

完整机器可读清单位于 [`config/skills.json`](config/skills.json)。其中：

- `sources` 登记自编来源和各个外部仓库；
- 每个技能的 `source_id`、`source_path` 和基线哈希记录其独立来源；
- `translation_contract` 表示是否需要源语言翻译保护；
- `allow_implicit_invocation` 控制 Codex 能否按请求语义隐式匹配；
- `required_english_terms` 保护中英混合触发词和行为锚点。

自编技能使用 `source_id: local`，不需要伪造外部仓库或翻译基线。外部技能应保留
来源和许可证，但引入后可以根据个人工作方式继续调整，不要求成为来源仓库的完整镜像。

配套 Markdown 参考文档的英文行为锚点位于
[`config/reference-terms.json`](config/reference-terms.json)。中文、英文、中英混合、
负例和显式调用用例位于
[`tests/invocation-cases.json`](tests/invocation-cases.json)，受保护的源文结构位于
[`tests/translation-contracts.json`](tests/translation-contracts.json)。

## 获取与维护 Skills

可以从其他仓库挑选适合自己的技能，也可以直接在本仓库编写。引入外部技能时，应先
审阅行为和许可证，再记录来源、选择性本地化，并通过调用用例与翻译契约验证。来源检查
只报告远程变化，任何合并都必须人工决定，避免远程更新覆盖本地工作方式。

完整流程见 [`SOURCES.md`](SOURCES.md)。

## 许可证

仓库自行编写的新增内容使用 MIT License。外部技能继续遵循各自来源许可证，并按来源
记录在 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) 和
`THIRD_PARTY_LICENSES/` 中。
