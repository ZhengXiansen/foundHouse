# 审查报告

## 范围

审查 `main` 的全历史路径过滤、保留文件完整性、refs、恢复备份、项目验证以及强制推送安全条件。

## 双模型审查

使用 `gpt-5.6-sol` 与 `gpt-5.6-terra` 独立只读审查并交叉核对。

### Critical

- 无历史重写正确性 Critical 问题。
- 推送前条件：必须实时确认远端 `main` 仍为旧 OID，并使用显式 OID 的 `--force-with-lease`。

### Warning

- 初始提交原有 GPG 签名在历史重写后不再有效，这是重写提交的预期结果。
- `git-filter-repo` 已按设计移除旁路仓库的 `origin`；推送时仅使用明确 GitHub URL/单一 main refspec，不 fetch 旧历史。
- force push 只能让旧提交不再由公开 `main` 可达，不能保证 GitHub 缓存、隐藏 refs、fork 或旧 clone 立即物理删除。
- 采用两阶段闭环：先提交活动任务审查记录并强推；远端 fresh clone 验证成功后，再标记 completed、归档并普通 fast-forward 推送。

## 重写证据

- 旧远端/本地 `main`：`8e05e49450cca5d9e98e420fe8efe7a704ceb01f`
- 重写后基础 HEAD：`10840dcbb38139e85330beb5bb8183d06e95d4cb`
- 过滤前后 tip tree：`0cef6f3d636a810409dbde5db343bdb91a9d9a9d`（一致）
- 提交数：5 → 5
- 历史唯一路径：1116 → 305
- 精确 literal 删除路径：811
- 删除路径残留：0
- 当前 `.gitignore` 历史命中：0
- CCG 保留路径：140，缺失 0
- 删除与保留清单交集：0
- refs：仅 `refs/heads/main`
- `git fsck --full --strict`：通过
- `git ls-files -ci --exclude-standard`：0

## 恢复备份

- Bundle：`C:\tmp\foundHouse-before-history-rewrite-20260715.bundle`
- 大小：12,561,424 bytes
- `git bundle verify`：完整历史、通过
- bundle 镜像恢复测试及 `git fsck --full`：通过

## 项目验证

- BFF `npm run lint`：通过
- BFF `npm test`：4 files / 28 tests 通过
- BFF `npm run build`：通过
- Flutter `flutter analyze`：No issues found
- Flutter `flutter test`：188 tests 通过

## 推送门禁

推送前必须：

1. `git ls-remote` 确认 GitHub `refs/heads/main` 仍为旧 OID。
2. dry-run 与正式推送使用相同 URL、refspec 和显式 lease。
3. 仅推 `HEAD:refs/heads/main`，禁止 `--force`、`--mirror` 或 `--all`。
4. 推送后从 GitHub fresh clone，复验 HEAD、历史命中、保留路径、refs 和 fsck。

## 当前结论

历史重写、备份和本地验证通过；可进入活动任务 checkpoint 提交及显式 `--force-with-lease` 推送。最终远端验证与任务归档待推送后完成。
