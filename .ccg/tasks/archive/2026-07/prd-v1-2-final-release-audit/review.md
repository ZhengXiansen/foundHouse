# PRD v1.2 最终发布审计复审记录

## 复审范围

- `.ccg/tasks/prd-v1-2-final-release-audit/requirements.md`
- `found-house-app/docs/qa/v1.2-final-release-audit-2026-07-07.md`
- `found-house-app/docs/qa/v1.2-test-cases.md`
- `found-house-app/docs/qa/v1.2-release-manual-checklist.md`

## CCG 双模型复审执行

- Antigravity：已按 CCG 要求并行调用，但 backend 不可用，stderr 为 `agy command not found in PATH`，无有效审查输出。
- Claude：复审完成，Session-ID `346e29b0-dc3c-49c7-92db-927a1cc9832e`。

日志文件：

- `claude-review.out.txt`
- `claude-review.err.txt`
- `antigravity-review.err.txt`
- `review-prompts/`

## Claude 复审结论摘要

### Critical

无。

### Important / 建议

1. APK 大小在报告中同时使用 `67,778,694 bytes` 与 `(64.6MB)`，语义自洽但建议统一口径，避免误读。
2. 自动化运行时数字来自执行轮次；最终 reviewer 是只读复审，建议在报告中明确审计边界。

### Minor / 建议

1. `integration_test/v1_1_formal_device_flow_test.dart` 历史文件名含 `v1_1`，但语义为 v1.2 补充覆盖；建议在报告中说明，或后续重命名。
2. `v1.2-release-manual-checklist.md` 仍为空白签署模板，当前仅能作为内部测试发布依据；对外正式发布前必须补齐人工签署。

## 已处理复审建议

已更新 `found-house-app/docs/qa/v1.2-final-release-audit-2026-07-07.md`：

- 统一 APK 大小表述为 `≈64.6 MiB (67,778,694 bytes)`。
- 增加复审说明：运行时数字来自本轮发布审计执行日志；最终 reviewer 只读核对文档、APK 元数据与测试覆盖范围；复审后又补跑了一轮关键命令，日志保存到任务目录。
- 在 v1.2 补充真机覆盖行注明 `v1_1_formal_device_flow_test.dart` 是历史文件名，当前脚本覆盖 v1.2 补充场景。

## 发布审计判断

- 对“App 内核心闭环 + 当前 release APK + 当前真机自动化验证”而言：可作为内部测试发布依据。
- 对“全部系统权限 / 相机相册 / 旧版覆盖安装 / 多设备权限弹窗人工签署”而言：仍未完全执行，不应直接作为对外正式发布签署依据。

## 复审后补跑验证（2026-07-07 10:08 起）

日志目录：`.ccg/tasks/prd-v1-2-final-release-audit/verification-20260707-100849/`。

关键结果：

- `flutter analyze` → `No issues found!`，ExitCode 0。
- `flutter test test/data/village_repository_test.dart --reporter expanded` → `+9 All tests passed!`，ExitCode 0。
- `flutter test test/features/scan_map_page_test.dart --reporter expanded` → `+14 All tests passed!`，ExitCode 0。
- `flutter test --reporter expanded` → `+158 All tests passed!`，ExitCode 0。
- `flutter build apk --release` → `Built build\app\outputs\flutter-apk\app-release.apk (64.6MB)`，ExitCode 0；APK `67,778,694 bytes`，LastWriteTime `2026-07-07 10:09:34`。
- `flutter test -d e4e6ad3a integration_test/full_device_flow_test.dart --reporter expanded` → `All tests passed!`，ExitCode 0。
- `flutter test -d e4e6ad3a integration_test/v1_1_formal_device_flow_test.dart --reporter expanded` → 首次遇到一次 `INSTALL_FAILED_USER_RESTRICTED`，重试后 `All tests passed!`，ExitCode 0。
- 最终正式包安装：`adb -s e4e6ad3a install -r build\app\outputs\flutter-apk\app-release.apk` → `Success`，ExitCode 0。
- `dumpsys package com.zheng.foundhouse` → `versionName=1.0.0`，`versionCode=1`，`lastUpdateTime=2026-07-07 10:13:44`。
- 启动验证：`topResumedActivity=... com.zheng.foundhouse/.MainActivity`，`mCurrentFocus=... com.zheng.foundhouse/com.zheng.foundhouse.MainActivity`。
- UI dump：包含 `首页`、`新增村`、`还没有村`、`按村扫楼，离线记录楼栋和房源`、底部 Tab `首页 / 房源 / 对比 / 我的`；不包含 `扫楼地图`、`定位`、`第三方`、`API`、`BFF`、`地图失败`。
