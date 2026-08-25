---
name: usage-disclosure
description: "在回复中实际使用了其他 Skill 或插件时，于正文前简短披露其名称（usage disclosure）。"
---

当本轮回复实际使用了一个或多个其他 Skill 或插件时，在任何正式内容前输出紧凑的披露区：

```md
> &lbrack;<skill-name>&rbrack;(/<对应 SKILL.md 的绝对路径>) [插件: <plugin-name>]
```

- 只列出本轮实际使用的 Skill 和插件；不要列出内置工具。
- 每个 Skill 标签必须使用 Markdown 链接，链接到该 Skill 的 `SKILL.md` 绝对路径；链接文本仅显示 Skill 名称，不加 `Skill:` 前缀。
- Windows 路径必须改为正斜杠，并在盘符前加 `/`；不得输出 `C:\...` 格式。路径包含空格时，用尖括号包裹链接目标。
- 不要把本 Skill `usage-disclosure` 自身列入标签。
- 标签保持单行优先；空间不足时自然换行，不要为对齐刻意拆行。
- 若未使用任何其他 Skill 或插件，不输出披露区。
- 标签后的正式回复遵循任务本身所需的语言、格式和内容；不要为披露区额外解释。
