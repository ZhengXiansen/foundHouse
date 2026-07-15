# 需求：重写 Git 历史并强制推送

## 目标

从 `main` 的所有可达历史提交中彻底移除当前 `.gitignore` 命中的本地工具、生成物和 CCG 非持久化产物，并将重写后的 `main` 安全推送到 `origin`。

## 必须清理

- `.aeroric/**`
- `.agents/**`
- `.claude/**`
- `.impeccable.md`
- `img/**`
- `found-house-app/.screenshots/**`
- `.ccg/tasks/**` 中不属于持久化白名单的文件

## 必须保留

- `.ccg/spec/**`
- `.ccg/tasks/**/task.json`
- `.ccg/tasks/**/requirements.md`
- `.ccg/tasks/**/plan.md`
- `.ccg/tasks/**/review.md`
- `.ccg/tasks/**/context.jsonl`
- 当前源码、测试、锁文件、配置、设计资料、许可证和治理文档

## 安全约束

- 重写前创建并验证仓库外 Git bundle。
- 未跟踪的当前任务目录单独备份。
- 使用逐历史文件生成的精确 literal 路径清单，禁止整体删除 `.ccg` 或 `.ccg/tasks`。
- 删除清单预期为 811 个路径，与 CCG 白名单交集必须为 0。
- 在全新旁路 clone 中运行 `git-filter-repo`，不直接重写原工作仓库。
- 过滤前后当前 tip tree 必须一致；新增任务归档提交除外。
- 只推送 `main`，使用带旧远端 OID 的显式 `--force-with-lease`，禁止裸 `--force`。
- 推送前后均核对远端 OID，并从远端全新 clone 复验。

## 验收标准

1. 重写后的历史中 811 个待删除路径全部不可达。
2. 历史中当前 `.gitignore` 命中数为 0。
3. 历史 CCG 白名单集合完整保留。
4. `git fsck --full` 通过，当前索引无被忽略的已跟踪文件。
5. BFF lint/test/build 与 Flutter analyze/test 通过。
6. 双模型审查无 Critical 问题。
7. `origin/main` 指向重写并包含任务归档提交的新提交。
