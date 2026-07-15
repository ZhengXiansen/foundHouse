# Plan — v1.1 formal QA and Android device report

## Scope

围绕 `租房扫楼产品PRDv1.1.md` 的正式版验收，交付：

1. 优化后的测试需求提示词。
2. v1.1 正式版测试用例矩阵。
3. 可在 Android 真机执行的自动化集成测试补充。
4. 基于新鲜命令输出的测试报告。

## Constraints

- 当前事实源：根目录 `租房扫楼产品PRDv1.1.md`。
- 主流程不得回退到地图/定位/第三方地图 API。
- CCG 双模型 wrapper 当前不存在，不能伪造外部模型分析/审查。
- 系统 UI（相机、相册、系统分享面板）若 `flutter test` 无法稳定接管，则作为手工观察项单列，不把自动化通过伪装为已完成手工系统测试。

## Execution steps

1. 文档：在 `found-house-app/docs/qa/` 新增优化提示词、测试用例矩阵、测试报告。
2. 自动化：新增正式版补充真机脚本，覆盖缺失村入口、多村、多入口快速记录、楼栋状态、房源村筛选、对比不足选择等既有 golden path 以外的高价值场景。
3. 验证：运行 `adb devices -l`、`flutter devices`、`flutter analyze`、`flutter test`、`flutter test -d <device> integration_test/full_device_flow_test.dart`、`flutter test -d <device> integration_test/v1_1_formal_device_flow_test.dart`。
4. 报告：记录设备、命令、结果、缺陷、手工/自动化边界和发布结论。
5. 收尾：写 `review.md`，归档 `.ccg/tasks/v1-1-formal-device-test-plan-report/` 到 `.ccg/tasks/archive/2026-07/`；根目录非 Git repo 时记录无法提交归档。
