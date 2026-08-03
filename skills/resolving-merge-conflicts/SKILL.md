---
name: resolving-merge-conflicts
description: "解决正在进行的 Git merge/rebase conflict 时使用。"
---

1. **查看合并或变基（merge/rebase）的当前状态**。检查 Git 历史和发生冲突的文件。

2. **查找每项冲突的一手来源（primary sources）**。深入理解每项变更为何产生以及其原始意图。阅读提交消息，查看 PR，并检查原始议题或工单。

3. **解决每一个冲突块（hunk）。**尽可能保留双方意图。无法兼容时，选择符合本次合并既定目标的一方，并说明权衡。**不要**发明新行为（behaviour）。始终解决冲突；绝不使用 `--abort`。

4. 找出并运行项目的**自动化检查（automated checks）**——通常依次为类型检查（typecheck）、测试（tests）和格式化（format）。修复合并导致的所有问题。

5. **完成合并或变基。**暂存（stage）所有内容并提交（commit）。如果正在变基，继续变基过程，直到所有提交都完成变基。
