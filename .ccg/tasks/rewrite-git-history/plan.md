# 实施计划

1. 核对本地/远端 main、refs 和 tags，记录旧远端 OID 与 tip tree。
2. 创建并验证仓库外 bundle，单独备份未跟踪任务目录。
3. 使用 NUL-safe Python 子进程枚举所有 commit tree，按当前 `.gitignore` 生成 811 条精确 literal 删除路径，并校验 CCG 白名单交集为 0。
4. 创建 `--no-local` 全新旁路 clone，运行 `git-filter-repo --invert-paths --paths-from-file`。
5. 验证 tip tree、历史路径集合、CCG 白名单、refs、fsck 和当前索引。
6. 将当前 CCG 任务目录复制到重写 clone，运行项目验证并完成双模型审查。
7. 写入 review.md，更新 task.json 为 completed，移动到 `archive/2026-07` 并提交归档。
8. 推送前用 `git ls-remote` 核对旧远端 OID，先 dry-run，再使用显式 OID 的 `--force-with-lease` 只推 main。
9. 从 GitHub 全新 clone 复验历史与 HEAD；最后让原工作仓库对齐重写后的 origin/main，保留本地 ignored 文件。
