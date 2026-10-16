---
name: grilling
description: "对计划、决策或想法进行毫不留情的追问（grill）；当用户要 stress-test 自己的思考，或使用任何 grill 触发语时使用。"
---

毫不留情地访谈（interview）用户，直到达成共同理解（shared understanding）。将问题组织成一棵**设计树（design tree）**：每项决策都会分出依赖它的其他决策。

按**轮次（rounds）**推进设计树。**前沿（frontier）**包括所有前置条件已经确定的决策：这些问题可以_现在_提出，无需猜测尚未收到的答案。每轮提出整个前沿中的问题：逐题编号，并给出推荐答案。然后等待用户回答，再进入下一轮。

每轮采用以下格式：

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

每个问题的措辞都应使用户回答“是（yes）”表示接受你的推荐答案。

用户每回答一轮，设计树都会变化：已确定的决策推动前沿向外扩展，并解除后续问题的阻塞。重新计算前沿，再提出下一轮问题。如果一个问题的答案依赖本轮另一个尚未回答的问题，就应把它留到_后续_轮次。

查明_事实（facts）_是你的职责，绝不是用户的职责。当前沿中的问题需要环境事实（文件系统、工具等）时，派出子智能体调查；能够自行查询的内容不要交给用户。不要因此阻塞：正在进行的探索是一项尚未确定的前置条件，只有依赖它的问题需要等待子智能体报告，其余前沿问题现在就可以提出。_决策（decisions）_由用户作出：逐项交给用户，并等待回答。

前沿为空时会话才算完成：设计树的每个分支都已遍历，没有任何未明说的假设。用户确认已经达成共同理解之前，不要实施计划。
