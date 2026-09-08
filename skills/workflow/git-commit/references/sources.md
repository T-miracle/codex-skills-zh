# 来源与适配记录

本 Skill 为本仓库自编内容，`source_id: local`、`translation_contract: false`。没有复制外部 Skill，不设置外部 Skill 哈希或翻译契约。

2026-09-08 用户要求先分析项目主要自然语言，再以该语言描述提交信息；语言推断优先采用提交历史和项目文档证据，协议词保持原文。

需求来自用户指定的 ChatGPT 对话“GitHub 提交规范”（对话 ID：`68e85b65-601c-8323-bd40-45a8bdeda498`），于 2026-09-07 读取全部三轮。提炼范围：提交类型与字段、破坏性变更、仅版本变化的 `chore(release)`、`npm version` 自动提交和 tag。

同日核对的一手资料：

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)：核对字段、可选 scope、`!`、footer 和类型边界。它是可选择的团队约定，不是 GitHub 强制标准。
- [npm version，CLI v11 文档](https://docs.npmjs.com/cli/v11/commands/npm-version/)：核对 `%s`、`git-tag-version`、生命周期脚本及执行顺序；实际操作需结合项目 npm 版本。
- [semantic-release/git](https://github.com/semantic-release/git)：核对发布资产提交由插件与配置控制。

本地行为设计增加了 diff 取证、index 范围、原子拆分、授权分支、失败后核对及完成标准；修正原对话中“自动发版必然生成版本提交”和“amend 即可完成版本提交修复”的过度概括。提交类型表是默认实践，仓库明确规则优先。

2026-09-07 经本地访谈确认提交拆分策略：功能的未提交边界、BUG 根因分组、配套修改的必要性判断、共享依赖顺序、同行重叠的最小合并例外、逐提交状态验证，以及仅在归属或范围存在实质歧义时展示方案并等待确认。这些是用户选择的工作流，不是 Conventional Commits 的强制规定。
