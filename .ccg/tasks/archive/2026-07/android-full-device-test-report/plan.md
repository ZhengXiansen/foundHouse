# Android 真机全流程测试执行计划

## 目标

基于 `test-cases.md`，在已连接 Android 真机 `f17804b` 上完成可自动化的主流程验证，并记录不可自动化/条件受限项，生成 `test-report.md`。

## 阶段 1：环境与基线

1. 确认 `.ccg/spec` 不存在或读取规范（已确认不存在）。
2. 确认设备：`flutter devices`、`adb devices -l`。
3. 运行静态分析：`flutter analyze`。
4. 运行现有单元/Widget 测试：`flutter test --reporter compact`。
5. 构建 Debug APK：`flutter build apk --debug`。
6. 安装并用 monkey 启动，采集 UIAutomator XML、截图、前台 Activity。

## 阶段 2：补充真机 integration_test

新增 `integration_test/full_device_flow_test.dart`，在真机上覆盖：

- 默认启动与底部 Tab。
- 快速记录：创建草稿、输入月租、选择房型、保存离开。
- 房源列表：展示卡片并进入详情。
- 房源详情：基础字段自动保存。
- Checklist：打开页面并记录至少一个检查项；补充风险标记后验证风险摘要。
- 偏好设置：保存预算/通勤目的地。
- 扫楼地图：有坐标房源显示「已定位」。
- 对比：选择两套房源，出现对比表与导出脱敏提示。

为避免污染用户真实数据，integration_test 使用内存 Drift 数据库与 `NoopFieldCipher` provider override；安装/启动 smoke 仍使用真实 APK。

## 阶段 3：真机执行

1. 清理 logcat：`adb -s f17804b logcat -c`。
2. 运行真机测试：`flutter test integration_test/full_device_flow_test.dart -d f17804b --reporter expanded`。
3. 导出 logcat：保存到任务目录。
4. 扫描崩溃关键字。
5. 导出测试后 UIAutomator XML/截图。

## 阶段 4：报告

1. 将每条用例的实际结果写入 `test-report.md`。
2. 对 Blocked/Manual-only/N.A. 项明确原因和建议。
3. 记录证据文件路径、命令、退出码。
4. 尝试 CCG review：antigravity 若仍缺失则记录失败；Claude 可用则保存审查输出。
5. 归档 `.ccg/tasks/android-full-device-test-report`；由于根目录不是 git worktree，归档 commit 不可执行时在报告说明。
