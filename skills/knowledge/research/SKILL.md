---
name: research
description: "针对问题调查高可信 primary sources，并将带引用的结果写入仓库 Markdown 文件；当用户要求 research、收集文档或 API 事实，或将阅读工作委派给 background agent 时使用。"
---

启动一个**后台智能体（background agent）**开展调研，这样它在阅读资料时你仍可继续工作。

它的任务：

1. 依据**一手来源（primary sources）**调查问题——包括官方文档、源代码、规格和第一方 API（first-party APIs）——而不是依据对它们的二手解读。每一项主张都要追溯到对其负责的原始来源。
2. 将调查结果写入一个 Markdown 文件，并为每一项主张标注来源。
3. 将文件保存到仓库现有的此类笔记目录中并遵循既有约定；如果没有约定，就放在合理的位置并说明保存位置。
