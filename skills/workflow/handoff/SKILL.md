---
name: handoff
description: "将当前对话压缩为 handoff 文档，供另一个 agent 接手。"
---

编写一份概括当前对话的交接文档（handoff document），使一个全新的智能体（fresh agent）能够继续这项工作。将文档保存到用户操作系统的临时目录，而不是当前工作区。

在文档中加入“建议技能”章节，推荐该智能体应当调用的技能。

不要重复其他制品（artifacts，例如规格、计划、ADR、议题、提交、差异）中已经记录的内容。改为通过路径或 URL 引用它们。

删去（redact）所有敏感信息，例如 API 密钥、密码或个人身份信息（personally identifiable information）。

如果用户传入了参数，将其视为下一次会话重点的描述，并据此调整文档。
