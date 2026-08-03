# Third-Party Notices

本文件只记录当前集合实际收录的外部内容，并按来源分别维护。自行编写的内容适用
本仓库的 [`LICENSE`](LICENSE)，不在这里重复列出。以后从其他仓库引入 Skill 时，
应新增对应来源小节，并保存其许可证或其他必要的授权说明。

## mattpocock/skills

当前集合中的一组已本地化 Skill 选自
[`mattpocock/skills`](https://github.com/mattpocock/skills) 的本地安装快照；
具体关联关系记录在 [`config/skills.json`](config/skills.json) 中。
原始项目由 Matt Pocock 于 2026 年以 MIT License 发布。

引入本集合后所做的主要修改包括：

- 将技能 `description` 改为中文主描述并保留英文关键触发词；
- 将技能指令正文和配套 Markdown 参考文档翻译为中文，并保留关键英文行为锚点；
- 为 Codex 增加 `agents/openai.yaml` UI 元数据和隐式调用策略；
- 增加安装、翻译契约验证、来源检查、测试与中文文档；
- 初次翻译以经过审阅的本机安装快照为源语言基线。

该来源的完整许可证见
[`THIRD_PARTY_LICENSES/mattpocock-skills-LICENSE`](THIRD_PARTY_LICENSES/mattpocock-skills-LICENSE)。
