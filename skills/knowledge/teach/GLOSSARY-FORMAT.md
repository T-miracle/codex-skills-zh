# GLOSSARY.md 格式

`GLOSSARY.md` 是此教学工作区的规范语言。所有讲解、练习和学习记录都应遵循其中的术语。构建术语表本身也是学习的一部分：能把概念压缩成严谨定义，正是用户已经理解它的证据。

## 结构（Structure）

```md
# {Topic} Glossary

{One or two sentence description of the topic this glossary covers.}

## Terms

**Hypertrophy**:
Muscle growth driven by mechanical tension and metabolic stress over repeated training sessions.
_Avoid_: Bulking, getting big

**Progressive overload**:
Systematically increasing the demand on a muscle over time — via load, volume, or intensity.
_Avoid_: Pushing harder, levelling up

**RPE (Rate of Perceived Exertion)**:
A 1–10 self-rating of how hard a set felt, where 10 is failure and 8 means two reps left in the tank.
_Avoid_: Effort score, intensity rating
```

## 规则（Rules）

- **只有用户理解后才添加术语。** 术语表是压缩知识的记录，不是供用户从头学习的词典。如果用户刚接触某个概念，应等到他们能正确使用后，再把它提升为正式条目。
- **做出明确取舍。** 同一概念存在多个说法时，选择最合适的一个，并把其余说法列为应避免的别名。这正是语言实现压缩的方式。
- **保持定义紧凑。** 限一到两句话。定义术语“是什么”，而不是它“做什么”或“怎么做”。
- **在定义中使用术语表已有术语。** 一个术语进入术语表后，应在所有地方优先使用——包括其他定义内部。这会让后续复杂术语更容易理解。
- **出现自然聚类时按子标题分组**（例如 `## Anatomy`、`## Programming`）。如果所有术语本就属于一个紧密领域，使用扁平列表也可以。
- **明确标记歧义。** 如果某个术语在更广泛的领域中用法松散，应记录这里的裁定：“在此工作区中，‘组（set）’始终指工作组——热身组另行跟踪。”
- **随着理解加深而修订。** 用户第一周写下的定义，到第六周可能已不正确。直接就地更新，不要保留过时条目。
