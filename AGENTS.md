# Skills 仓库维护流程

本仓库的每个 Skill 都必须先成为可验证的项目内容，再考虑安装到用户目录。不要把项目内
分类目录、仓库清单和用户目录中的 Junction 混为一件事。

## 引入新的外部 Skill

1. 阅读上游 `SKILL.md`、许可和关联文件，确认适合引入；记录来源仓库、分支和审阅时的提交。
2. 将 Skill 放在 `skills/<category>/<skill-name>/`，其中 `category` 只能是 `development`、`planning`、`quality`、`knowledge` 或 `workflow`。不得在 `skills/` 根目录直接放置 Skill。
3. 本地化或适配时保持中文主说明，并在 `description` 中保留一个准确的英文触发锚点。只有忠实翻译时才启用 `translation_contract` 并生成契约；若为本地行为重构，设为 `false`，不要伪造翻译契约。
4. 创建或更新 `agents/openai.yaml`。其 `allow_implicit_invocation` 必须与清单一致，`default_prompt` 必须包含 `$<skill-name>`，`short_description` 长度为 25～64 个字符。
5. 在 `config/skills.json` 中登记：
   - 新上游来源：`sources` 中的仓库、URL、`default_ref`、许可证路径和审阅基线；
   - Skill：名称、分类、`source_id`、`source_path`、调用策略和精确的 `baseline_skill_sha256`。
   上游哈希必须针对 GitHub 原始 UTF-8/LF 字节计算，不得直接使用 Windows 工作区中可能为 CRLF 的文件哈希。
6. 将许可证保存到 `THIRD_PARTY_LICENSES/`，并在 `THIRD_PARTY_NOTICES.md` 记录本地改造范围。
7. 更新 README 的分类表，并在 `tests/invocation-cases.json` 添加同名条目。每组 `positive_zh`、`positive_en`、`positive_mixed`、`negative`、`explicit` 至少包含一个用例；`explicit` 必须包含 `$<skill-name>`。

## 修改已有 Skill

1. 先读取该 Skill、`config/skills.json`、调用用例及其来源记录。
2. 保持 Skill 路径、清单分类和 `agents/openai.yaml` 策略一致；修改自动调用边界时，同步更新 description 和正反调用用例。
3. 上游存在更新时先运行来源检查并人工审阅差异。只有确认采纳后，才更新 `baseline_skill_sha256`；来源检查不能自动覆盖本地适配内容。
4. 翻译契约适用时，先准备经过审阅的源语言副本，再运行 `scripts/new-translation-contract.ps1 -Skill <skill-name> -Force`。不要使用已本地化文件作为源语言基线。

## 验证与安装

完成项目内变更后，至少运行：

```powershell
.\scripts\verify.ps1
.\scripts\check-sources.ps1 -Source <source-id> -Detailed
git diff --check
```

只有用户明确要求将项目 Skill 安装到官方用户目录时，才执行安装流程：

```powershell
.\scripts\install.ps1 -WhatIf
.\scripts\install.ps1
.\scripts\verify.ps1 -CheckInstallation
```

安装目标是 `%USERPROFILE%\.agents\skills`，由脚本创建扁平的 Junction；不要在项目内创建 `.agent` 或 `.agents` 链接目录。`install.ps1` 会遍历清单中的全部 Skill，因此执行前要说明影响范围并取得明确授权。不得自动提交 Git。
