# 技能来源与同步流程

本仓库是个人精选集合，不绑定单一上游。技能可以：

- 在本仓库中自行编写；
- 从一个或多个公开仓库挑选后引入，或在自行具备访问权限时从私有仓库引入；
- 在引入后翻译、精简或按个人工作方式调整。

每个来源登记在 `config/skills.json` 的 `sources` 中，每个技能通过 `source_id`
独立关联来源。外部技能还应记录 `source_path`、许可证和经过人工审阅的
`baseline_skill_sha256`。自编技能使用 `local` 来源，不需要远程路径或来源基线。

`README.md` 只说明这套通用工作方式，不列出某个外部仓库作为固定依赖。
真实出处只放在机器可读清单、第三方声明和必要的来源专用 Skill 中。这样以后增加
自己的 Skill、替换某个外部 Skill，或从新的仓库择优引入时，都不需要改写仓库定位。

## 引入外部技能

1. 阅读候选技能及其引用文件，确认它确实适合自己的工作方式。
2. 检查来源许可证是否允许复制和修改，并把许可证保存到
   `THIRD_PARTY_LICENSES/`，同时在 `THIRD_PARTY_NOTICES.md` 增加来源小节。
3. 在 `sources` 中登记新的来源；同一来源只登记一次。
4. 将技能复制到 `skills/<category>/<skill-name>/`，并在该技能清单项中记录来源、路径和 `category`。
5. 如果需要中文本地化，设置 `translation_contract: true`，保留重要英文触发词和
   行为锚点，并从审阅过的源语言文件生成翻译契约。
6. 补充 `agents/openai.yaml`、调用用例和必要的英文行为锚点。
7. 运行完整验证并人工审阅；仓库脚本不会自动提交 Git。

例如，从另一个 GitHub 仓库挑选 Skill 时，可以新增一个独立来源：

```json
{
  "id": "example-source",
  "kind": "github",
  "repository": "owner/repository",
  "url": "https://github.com/owner/repository",
  "default_ref": "main",
  "license": "LICENSE-ID",
  "license_file": "THIRD_PARTY_LICENSES/example-source-LICENSE"
}
```

对应 Skill 只引用该来源，不影响集合中的其他 Skill：

```json
{
  "name": "selected-skill",
  "source_id": "example-source",
  "source_path": "path/to/selected-skill",
  "baseline_skill_sha256": "<reviewed-source-skill-sha256>",
  "translation_contract": true,
  "allow_implicit_invocation": false,
  "required_english_terms": ["important trigger"]
}
```

`source_path` 指向来源仓库中包含 `SKILL.md` 的目录，必须使用 `/` 分隔，不能带
`SKILL.md` 文件名、绝对路径或 `..`。`baseline_skill_sha256` 是远程原始
`SKILL.md` **精确字节**的 SHA-256，不是翻译后文件或重新编码文本的哈希。

首次登记时，可以暂时省略 `baseline_skill_sha256`，再运行：

```powershell
# 显示完整远程哈希和解析后的 URL；缺少基线时命令会返回非零退出码。
.\scripts\check-sources.ps1 -Source example-source -Detailed
```

人工确认下载内容与许可证后，把输出中的 `RemoteSha256` 写入
`baseline_skill_sha256`，再运行完整验证。普通 `github.com` 来源可自动检查；
GitHub Enterprise、其他托管平台或需要自定义认证的来源，应登记为人工来源：

```json
{
  "id": "example-manual-source",
  "kind": "manual",
  "url": "https://example.com/owner/repository",
  "license": "LICENSE-ID",
  "license_file": "THIRD_PARTY_LICENSES/example-manual-source-LICENSE"
}
```

人工来源同样要在 Skill 条目中记录 `source_path` 和经过审阅的
`baseline_skill_sha256`，但来源检查只提示人工复核，不会尝试匿名下载。

## 自行编写技能

自编技能使用：

```json
{
  "name": "my-skill",
  "source_id": "local",
  "translation_contract": false,
  "allow_implicit_invocation": false
}
```

自编技能不需要伪造外部来源、许可证或英文翻译基线。它仍应具有有效的
`SKILL.md`、`agents/openai.yaml` 和调用测试。无论来源如何，`SKILL.md` 的
`description` 都采用中文主描述并至少保留一个英文触发词。

`agents/openai.yaml` 至少满足以下格式；`allow_implicit_invocation` 必须与清单一致，
`short_description` 长度为 25–64 个字符，`default_prompt` 必须包含技能名：

```yaml
interface:
  display_name: "我的技能"
  short_description: "说明这个 Skill 何时使用以及它要完成的主要工作"
  default_prompt: "使用 $my-skill 完成这项工作。"

policy:
  allow_implicit_invocation: false
```

还要在 `tests/invocation-cases.json` 的 `skills` 数组中增加同名条目。五组提示都
至少包含一项，`explicit` 必须出现 `$<skill-name>`：

```json
{
  "name": "my-skill",
  "positive_zh": ["一个应当调用该技能的中文请求。"],
  "positive_en": ["An English request that should invoke the skill."],
  "positive_mixed": ["一个包含 English trigger 的混合请求。"],
  "negative": ["一个不应调用该技能的相邻请求。"],
  "explicit": ["$my-skill 明确使用这个技能。"]
}
```

## 为单个外部 Skill 建立翻译契约

先把该 Skill **翻译前**的完整目录放入独立暂存根目录，例如
`C:\Temp\source-skills\selected-skill\`；其中要包含原始 `SKILL.md` 和所有将被
本地化的 Markdown 参考文件。清单中先设置 `translation_contract: true`，然后运行：

```powershell
# 先预览；只更新 selected-skill，保留现有其他契约。
.\scripts\new-translation-contract.ps1 `
  -SourceSkillsRoot C:\Temp\source-skills `
  -Skill selected-skill `
  -Force `
  -WhatIf

# 人工确认暂存目录确实是经过审阅的源语言版本后再写入。
.\scripts\new-translation-contract.ps1 `
  -SourceSkillsRoot C:\Temp\source-skills `
  -Skill selected-skill `
  -Force
```

随后翻译仓库内对应文件，并为每个已翻译的配套 Markdown 在
`config/reference-terms.json` 中登记必须保留的英文行为锚点。省略 `-Skill` 会重建
全部已启用的翻译契约，此时暂存根目录必须包含所有这类 Skill 的源语言版本。

## 目录与分类约束

仓库按 `skills/<category>/<skill-name>/` 组织，以使用场景帮助维护者浏览。安装、卸载
和验证脚本从 `config/skills.json` 的 `category` 解析仓库路径，但安装到 Codex 的用户
目录时始终保持 `.agents/skills/<skill-name>/` 的扁平命名空间。不要在 `skills/` 根目录
创建旧路径兼容链接；分类、目录与 README 索引均由清单驱动。

## 检查外部来源

```powershell
# 检查全部已登记的远程来源；只报告，不修改技能。
.\scripts\check-sources.ps1

# 只检查一个来源。
.\scripts\check-sources.ps1 -Source <source-id>

# 在 CI 中让“发现更新”返回非零退出码。
.\scripts\check-sources.ps1 -FailOnUpdate
```

状态含义：

- `local`：本仓库自编技能，不需要远程检查。
- `manual-review`：该来源需要按登记 URL 和许可证人工复核。
- `baseline-missing`：已取得远程内容，但还没有记录有效的审阅基线。
- `unchanged`：远程 `SKILL.md` 与审阅基线一致。
- `update-available`：远程内容发生变化，需要人工审阅。
- `error`：网络、来源配置、路径或下载失败，不能当作“无更新”。

## 人工合并外部更新

1. 阅读来源 diff，确认正文、引用文件和目录结构是否一起变化。
2. 只合并适合自己使用的变化，不要求与来源仓库保持完整镜像。
3. 本地化正文时保留中文主描述和英文关键触发词／行为锚点。
4. 行为敏感结构确实改变时，人工复核后重新生成翻译契约；不要为了让验证通过而
   盲目提升基线。
5. 复核隐式调用策略、调用测试和第三方声明。
6. 接受更新后，更新对应技能的 `baseline_skill_sha256`。
7. 运行 `.\scripts\verify.ps1 -CheckInstallation`，人工审阅后再自行提交。

来源检查脚本只提供更新信号，绝不自动覆写本地技能。个人集合的最终行为以本仓库版本为准。
