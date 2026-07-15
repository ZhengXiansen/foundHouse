# fix-review-dev-execution-plan 收尾审查

审查时间：2026-07-04 01:18:17 +0800  
任务：`.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan`  
范围：对照本任务 `requirements.md` / `plan.md`，复核此前 `review-dev-execution-plan` 报告中的缺口是否已修复，并记录最终质量门禁与 CCG 双模型审查尝试结果。

## 结论

本地实现审查与质量门禁未发现阻塞项。`requirements.md` 中 Must Fix 均已有当前代码与测试证据支撑；Should Fix 的 PDF 中文字体风险也已通过可用字体加载与测试覆盖处理。

CCG 双模型审查已按要求重新尝试，但外部审查基础设施未返回可用报告：antigravity 后端因 `agy command not found in PATH` 失败，Claude 后端 600 秒超时且无输出。按 `plan.md` Final 第 2 项，本报告记录该基础设施失败，并以本地静态审查 + 新鲜质量门禁结果作为收尾证据。

## 质量门禁

| 命令 | 结果 | 日志 |
| --- | --- | --- |
| `flutter analyze` | Exit 0 | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/verification/flutter-analyze.log` |
| `flutter test` | Exit 0 | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/verification/flutter-test.log` |
| `npm test` | Exit 0 | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/verification/npm-test.log` |
| `npm run build` | Exit 0 | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/verification/npm-build.log` |
| `npm run lint` | Exit 0 | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/verification/npm-lint.log` |

所有质量门禁 exit code 均为 0。

## CCG 双模型审查尝试

| 后端 | 结果 | stdout | stderr |
| --- | --- | --- | --- |
| antigravity | State=Completed; TimedOut=false | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/model-review/antigravity-review.log` | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/model-review/antigravity-review.err.log` |
| claude | State=TimedOut; TimedOut=true | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/model-review/claude-review.log` | `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/model-review/claude-review.err.log` |

补充说明：

- `antigravity-review.err.log` 记录 wrapper 启动后调用 `agy --add-dir ...`，失败原因为 `agy command not found in PATH`。
- `claude-review.log` 与 `claude-review.err.log` 均为空；PowerShell job 在 600 秒超时后结束，未得到可用 Claude 审查报告。随后复查未发现残留 `codeagent-wrapper` / `claude` / `agy` 进程。

## Requirements 完成度

| 要求 | 状态 | 证据 |
| --- | --- | --- |
| C1/F7：生产 repository path 敏感字段密文落库，不再默认 Noop | 已满足 | `found-house-app/lib/data/providers.dart` 默认 `fieldCipherProvider` 返回 `CryptoFieldCipher`；`found-house-app/lib/data/crypto/field_cipher.dart` 为密文增加 `fh:v1:` 前缀并调用 `CryptoService`；`found-house-app/lib/data/repositories/house_repository.dart` 在 create/update/assemble 边界 await 加解密；`found-house-app/test/data/house_repository_test.dart` 覆盖 DB 密文不等于明文且领域层读回明文。 |
| C2/W3/F6：客户端地图不再是 placeholder，连接房源位置、POI/通勤摘要、本地 MapSnapshot | 已满足 | `found-house-app/lib/features/scan/scan_map_page.dart` 展示扫楼地图、定位房源、POI/通勤摘要与刷新入口；`found-house-app/lib/integrations/amap/amap_client.dart` 调用 BFF `/api/map/nearby-summary` 与 `/api/map/commute`；`found-house-app/lib/data/repositories/map_repository.dart` 刷新并写入 `MapSnapshot`；`test/features/scan_map_page_test.dart`、`test/integrations/amap/amap_client_test.dart`、`test/data/map_repository_test.dart` 覆盖。 |
| W1/F1/F2：水电有单价但无月费时仍计入默认月估值 | 已满足 | `found-house-app/lib/features/scoring/cost_calculator.dart` 始终计入默认水/电月估值，单价缺失只影响 missing flags；`test/scoring/cost_calculator_test.dart` 覆盖有单价场景仍计入 60/150。 |
| W2/F5：primary=true 目的地优先，未标 primary 时回退第一个目的地 | 已满足 | `found-house-app/lib/features/scoring/scoring_models.dart` 为通勤结果保留 `destinationId`；`commute_selector.dart` 先按 primary destination 过滤再按 mode 选择；`house_scoring_controller.dart` 从 `destinationsJson` 解析 primary 或 first id；`commute_selector_test.dart` 与 `house_scoring_controller_test.dart` 覆盖。 |
| W3：BFF 地图限流返回 MAP_RATE_LIMITED，Redis 可用时共享状态 | 已满足 | `found-house-bff/src/infra/rate-limit.ts` 为地图接口全局/设备限流抛出 `ErrorCode.MAP_RATE_LIMITED` 并接入 `getRedis()`；`src/infra/rate-limit.test.ts` 覆盖设备阈值、全局阈值与 Redis 多实例共享。 |
| W4：质量门禁通过或记录阻塞证据 | 已满足 | 本报告“质量门禁”表中 5 个要求命令均 exit 0；完整日志保存在 `verification/`。 |
| I1：PDF 使用中文字体或避免中文不可读输出 | 已满足 | `found-house-app/lib/features/compare/export_service.dart` 支持注入/本地/PdfGoogleFonts CJK 字体并校验可渲染中文；`test/features/export_service_test.dart` 覆盖配置中文字体后不输出缺字警告（在存在测试字体时执行）。 |

## Plan 分层完成度

- Layer 1 Deterministic Logic and Gates：已完成，质量门禁与对应单测通过。
- Layer 2 Encryption：已完成，默认 provider 使用 AES-GCM backed cipher，Noop 仅保留给测试/显式覆盖。
- Layer 3 Client Map：已完成，页面、BFF client、MapRepository 与测试均已落地。
- Layer 4 PDF：已完成，CJK 字体加载与测试已落地。
- Final：质量门禁已完成；双模型审查已尝试并记录基础设施失败；本文件为最终 review.md。归档已执行到 `.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/`。

## 风险/限制

- 外部模型审查未获得有效审查报告，这是当前环境基础设施限制，不是业务代码缺口。后续如果 `agy` 与 Claude wrapper 恢复，可重新运行 `model-review/*-prompt.txt`。
- 根目录 `D:\dev\code\foundHouse` 不是 git 仓库，`found-house-bff` 也不是 git 仓库；因此 CCG 归档要求中的 `git commit` 无法在根任务目录执行。

## 归档状态

- 已归档到：`.ccg/tasks/archive/2026-07/fix-review-dev-execution-plan/`
- `git commit` 未执行：工作区根目录不是 git 仓库，命令返回 `fatal: not a git repository (or any of the parent directories): .git`。
