# MISSION.md 格式

`MISSION.md` 位于工作区根目录，用来记录用户学习该主题的_原因_。每一项教学决策——接下来教什么、提供哪些资源、设计哪些练习——都应追溯到此文档。

## 模板（Template）

```md
# Mission: {Topic}

## Why
{1-3 sentences. The concrete real-world goal the user is chasing. What changes in their life or work when they have this skill? Avoid abstract framings like "to understand X" — push for the underlying outcome.}

## Success looks like
- {A specific, observable thing the user will be able to do}
- {Another specific thing}
- {…}

## Constraints
- {Time, budget, prior commitments, learning preferences, anything that bounds the approach}

## Out of scope
- {Adjacent topics the user explicitly does not want to chase right now — protects the zone of proximal development}
```

## 规则（Rules）

- **一个工作区只对应一项使命。** 如果用户想学习两件互不相关的事，就应使用两个工作区。
- **具体胜于抽象。** “十月前跑完半程马拉松”优于“变得更健康”；“向团队交付一个 Rust CLI”优于“学习 Rust”。
- **追问含糊表述。** 如果用户说不清原因，先访谈再落笔。糟糕的使命还不如没有使命。
- **现实变化时及时修订。** 使命会改变。用户的目标转移时，应更新此文件——不要让过时的使命继续引导后续会话。
- **保持简短。** 如果 `MISSION.md` 超过一屏，它就不再是指南针，而开始变成计划。
