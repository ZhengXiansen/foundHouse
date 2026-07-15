# Review — fix manual village flow findings

## Scope

本轮复核范围来自上一轮全局 review 的 P0/P1 问题，并补充真机测试入口检查：

- Drift `schemaVersion` v1 -> v2 迁移显式回归测试。
- `QuickRecordPage._openDetail()` 导航从 pop 后复用 context 改为稳定 replacement。
- `VillageDetailPage._BuildingList` 将“在此楼记录房源”动作放回对应楼栋 Card 内。
- 过期 map-first 文档入口增加 2026-07 状态标注。
- `integration_test/full_device_flow_test.dart` 从旧“扫楼地图”主流程更新为“首页村列表 → 村 → 楼栋 → 快速记录 → 详情”的设备主流程脚本。

## External dual-model review status

CCG 规范要求 M+ 任务使用 antigravity + Claude 双模型分析/审查。但本机 wrapper 不存在，无法执行外部双模型审查：

- `C:\Users\Mr.Zheng\.claude\bin\codeagent-wrapper`：missing
- `C:/Users/Mr.Zheng/.claude/bin/codeagent-wrapper`：missing

本次 fallback 为：本地源代码 review + focused regression tests + `flutter analyze` + full unit/widget tests + Android device/build checks。未伪造外部模型审查结果。

## Review findings

### Critical

None found in the reviewed scope.

### Warning

1. **Android 真机未实际执行成功**  
   `adb devices` 能看到设备 `e4e6ad3a`，但状态为 `unauthorized`；`flutter devices` 因未授权不把它列为可用 Android 设备。因此无法把 integration test 安装/运行到真机。已补充 Android debug APK 构建验证，等待用户在手机上确认 USB 调试授权后可继续运行：
   `flutter test -d e4e6ad3a integration_test/full_device_flow_test.dart`。

2. **Git/diff 隔离能力有限**  
   根目录 `D:\dev\code\foundHouse` 不是 Git repo；`found-house-app` 是 Git repo 但当前所有文件均处于 untracked 状态。因此本次无法用正常 commit diff 精确隔离变更，只能按文件审查和测试证据确认范围。

3. **地图 / AMap / BFF 底层代码仍存在**  
   按当前分阶段策略，本轮只做业务下线与主流程测试更新。底层 map repository、BFF client、旧地图相关单测仍保留，属于 phase-2 物理清理 backlog；当前用户可见主流程不再暴露地图/定位依赖。

### Info

- 新增 v1 -> v2 Drift migration test，覆盖旧 `house_record`、旧 `photo_asset.house_id`、`system-unassigned-village` 回填、owner-aware photo 迁移，以及 `HouseRepository.getPhotoAssets(oldHouseId)` 兼容读取。
- 新增 QuickRecord widget 回归：点击“去补全”进入 `房源详情`，且 `快速记录` route 被 replacement 移除。
- 新增 VillageDetail widget 回归：`在此楼记录房源` 必须是对应 `1号楼` Card 的 descendant。
- 设备 integration 脚本已同步为新版手动村扫楼主流程，并断言启动页不出现“扫楼地图/定位”文案。
- 过期 README/CLAUDE 文档已加状态 banner，明确当前以 `租房扫楼产品PRDv1.1.md` 为准。

## Source review notes

- `lib/features/scan/quick_record_page.dart`
  - `_openDetail()` 现在使用 `context.pushReplacement('/houses/$id')`，避免 pop 当前 route 后继续使用同一个已弹出 route 的 `BuildContext`。
- `lib/features/scan/village_detail_page.dart`
  - 每个 building 使用一个 `Card -> Column` 包含 `ListTile` 与该楼栋的 `OutlinedButton('在此楼记录房源')`，视觉归属和点击目标一致。
- `integration_test/full_device_flow_test.dart`
  - 旧地图流程断言已替换为：空首页新增村、进入村、新增楼栋、楼栋下快速记录、去补全进入详情、Checklist、偏好、对比、隐私页。

## Verification evidence

以下命令均为本轮 review 阶段后新鲜执行：

```powershell
cd D:\dev\code\foundHouse\found-house-app
flutter test --reporter expanded test/data/app_database_migration_test.dart test/features/scan_map_page_test.dart
```

结果：exit 0，输出结尾：`+5: All tests passed!`

```powershell
flutter analyze
```

结果：exit 0，输出：`No issues found! (ran in 2.9s)`

```powershell
flutter test
```

结果：exit 0，输出结尾：`+144: All tests passed!`

```powershell
flutter build apk --debug
```

结果：exit 0，输出：`✓ Built build\app\outputs\flutter-apk\app-debug.apk`

## Device test status

已检查 Android 设备连接状态：

```text
adb devices
List of devices attached
e4e6ad3a	unauthorized
```

```text
flutter devices
Found 3 connected devices:
  Windows (desktop) • windows • windows-x64
  Chrome (web)      • chrome  • web-javascript
  Edge (web)        • edge    • web-javascript

Device e4e6ad3a is not authorized.
```

真机 integration test 尝试：

```powershell
flutter test -d e4e6ad3a integration_test/full_device_flow_test.dart
```

结果：exit 1，原因：`No supported devices found with name or id matching 'e4e6ad3a'`。根因仍是手机 USB 调试未授权。

结论：Android 真机测试当前被设备授权状态阻塞；Android debug APK 构建通过，integration test 脚本已更新为新版手动村扫楼主流程，待手机授权后可直接复跑。
