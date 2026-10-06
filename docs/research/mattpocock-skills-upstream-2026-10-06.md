# mattpocock/skills 与本仓库的更新对比

调查日期：2026-10-06，时间按 Asia/Shanghai。范围：上游最新内容、未收录技能、改名与移除、发行及目录变化，以及本仓库现有 22 个来源技能与配套文件的逐项差异。

> 本文主体记录更新前的比较快照；后续采纳结果见文末。清单及契约链接现在指向更新后的文件。

## 比较依据

本地 [config/skills.json](../../config/skills.json) 登记了 22 个 `mattpocock-skills` 来源技能，来源基线为 2026-07-31 的本地安装快照，`commit` 为 `null`。本次以清单中的 22 个 `baseline_skill_sha256` 反查 Git 原始 blob；22 个技能均与上游提交 `391a2701dd948f94f56a39f7533f8eea9a859c87`、`2ee14df19c2bbea2303e0a187e8619a5ddef8817` 的对应文件完全匹配。两者均提交于 2026-07-10。后文使用较新的 `391a270…` 作为可复现的内容参考点；这能确定源文件内容，不能唯一确定当时安装采用的提交，也没有修改清单中的来源记录。[参考树](https://github.com/mattpocock/skills/tree/391a2701dd948f94f56a39f7533f8eea9a859c87/skills)、[另一匹配提交](https://github.com/mattpocock/skills/commit/2ee14df19c2bbea2303e0a187e8619a5ddef8817)

进一步将 [翻译契约](../../tests/translation-contracts.json) 中的 22 个技能正文哈希与 21 个配套 Markdown 哈希和上述参考树核对，**43 项全部匹配**。因此可以比较经过核实的英文旧版与英文最新版，再结合本地中文指令说明影响，避免把翻译差异或 Windows CRLF 转换误判为上游更新。比较使用 `git cat-file` / `git show` 返回的原始 UTF-8/LF 字节。[完整上游比较](https://github.com/mattpocock/skills/compare/391a2701dd948f94f56a39f7533f8eea9a859c87...4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d)

本次查询的最新 `main` 是 **`4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d`**，提交于上海时间 **2026-10-05 19:17:18**。该提交补充 `chief-of-staff` 的描述；上一条提交于同日新增该实验技能。因此，最新 main 的变化应与最新版本号分别说明。[最新提交](https://github.com/mattpocock/skills/commit/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d)、[新增 chief-of-staff](https://github.com/mattpocock/skills/commit/e47c149e9489bccd6acb41a1fb420ed68a5067e1)

`package.json` 和 Claude Code 插件元数据目前均为 **1.3.1**。`v1.3.1` 标签对应提交 `24fe0ef7737efae15c87225755e9f6f5965e4888`，发布于 2026-10-04；它早于上述最新 main。[package.json](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/package.json)、[插件元数据](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/.claude-plugin/plugin.json)、[1.3.1 对应提交](https://github.com/mattpocock/skills/commit/24fe0ef7737efae15c87225755e9f6f5965e4888)

本地来源检查结果为 **19 个原路径正文变化、1 个正文一致、2 个旧路径 404**。核实两个 404 后，22 个已有技能应理解为 **19 个原名更新、1 个改名并重构、1 个移除、1 个正文不变**。哈希变化包含文案、标点和调用指令变化，不代表 19 项都发生大幅功能重构；逐项说明见下文。

## 最新稳定集合中，本地未收录的六个名称

上游目前正式推广的技能为 **27 个**：`engineering` 20 个，`productivity` 7 个；Claude Code 插件清单也恰好登记这 27 个。相对本地 22 个来源技能，数量关系是：保留 20 个原名、1 个改名、1 个删除，再增加下列 6 个名称。下表中的“新加”均以反查到的 2026-07-10 内容参考树为准。[正式技能目录](https://github.com/mattpocock/skills/tree/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills)、[完整插件清单](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/.claude-plugin/plugin.json)

| 技能 | 相对参考树的状态 | 最新调用方式 | 主要作用与一手来源 |
| --- | --- | --- | --- |
| `implement-spec` | 新加；1.3.0 晋升到 engineering | 用户显式调用 | 按 ticket 阻塞关系维护任务图与就绪 frontier；并行 implementer 各用独立 worktree，在一条 integration branch 汇总整份 spec，再由 `code-review` 收尾。目标是完整实现及关闭 tickets；需要 PR 时，第一次合并后才创建 draft PR。[SKILL.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/implement-spec/SKILL.md)、[晋升提交](https://github.com/mattpocock/skills/commit/24f41cc26d34ffd688e9105b43798a4b446e267d) |
| `retro` | 新加；1.3.0 晋升到 engineering | 用户显式调用 | 复盘编码会话，按严重程度提出 agent 环境改进：导航、自动检查、编码规范、steering files、工具成本、信息访问等。机械规则优先变成 lint、hook 或 CI；需要判断的规则才放进 `CODING_STANDARDS.md`。[SKILL.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/retro/SKILL.md)、[晋升提交](https://github.com/mattpocock/skills/commit/a7d038f6bf7f01b516408e95e2fb56e0b338fa6f) |
| `pr` | 新加；1.3.0 晋升到 engineering | 模型可自动调用 | 规定 PR 正文格式：最小图示、伪代码、树或 diff 作为 Summary；Before/After 验证作为 Evidence；Merge Danger 说明可逆性和影响范围。包含来自 Dex Horthy `show-me` 的归属记录。[SKILL.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/pr/SKILL.md)、[CREDITS.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/pr/CREDITS.md) |
| `wizard` | 参考树已有 beta；后来晋升到 engineering | 模型可自动调用 | 生成交互式 Bash 向导，组织只有人能完成的操作：第三方控制台、凭据、CI secrets、迁移或切换。提供固定 `template.sh`，支持隐藏输入、URL 打开、`.env` 更新与阶段确认；最新模板按阶段计数，已删除时间估计。[参考树中的 beta](https://github.com/mattpocock/skills/blob/391a2701dd948f94f56a39f7533f8eea9a859c87/skills/in-progress/wizard/SKILL.md)、[最新 SKILL.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/wizard/SKILL.md)、[删除时间估计](https://github.com/mattpocock/skills/commit/c0fd1e973e040347d424e09934099f1bd6c2dee0) |
| `to-questionnaire` | 新加；1.2.0 晋升到 productivity | 用户显式调用 | 用户无法独自回答问题时，生成给另一位知情人的 Markdown 问卷。先确认收件人和希望获得什么，再针对知识缺口提问；输出 `to-questionnaire-<slug>.md`。[SKILL.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/to-questionnaire/SKILL.md)、[晋升提交](https://github.com/mattpocock/skills/commit/0f2bdbdb06220d2df3718b8f0483157c6c8a8600) |
| `wait-what` | 新加；1.2.0 收录到 productivity | 用户显式调用 | 用户没有理解上一条信息时重新解释：补背景、使用简明技术英语与领域词汇；最新支持由 `GLOSSARY-MAP.md` 导航到对应 `GLOSSARY.md`。[SKILL.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/wait-what/SKILL.md)、[新增提交](https://github.com/mattpocock/skills/commit/355fa7420b418af838998f7ec4365ceda1c8dfcc) |

`implement-spec`、`pr`、`retro` 是 1.3.0 的主要新增正式技能；`wizard`、`to-questionnaire`、`wait-what` 已在 1.2.0 系列进入正式集合。因此应称为“本地未收录的六个正式名称”，其中只有五个是相对参考树新增，`wizard` 属于既有 beta 的晋升。[1.3.0 晋升变更](https://github.com/mattpocock/skills/commit/2aecca12ea9ff047f76c8178cb64dfeafd192abe)、[wizard 晋升](https://github.com/mattpocock/skills/commit/b3376f8d39848dd08572ec2667da4739a67c8c04)、[wait-what 进入正式目录](https://github.com/mattpocock/skills/commit/50777fcc0982d5867997a75a1e0731b9daac94eb)

## writing-great-skills 改名及行为变化

`writing-great-skills` 已改名为 **`writing-for-agents`**，旧路径被删除，没有兼容别名。该改名提交的 author date 是 2026-07-23，committer date 是 2026-07-31 17:04:40 UTC，不能仅凭 author date 与本地快照的捕获日期判断先后。[改名提交](https://github.com/mattpocock/skills/commit/1fc6573e0e300118ce342fb9365521c9c34eefd4)

内容范围扩大到 agent 消费的所有文档，包括 Skills、`AGENTS.md`、`CLAUDE.md` 和通过指针读取的文档。原独立 `GLOSSARY.md` 合入主文件，skill 专属机制拆到 `SKILL-MECHANICS.md`；新增 context pointer、cache 等概念，并重写删减和信息层次原则。[最新主文件](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/writing-for-agents/SKILL.md)、[SKILL-MECHANICS.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/writing-for-agents/SKILL-MECHANICS.md)

调用方式也由仅用户显式调用调整为模型可自动调用。1.2.2 又修正 Codex 元数据中遗留的 `allow_implicit_invocation: false`，同步更新仍写旧名称的 UI 文案。若以后采纳，需要同时审阅本地清单、名称、路径、调用用例和元数据；旧路径的来源检查 404 是这次改名的结果。[Codex 调用策略修复](https://github.com/mattpocock/skills/commit/4aaccb58d40559d7e3c59a029b2290ae5ba538de)

## resolving-merge-conflicts 被移除

上游 2026-09-24 删除 **`resolving-merge-conflicts`**，从技能目录、插件清单、README 及 `ask-matt` 路由移出。上游明确写明不再需要专用技能，agent 直接处理 merge/rebase conflict，**没有替代技能**。这是主动移除，不能将当前 404 解释为暂时网络问题。[移除提交](https://github.com/mattpocock/skills/commit/daa01d8aa68ad5c61b68970ec2018d0ce9567be6)

后续提交恢复保留其文档页并标记 archived；保留文档不代表恢复了可安装技能。该移除包含在 1.3.0 中。本次调查没有删除本地版本。[保留归档文档](https://github.com/mattpocock/skills/commit/deb4a9c8fe0ad4409c02a3f0e341082112bde1f0)、[最新归档文档](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/docs/engineering/resolving-merge-conflicts.md)

## 目录及发行方式

最新版共有 **38 个 `SKILL.md`**：27 个正式推广技能、7 个 `in-progress`、4 个 `misc`。`in-progress` 是公开 beta，排除于正式插件和顶层 README；`misc` 也是未正式推广的工具。`deprecated` 目录保留但目前为空。[最新目录树](https://github.com/mattpocock/skills/tree/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills)、[beta 约定](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/in-progress/README.md)、[misc 清单](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/misc/README.md)、[deprecated 约定](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/deprecated/README.md)

新实验技能 **`chief-of-staff`** 在一条长期会话中协调 subagents 和 schedules，主会话保留战略判断，任务尽量交给 subagents，并持续改善 agent 环境。它于 2026-10-05 新增，尚未列入 `in-progress/README.md`，但技能文件和 Codex 元数据已存在；统计采用实际文件树而非 README 行数。[当前 SKILL.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/in-progress/chief-of-staff/SKILL.md)、[新增提交](https://github.com/mattpocock/skills/commit/e47c149e9489bccd6acb41a1fb420ed68a5067e1)

其余六个 beta：`loop-me`、`writing-beats`、`writing-fragments`、`writing-shape`、`claude-handoff`、`setup-ts-deep-modules`；四个 misc：`git-guardrails-claude-code`、`migrate-to-shoehorn`、`scaffold-exercises`、`setup-pre-commit`。这十个在参考树已经存在，本地未收录，不应计为此次新增。[参考 beta 目录](https://github.com/mattpocock/skills/tree/391a2701dd948f94f56a39f7533f8eea9a859c87/skills/in-progress)、[参考 misc 目录](https://github.com/mattpocock/skills/tree/391a2701dd948f94f56a39f7533f8eea9a859c87/skills/misc)

另删除了六个本地未收录的旧技能：`ubiquitous-language`、`design-an-interface`、`qa`、`request-refactor-plan`、`edit-article`、`obsidian-vault`。前四个的能力已归入其他正式技能；后两个是作者私用技能，`personal` 目录随之删除。[移除六个技能的变更记录](https://github.com/mattpocock/skills/commit/c66bdeeee002d81e3f8b21403c07f9a0d7bea6da)

发行层面，1.2 系列补齐原生 Claude Code 插件与 Codex 的 `agents/openai.yaml` 元数据；上游 README 现在提供 Claude Code 官方 marketplace 安装入口，以及面向 Codex 等环境的 `skills.sh` 文件安装入口。上游 ADR 记录仍暂缓原生 Codex 插件，原因是其当时的单路径技能选择与正式/非正式分桶不匹配；这是该项目记录的发行决策，不应直接等同于当前 Codex 产品能力结论。[Claude 插件发行提交](https://github.com/mattpocock/skills/commit/42a5b70fcacc7baff1977b13f3919fb2f63af14e)、[Codex 元数据提交](https://github.com/mattpocock/skills/commit/697d4ce9742da558fd1ba6697c8e9775e2e302dd)、[发行 ADR](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/.agents/adr/0002-ship-as-a-claude-code-plugin.md)

版本管理采用 Changesets：主分支触发 version PR，更新版本时同步 `package.json` 与插件版本，并通过标签发布。1.3.1 的内容是修复 `ask-matt` 和 diagnosing-bugs 文档中遗留的 post-mortem 路由：修复 bug 后的反思指向 `retro`，缺少 seam 时再考虑 `improve-codebase-architecture`。[release workflow](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/.github/workflows/release.yml)、[1.3.1 修复提交](https://github.com/mattpocock/skills/commit/c5b98691982c4f0d3a5e40ab09566b3b84721e00)

## 跨技能变化，需要和新增技能一起审阅

- 领域文档约定由 `CONTEXT.md` / `CONTEXT-MAP.md` 改成 `GLOSSARY.md` / `GLOSSARY-MAP.md`，涉及读写它们的多项技能；最新流程只查新名称，旧项目需要迁移对应文档与指针。[约定迁移提交](https://github.com/mattpocock/skills/commit/e484a8095543718ced436b9b49a8160ed4554000)
- 跨技能调用改为显式说明调用 Skill tool，并区分模型可调用与仅用户可调用的技能；后一类由 agent 提醒用户运行，不能由其他技能调用。`diagnosing-bugs` 因此移除了自动转入 `improve-codebase-architecture` 的 post-mortem 阶段。[调用指令标准化](https://github.com/mattpocock/skills/commit/e3e547b57d549110a0aa6ff40fd7b871c01c76c9)、[修复用户调用边界](https://github.com/mattpocock/skills/commit/1dab98299c3b81f560026c01b7ebf55ed5d91373)
- `grilling` 从逐题问答变成按就绪 frontier 一轮提多个问题，并后台调查能由环境回答的事实。[逐轮问答提交](https://github.com/mattpocock/skills/commit/a4b2009a1a3ac9575506c10b4c84f08f9bba7a38)
- 上游普遍清理 prose 中的 em-dash，另修复六个 `description` 未加引号而含冒号的 YAML 发现问题。这类语法修复与行为改动应分开看待。[文案清理](https://github.com/mattpocock/skills/commit/e6e957797d8cceb5b351c0dc840369523f9fb8fb)、[YAML 修复](https://github.com/mattpocock/skills/commit/4f289474bad013fe2be8f8769d733f59d9103d6b)

## 本仓库已收录的 22 个技能逐项差异

下表“变化”均比较清单记录的英文源基线与固定最新提交；技能名链接指向对应的最新源文件。中文本地化、分类目录、Codex 元数据及仓库维护脚本属于本地已有适配，不作为上游行为更新计数。

| 本地技能 | 状态 | 相对本地源基线的实际变化 |
| --- | --- | --- |
| [ask-matt](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/ask-matt/SKILL.md) | 更新 | 路由加入整份 spec 并行实施的 `implement-spec`、PR 正文的 `pr`、主流程末尾的 `retro`，以及 `wizard`、`to-questionnaire`、`wait-what`。新增阶段边界选择说明；`handoff` 主要用于跨工具、跨目录、交给同事或中途分支，常规阶段切换可考虑 `compact`。修正修复 bug 后的复盘路由。 |
| [codebase-design](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/codebase-design/SKILL.md) | 更新 | 主文核心模块设计原则保持一致，主要为措辞调整；配套 `DESIGN-IT-TWICE.md` 换用 `GLOSSARY.md`，删除特定工具名称，使并行接口设计可用于不同 agent 环境。 |
| [code-review](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/code-review/SKILL.md) | 更新 | 保留 Standards / Spec 两轴与原有 Fowler smell baseline。删除绑定 Claude Code 的 `Agent` / `general-purpose` 调度指令；缺少 tracker 配置时提醒用户运行 setup；统一 spec 措辞及有效 YAML description。 |
| [diagnosing-bugs](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/diagnosing-bugs/SKILL.md) | 更新 | 增加展示命令、输出及抓包材料前的 secret 脱敏规则，反馈循环通过环境变量使用凭据；Phase 6 变为 Cleanup，移除自动调用架构改善的 post-mortem；读取 `GLOSSARY.md`。 |
| [domain-modeling](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/domain-modeling/SKILL.md) | 更新 | `CONTEXT.md` / `CONTEXT-MAP.md` 改为 `GLOSSARY.md` / `GLOSSARY-MAP.md`；格式文件随之改名。description 扩展到讨论代码库术语、直接写或编辑词汇表及 ADR，不再含“其他 skill 需要维护模型”的条件。 |
| [grilling](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/grilling/SKILL.md) | 更新 | 从每次只问一个问题，改为每轮提出所有前置条件已满足的问题，即 frontier；相关依赖问题留到后续轮次。每题编号并给推荐答案，问题间加分隔线；可查事实由 subagent 调查，决策仍等待用户回答。用户确认共同理解的门槛在旧版已经存在。 |
| [grill-me](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/grill-me/SKILL.md) | 更新 | 把“运行 `/grilling`”换成明确调用 Skill tool 加载 `grilling`。实际访谈行为取决于上面的共享技能更新。 |
| [grill-with-docs](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/grill-with-docs/SKILL.md) | 更新 | 明确分别调用 Skill tool 加载 `grilling` 与 `domain-modeling`；入口仍很小，逐轮访谈和词汇表改名由两个依赖实现。 |
| [handoff](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/handoff/SKILL.md) | 更新 | “suggested skills” 改为指出后续 agent 应通过 Skill tool 调用哪些技能；交接文档职责保持一致。适用场景的主要新说明位于 `ask-matt/PHASE-BOUNDARIES.md`。 |
| [implement](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/implement/SKILL.md) | 正文不变 | 原始 SKILL.md SHA-256 与本地基线完全相同，仍围绕单个 spec / ticket 实施。并行整份 spec 是新 `implement-spec` 的职责；上游另外新增了 Codex UI 元数据和人类文档说明。 |
| [improve-codebase-architecture](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/improve-codebase-architecture/SKILL.md) | 更新 | 扫描前先确定范围：用户指定方向优先，否则用 git 历史找到近期反复变化的热点，按 YAGNI 分配关注。去掉特定 Explore agent 类型；显式加载共享技能，使用 `GLOSSARY.md`。 |
| [prototype](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/prototype/SKILL.md) | 更新 | 逻辑原型从交互式终端应用变为双击即可运行、可分享给非开发者的单文件 HTML，包含自由操作按钮和分标签的场景演练；纯逻辑模块与页面分离。UI 多变体分支基本保持一致。 |
| [research](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/research/SKILL.md) | 更新 | 只有一处标点和句式调整；后台调查一手来源、输出带引用 Markdown 的行为保持一致。 |
| [resolving-merge-conflicts 的移除提交](https://github.com/mattpocock/skills/commit/daa01d8aa68ad5c61b68970ec2018d0ce9567be6) | 上游移除 | 技能被删除，无替代技能；保留标为 archived 的人类文档。本地仍收录。 |
| [setup-matt-pocock-skills](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/setup-matt-pocock-skills/SKILL.md) | 更新 | 将探索和生成的领域文档改为 `GLOSSARY.md` / `GLOSSARY-MAP.md`，配套 `domain.md` 同步；移除过时的 `qa` 引用。Issue tracker 与 triage 标签设置流程保持一致。 |
| [tdd](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/tdd/SKILL.md) | 更新 | 当接口深度或 seam 本身需要设计时，明确加载 `codebase-design`；换读 `GLOSSARY.md`。预先约定 seam、垂直切片和 tautological test 反例在本地源基线已经存在；配套 `tests.md` / `mocking.md` 完全没变。 |
| [teach](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/teach/SKILL.md) | 更新 | 主文与配套模板主要清理标点和句式；多会话教学、HTML lesson 及 `assets/` 组件复用在基线已存在，未出现新的教学流程。 |
| [to-spec](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/to-spec/SKILL.md) | 更新 | 缺少配置时提醒用户运行 setup；description 使用有效引号，统一为 spec。仍直接综合当前讨论，没有新增访谈流程。 |
| [to-tickets](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/to-tickets/SKILL.md) | 更新 | 缺少配置时提醒用户运行 setup；删除结尾强制“逐个 `/implement` 并清上下文”的指令，为并行整份实施留出选择；模板和标点调整。原生阻塞边与 expand–contract 在本地源基线已经存在。 |
| [triage](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/triage/SKILL.md) | 更新 | 需要澄清时明确分别加载共享技能，改成按轮追问，写 `GLOSSARY.md` / ADR；缺配置时提醒用户运行 setup。外部 PR 分流能力在基线已经存在，不能列为本次新功能。 |
| [wayfinder](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/wayfinder/SKILL.md) | 更新 | 更明确区分决策工单与实施切片；初次建图后立即并行启动 research 工单的 subagents，将结果留在 `research/<name>` 分支并从工单链接。每会话只解决一个工单的规则新增 research 例外；共享技能调用与轮次语义同步。 |
| [writing-great-skills → writing-for-agents](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/writing-for-agents/SKILL.md) | 改名并重构 | 范围从 Skill 写作扩展到所有 agent 文档；重组原独立词汇参考，新增 `SKILL-MECHANICS.md`；允许模型自动调用。详见前文。 |

## 配套文件与核验边界

本地翻译契约记录的 21 个配套 Markdown 中，**16 个内容变化、1 个改名、1 个移除、3 个完全不变**。内容变化也可能只是去掉 em-dash 或统一 spec 名称；不能只看哈希推断行为变化。[对应文件变化](https://github.com/mattpocock/skills/compare/391a2701dd948f94f56a39f7533f8eea9a859c87...4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d)

最值得随 SKILL.md 一起审阅的配套变化是：

- `ask-matt` 新增 [PHASE-BOUNDARIES.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/ask-matt/PHASE-BOUNDARIES.md)，解释 continue、clear、handoff、subagent、compact 五种选择。
- `domain-modeling/CONTEXT-FORMAT.md` 改为 [GLOSSARY-FORMAT.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/domain-modeling/GLOSSARY-FORMAT.md)，并和 setup 的 [domain.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/setup-matt-pocock-skills/domain.md) 一起换用新文档名。
- `prototype/LOGIC.md` 重写为分享给非开发者的 [HTML 演示流程](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/prototype/LOGIC.md)；`UI.md` 主要为措辞及示例注释调整。
- `writing-great-skills/GLOSSARY.md` 旧文件删除，内容重新组织到新主文和 [SKILL-MECHANICS.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/productivity/writing-for-agents/SKILL-MECHANICS.md)，应作为重构审阅。
- `diagnosing-bugs/scripts/hitl-loop.template.sh` 增加注释：capture 会把值打印回终端，应捕获观测结果，登录留给用户 step。[最新模板](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/diagnosing-bugs/scripts/hitl-loop.template.sh)
- 完全未变的配套文件是 setup 的 [triage-labels.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/setup-matt-pocock-skills/triage-labels.md) 和 tdd 的 [mocking.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/tdd/mocking.md)、[tests.md](https://github.com/mattpocock/skills/blob/4588b32ecab9ecc9fc8cc6b6c5e7d675b6004b0d/skills/engineering/tdd/tests.md)。

仓库 [check-sources.ps1](../../scripts/check-sources.ps1) 只检查清单中原路径的 SKILL.md，不发现新增技能、辅助文件或改名目标；本次因此另行读取完整 Git 树与提交历史。其两个 404 应在人工决定保留、移除或改名后处理，不能自动替换本地适配内容。

上游现在也提供 Codex `agents/openai.yaml`，但本地早已为收录技能增加中文 UI 元数据、`default_prompt` 和调用策略。不能把上游英文元数据直接覆盖本地版本；若以后采纳，需同步审阅名称、source_path、调用策略、调用用例和从新英文源文件生成的翻译契约。[本地适配记录](../../THIRD_PARTY_NOTICES.md)、[维护约束](../../AGENTS.md)

## 更新前比较阶段的验证和产物

- `scripts/verify.ps1`：通过，验证现有 28 个技能、2 个来源及元数据、调用策略、链接、调用用例和脚本。
- `scripts/check-sources.ps1 -Source mattpocock-skills -Detailed`：已运行，`unchanged=1, updates=19, errors=2`，退出码 1；两个 error 已由改名及主动移除解释，不能报告为来源检查通过。
- 精确来源核对：22 / 22 个 SKILL.md 原始文件哈希匹配；22 / 22 个技能正文契约、21 / 21 个配套 Markdown 契约与参考树匹配。
- `git diff --check`：通过；新报告另行检查，83 个来源及本地链接全部有效，无尾随空白。

最初比较阶段只新增本研究笔记；已有项目技能、来源清单、调用用例及工作区原有的 YAML 修改保持原状，未安装或提交。

## 后续采纳（2026-10-06）

用户确认同步已收录技能的变化、改名和移除，并另外选择引入 `implement-spec`、`retro`、`pr`、`wait-what`。
本集合现为 31 个技能，其中 25 个来自本来源、6 个自编。来源基线更新至上述审阅提交；
23 项采用源语言翻译契约，`ask-matt` 的本地路由和 `wait-what` 的中文语言要求明确标记为行为适配。
`wizard` 与 `to-questionnaire` 未引入。

新增四项的关联与调用策略见 [README](../../README.md)，改造范围见 [第三方说明](../../THIRD_PARTY_NOTICES.md)。
原有工作区 UI 名称修改保留；被移除技能的工作区版本已在仓库外备份。
项目同步不执行用户目录安装或 Git 提交。

本次同步验证结果：

- `scripts/verify.ps1`：通过，31 个技能、2 个来源，覆盖元数据、调用策略、链接、调用用例和脚本语法。
- `scripts/check-sources.ps1 -Source mattpocock-skills -Detailed`：通过，`unchanged=25, updates=0, errors=0`。
- 翻译来源核对：23 个技能正文与 22 个参考文件的契约哈希，全部匹配该提交的英文 UTF-8/LF 原始文件。
- 修复契约生成脚本的分类路径分隔符问题，完整参考文件名不再被截断；诊断 Bash 模板通过 `bash -n`。
- `git diff --check`：通过。原有 26 个保留技能的 UI 名称未改变，不相关 YAML 内容保持原始字节。

用户目录中的旧 `writing-great-skills`、`resolving-merge-conflicts` Junction 指向已移除路径。
本次未运行安装，后续若要求安装，应按项目流程说明全量影响并同步用户目录链接。
