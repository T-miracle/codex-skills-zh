# 版本提交

## 仅版本变化

确认 diff 中只有版本元数据及一致更新的锁文件等发布资产时，默认写为：

```text
chore(release): bump version to 1.2.3
```

版本号从实际内容读取。若还包含功能或修复，先按目的拆分，不因准备上线而把业务变更统称为 `chore(release)`。

## npm version

运行前检查当前 npm 版本、版本文件、工作区、`.npmrc` 的相关选项，以及 `package.json` 中的 `preversion`、`version`、`postversion` 和它们调用的脚本。生命周期脚本可能暂存其他文件、推送或发布；授权范围必须覆盖实际副作用。

根据用户意图选择一种方式，以下为命令示例而非执行授权：

| 用户意图 | 方式 | 核对事项 |
| --- | --- | --- |
| 已授权升级版本、创建提交和 tag | `npm version patch -m "chore(release): bump version to %s"` | `%s` 是结果版本；默认 Git 集成会创建提交和 tag |
| 仅修改版本文件，后续审阅再提交 | `npm version patch --no-git-tag-version` | 禁止 npm 自带提交和 tag，但生命周期脚本仍需审阅 |
| 只需要提交信息 | 输出与实际目标版本一致的草稿 | 不运行版本命令 |

遵循仓库现有发布工具与 workspace 规则；用户指定精确版本或 minor/major 时采用该目标，不固定使用 patch。运行后核对版本文件、HEAD、tag 和工作区；已有版本提交时不再手工重复 commit。

若命令失败，先确认文件、提交及 tag 已进行到哪一步，再恢复；不要直接重跑递增版本的命令或用 `--force` 绕过脏工作区。

## 已有版本提交或自动发版

- 用户要求修正最后一次信息时，先检查该提交内容、是否已共享以及关联 tag。amend 会更换提交对象，已有 tag 不会自动跟随；只有历史修改及相关 tag 处理已获授权时才执行。不能为补规范擅自强推。
- 使用 semantic-release 等工具时读取实际 release 配置、插件和 CI。是否写回版本文件、生成 release commit 由配置决定；仅安装 semantic-release 不代表一定产生 `chore(release)` 提交。
- `feat`、`fix` 和破坏性标记可用于版本推导，但实际发布结果取决于发布工具规则及待发布的整组提交。写了 `chore(release)` 既不等于执行发布，也不能单独证明应升 patch。

完成标准：信息匹配实际版本；若执行过操作，文件、提交和 tag 状态均已核对；已有发布流程和授权范围得到遵守。
