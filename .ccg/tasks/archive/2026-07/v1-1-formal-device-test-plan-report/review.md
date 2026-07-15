# Review — v1.1 formal QA docs and Android device tests

## Scope reviewed

变更范围：

- `found-house-app/docs/qa/v1.1-formal-test-prompt.md`
- `found-house-app/docs/qa/v1.1-test-cases.md`
- `found-house-app/docs/qa/v1.1-android-device-test-report.md`
- `found-house-app/integration_test/v1_1_formal_device_flow_test.dart`
- `found-house-app/integration_test/full_device_flow_test.dart`
- `.ccg/tasks/v1-1-formal-device-test-plan-report/*`

## External dual-model review status

CCG 要求 L+ 任务进行 antigravity + Claude 双模型分析/审查。但本机 required wrapper 缺失：

```text
MISSING C:/Users/Mr.Zheng/.claude/bin/codeagent-wrapper
MISSING C:\Users\Mr.Zheng\.claude\bin\codeagent-wrapper
```

因此未伪造外部双模型审查。本 review 为本地自查 + 命令验证结果。

## Local review checklist

| 项 | 结果 | 说明 |
| --- | --- | --- |
| 需求提示词 | PASS | 明确测试目标、范围、维度、证据、通过标准 |
| 测试用例矩阵 | PASS | 覆盖 Smoke、首页/村、楼栋、快速记录、房源、Checklist、风险、对比、设置、隐私、设备、旧地图回归 |
| 真机报告 | PASS | 记录设备、命令、结果、覆盖、未自动化系统 UI、结论 |
| 自动化补充脚本 | PASS | 覆盖缺失村负向、多村、多入口、6 楼栋状态、村筛选、对比不足、旧地图回归 |
| 旧 golden path | PASS | 修复真机 route replacement 退出动画误报，仍覆盖 P0 主链路 |
| 主流程地图下线 | PASS | 新脚本与报告均断言主路径不出现旧地图/定位文案 |
| 数据归属 | PASS | 自动断言 `villageId` 必填、`buildingId` 根据入口正确写入 |
| 手工边界 | PASS | 相机/相册/系统分享明确列为 Manual-System NOT RUN，未冒充自动化通过 |

## Verification evidence

已重新执行并通过：

```text
flutter analyze
No issues found! (ran in 3.2s)

flutter test --reporter expanded test/features/scan_map_page_test.dart
+4: All tests passed!

flutter test
+144: All tests passed!

flutter test -d e4e6ad3a integration_test/full_device_flow_test.dart
+1: All tests passed!

flutter test -d e4e6ad3a integration_test/v1_1_formal_device_flow_test.dart
+1: All tests passed!
```

## Findings

### Critical

- None.

### Warning

- Manual-System 用例（拍照、相册、系统分享）未在本轮自动化中执行；报告已标注为发布前人工补测项。
- 根目录不是 Git repo，任务归档无法按 CCG 要求提交 commit；归档动作仍可执行，commit 需用户在实际仓库策略下处理。

### Info

- 底层地图代码保留符合 PRD v1.1 Phase 2 分阶段下线策略；本轮只验证用户主流程不暴露/不依赖。
- `found-house-app` 仓库当前大量文件为 untracked 状态，不应在本任务中清理或删除。
