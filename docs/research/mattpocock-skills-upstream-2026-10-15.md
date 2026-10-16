# mattpocock/skills：11 项来源更新的具体内容

调查日期：2026-10-15（Asia/Shanghai）。本文主体记录合并前的比较结果；用户随后授权采纳，结果见文末“本次采纳”。

## 比较依据与范围

调查开始时，本仓库 [config/skills.json](../../config/skills.json) 收录 25 个 `mattpocock-skills` 来源技能，审阅基线为 `4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d`（2026-10-06 记录）。本次固定比较至 `49dd158d1076134a641b33efb035946536778336`，提交时间为 2026-10-09 18:56:49（上海时间）。GitHub 官方 compare API 返回 `ahead_by=42`、`total_commits=42`。[完整固定版本比较](https://github.com/mattpocock/skills/compare/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d...49dd158d1076134a641b33efb035946536778336)、[官方 API](https://api.github.com/repos/mattpocock/skills/compare/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d...49dd158d1076134a641b33efb035946536778336)

按清单的 `source_path` 对照比较结果，**11 个已收录技能的 `SKILL.md` 有变化，14 个未变；已收录目录内另有 3 个配套 Markdown 变化，均在 setup 技能中**。本次逐项审阅了这 14 个文件的全部 patch。来源检查脚本仅下载入口 `SKILL.md` 并比较 `baseline_skill_sha256`，因此“11 项更新”不是整个上游仓库的变更数，也不包含配套模板。[检查脚本](../../scripts/check-sources.ps1)、[固定版本比较](https://github.com/mattpocock/skills/compare/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d...49dd158d1076134a641b33efb035946536778336)

下文“上游变化”均指两个英文源版本之间的差异；本仓库中文翻译及现有本地适配不是本次上游变更。尤其是工作区现有 `to-tickets` 双模式改造，不能归因于上游这次更新。

## 11 个入口逐项变化

技能名链接均固定到本次审阅的上游提交。

| 技能 | 上游变化 | 对使用行为的影响 |
| --- | --- | --- |
| [ask-matt](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/ask-matt/SKILL.md) | 新增要求：介绍某技能的职责或建议跳过某步骤前，先读该技能的 `SKILL.md`；路由中的摘要仅供定位。 | 防止仅凭路由摘要猜测能力或跳过必要步骤。没有新增路由。 |
| [code-review](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/code-review/SKILL.md) | 不再硬编码 tracker 文档必须位于 `docs/agents/issue-tracker.md`，改用已提供的 tracker 配置；要求搜索所有规范文件，存在 `CODING_STANDARDS.md` 或 `CONTRIBUTING.md` 时必须纳入；两轴子代理必须一起在前台调用并汇总返回报告。 | 减少遗漏规范，明确 Standards / Spec 并行审阅的调度和汇总方式。两轴与 smell baseline 本来就存在。 |
| [diagnosing-bugs](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/diagnosing-bugs/SKILL.md) | 如果通过修改代码或 fixture 强制造出红灯，先和干净副本做 `diff`，证明修改确实生效。 | 防止把未落地的故障注入误当成有效的失败验证；仅在用这种方式制造红灯时适用。 |
| [implement](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/implement/SKILL.md) | 用户传入工单引用时，先从 tracker 获取并报出标题，有歧义则询问；`tdd` 和 `code-review` 改为明确调用 Skill tool。 | 避免把 `#2` 误解成上下文中的第二项任务；把“使用技能”写成明确加载动作。结尾提交当前分支的指令原本已存在。 |
| [setup-matt-pocock-skills](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/setup-matt-pocock-skills/SKILL.md) | 在 GitHub / GitLab 完成 Section B 标签配置后，通过 `gh label create` / `glab label create` 创建 tracker 中缺失的已配置标签。 | 配置不再只写文档；还补齐实际标签。仅在 Section B 确实运行时执行。 |
| [tdd](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/tdd/SKILL.md) | 提议每个测试 seam 时，加一句说明它能发现什么、遗漏什么。 | 用户确认测试边界时能看到覆盖取舍；预先确认 seam 的要求并非本次新增。 |
| [to-tickets](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/to-tickets/SKILL.md) | 明确拆开“阻塞关系”和“父子关系”：用原生阻塞边表达依赖；若输入来自已有 issue，每张拆分工单都设为该 issue 的子 issue。使用原生阻塞边时，正文省略 `## Blocked by`。 | 避免把 sub-issue 当成依赖边，也避免原生边与正文重复维护。没有新增本地任务 / tracker 双模式；上游基线已包含按 tracker 选择发布方式。 |
| [wayfinder](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/wayfinder/SKILL.md) | map 和决策工单只能带 `wayfinder:` 标签，不能混入 `ready-for-agent` 等 triage 标签；第二遍接依赖边时也填写真实 ID 的交叉引用；研究分支需 push，但不开 PR、永不合并；处理工单时读取类型标签，不能只看正文。 | 区分决策探索和实施工单；防止占位引用错误关联其他 issue；明确研究结果的发布方式及工单类型分派。并行研究和临时研究分支原本已存在。 |
| [grilling](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/productivity/grilling/SKILL.md) | 每个问题的措辞应使“yes”表示接受推荐答案。 | 统一确认方向，减少“是”到底接受哪个选项的歧义。没有改变 frontier 分轮访谈结构。 |
| [handoff](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/productivity/handoff/SKILL.md) | 明确临时目录解析：`$TMPDIR`，否则 `/tmp`；Windows 使用 `%TEMP%`。 | 减少寻找临时目录的试错。保存到临时目录而非工作区的规则原本已存在。 |
| [teach](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/productivity/teach/SKILL.md) | 课程文件路径从调用 `/teach` 的工作目录解析，只有 `*-FORMAT.md` 从技能目录解析；测验正确答案在各题中要变换位置。 | 防止把课程写进安装技能的目录；减少通过答案顺序猜中答案。 |

## 容易漏掉的 3 个配套文件

这些变化属于已收录的 setup 技能，但不单独计入“11 项入口哈希变化”。

| 文件 | 上游变化 |
| --- | --- |
| [issue-tracker-github.md](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md) | 读 issue 改用 `--json number,title,body,labels,comments`，获取相关工单时复用该操作。新增子 issue 操作：模板标注 `gh` 2.94+ 可用 `gh issue create --parent` / `gh issue edit --add-sub-issue`，旧版本给出 API 方式，不支持时回退到 `Part of #…`；wayfinder 子工单说明复用此操作。外部 PR 列表从请求 `gh pr list` 不支持的 `authorAssociation` 字段，改为分页 REST API，按 `author_association` 排除 OWNER / MEMBER / COLLABORATOR。 |
| [issue-tracker-gitlab.md](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/setup-matt-pocock-skills/issue-tracker-gitlab.md) | issue 列表及 frontier 查询的 JSON 参数由 `-F json` 改为 `-O json`；查询链接的路径把模糊的 `:iid` 改成显式 `<child-iid>`。 |
| [triage-labels.md](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/skills/engineering/setup-matt-pocock-skills/triage-labels.md) | 将“编辑右侧一列”改成明确编辑 `Label in our tracker` 列，避免误改 Meaning 列。属于文案准确性修复。 |

以上命令是对上游补丁的描述，未在真实 tracker 执行。若后续采纳 GitHub 子 issue 修复，已有项目的 tracker 文档也需同步；上游人类文档明确提示重新运行 setup 刷新旧文档。[to-tickets 使用文档](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/docs/engineering/to-tickets.md)

## 其他上游变化：仅作范围概述

完整比较没有新增 `SKILL.md` 入口。未收录内容的变化还包括 `wizard/template.sh`，实验技能 `chief-of-staff`、`claude-handoff`，以及安装说明、维护政策、issue 模板、triage 自动化与人类使用文档；这些不计入已收录技能的 11 项更新。本记录没有对所有未收录内容进行完整行为审计。[完整比较](https://github.com/mattpocock/skills/compare/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d...49dd158d1076134a641b33efb035946536778336)

上游新增 `SCOPE.md`，要求改进请求来自真实会话中的已观察失败，并符合其维护方向；misc 冻结，新技能提案不接纳。另明确不在共享 grilling 技能中内建宿主原生询问 UI，偏好该 UI 的用户可在自己的 `AGENTS.md` / `CLAUDE.md` 配置。这是上游项目的取舍，不是本仓库禁止本地适配的规则，也不否定用户明确要求的弹窗交互。[SCOPE.md](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/SCOPE.md)、[原生询问工具的范围说明](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/.out-of-scope/native-question-tool.md)

发行 ADR 新增了作者对 Codex / Copilot 托管安装的验证记录，安装说明也随之调整；这属于上游分发策略更新，不意味着本仓库应改用其安装流程。本记录未另行验证当前产品安装能力。[固定版本发行 ADR](https://github.com/mattpocock/skills/blob/49dd158d1076134a641b33efb035946536778336/.agents/adr/0002-ship-as-a-claude-code-plugin.md)

## 调查阶段的采纳建议

1. 优先审阅工单链路：`implement`、`to-tickets`、`wayfinder` 和 setup 三个模板应一起看，避免入口更新而项目 tracker 文档仍旧。
2. `ask-matt` 和 `to-tickets` 已有本地行为适配，应按语义合并；保留当前 `to-tickets` 双模式设计。其余小修复可逐项评估，但仍需中文翻译、契约和验证流程。
3. 若采纳“读取真实工单、明确标题”“正确区分阻塞与父子关系”等修复，应保留本仓库的权限和调用边界。上游写着提交或推送，不等于本次调查授权执行这些操作。
4. 采纳后才更新源基线和精确哈希；当前研究无需改变清单、翻译契约、调用用例或用户目录安装。[仓库维护约束](../../AGENTS.md)

调查阶段只新增本文件；没有合入上游、更新哈希、安装或提交。

## 本次采纳（2026-10-15）

用户授权后，已将上述 11 个技能入口和 3 个 setup 配套文件的变化合入中文版本，来源基线更新至 `49dd158d1076134a641b33efb035946536778336`。11 个变化入口的哈希按该提交的原始 UTF-8/LF 字节更新；9 个忠实翻译技能的契约从审阅过的英文源副本重新生成。其余 14 个入口的原始哈希未变。

保留 `ask-matt` 的本地路由、`wait-what` 的语言适配，以及 `to-tickets` 的场景／垂直切片手动选择、局部预重构和测试质量规则；三者仍不使用翻译契约。`ask-matt` 的拆单指针同步说明由用户选择模式。`to-tickets` 在保留父议题其他内容和状态的前提下允许建立子议题关联，原生阻塞边与正文去重规则适用于两种模式。

本次未引入未收录技能、上游安装与维护政策，也未运行项目初始化或真实 tracker 操作。改动保留在工作区，没有安装到用户目录或提交 Git。

验证结果：

- `scripts/verify.ps1` 通过：32 个技能、2 个来源的元数据、策略、链接、调用用例和脚本均有效。
- `scripts/check-sources.ps1 -Source mattpocock-skills -Detailed` 通过：`unchanged=25, updates=0, errors=0`。
- 25 个上游入口的原始 UTF-8/LF 字节哈希、22 个英文正文契约和 22 个配套文档契约全部与固定提交匹配；未选中的技能契约保持不变。
- 11 个更新技能的 `quick_validate.py` 检查及 `git diff --check` 均通过。
