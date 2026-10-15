# Third-Party Notices

本文件记录当前集合实际收录的外部内容。自编内容适用本仓库的 [`LICENSE`](LICENSE)。
引入其他来源时，应增加来源记录并保存许可证或其他必要授权说明。

## mattpocock/skills

当前集合中的 25 个外部 Skill 选自 [`mattpocock/skills`](https://github.com/mattpocock/skills)。
2026-10-15 审阅并采纳已收录技能及其配套文件在 `main` 的提交
[`49dd158d1076134a641b33efb035946536778336`](https://github.com/mattpocock/skills/commit/49dd158d1076134a641b33efb035946536778336)。
对应路径和精确原始字节哈希见 [`config/skills.json`](config/skills.json)。原项目由 Matt Pocock
于 2026 年以 MIT License 发布。

本地修改范围：

- 技能描述、正文和配套 Markdown 以中文为主，保留英文触发词和行为锚点；
- 增加中文 `agents/openai.yaml` 元数据、默认提示及与上游调用方式对应的隐式调用策略；
- 保留固定模板、代码、命令、标签和链接目标，从审阅过的英文 UTF-8/LF 原始文件生成翻译契约；
- 增加安装、验证、来源检查、调用用例和中文维护文档；
- 初次引入使用本机快照；2026-10-06 改为明确的 GitHub 提交基线，合入词汇表改名、分轮追问、
  可分享逻辑原型、架构扫描范围、脱敏和显式技能加载等上游变化；
- `writing-great-skills` 改名为 `writing-for-agents`，扩展至所有智能体文档并允许隐式调用；
  移除上游已删除的 `resolving-merge-conflicts`；
- 新增 `implement-spec`、`retro`、`pr`、`wait-what`。`pr` 保留上游对 Humanlayer / Dex Horthy
  的 `show-me` 写作方法署名与链接，见 [CREDITS.md](skills/workflow/pr/CREDITS.md)；
- `ask-matt` 按实际收录技能重组路由，包含新增四项和本地工作流，未推荐尚未收录的
  `wizard`、`to-questionnaire`；`wait-what` 按对话语言重述，中文使用简明中文，英文保留
  ASD-STE100 Simplified Technical English。这两项是本地行为适配，
  `translation_contract` 为 `false`，不伪造忠实翻译契约；
- `to-tickets` 由用户选择场景拆分或细粒度垂直切片；未明确选择时先询问并等待，
  选择仅在本次规划内沿用，允许主动切换。场景模式增加继续拆分的依据与停止条件；
  两种模式共用局部预重构并入工单、广域重构扩展—收缩、验收与验证映射、风险及回归
  覆盖和集成验证归属，保留现有执行技能的测试门禁。这是本地行为适配，
  `translation_contract` 为 `false`，移除其翻译契约，保留可追溯的上游来源和审阅基线；
- 2026-10-15 合入 11 个技能入口及 setup 的 3 个配套文件更新，包括工单引用读取、
  阻塞边与父子关系分离、测试接缝覆盖取舍、调研标签与分支规则、tracker 命令和标签创建。
  `ask-matt` 的路由说明同步指向本地 `to-tickets` 双模式；后者允许建立子议题关联，
  同时保留父议题其他内容与状态。未引入上游分发流程、维护政策或未收录技能。

完整许可证见 [`THIRD_PARTY_LICENSES/mattpocock-skills-LICENSE`](THIRD_PARTY_LICENSES/mattpocock-skills-LICENSE)。
历史采纳记录见 [10 月 6 日调查](docs/research/mattpocock-skills-upstream-2026-10-06.md)，
本次比较及采纳记录见 [10 月 15 日调查](docs/research/mattpocock-skills-upstream-2026-10-15.md)。
