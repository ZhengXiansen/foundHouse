# PRD v1.2 审查与验证记录

## 范围

- PRD：`租房扫楼产品PRDv1.2.md`
- App：`found-house-app`
- 重点能力：快速记录显式保存、必填校验、村级楼栋选择/创建、楼栋入口去重、字段顺序调整、村/楼栋/房源右划删除、地图/定位主流程下线。

## 关键实现

- `lib/features/scan/quick_record_page.dart`
  - 进入页面不再自动创建空房源；只在显式保存/去补全且月租、门牌/房号、房型合法后落库。
  - 村级入口支持选择已有楼栋或输入新楼栋，房源保存失败时通过 `deleteBuildingIfEmpty` 安全回滚仅空楼栋。
  - 楼栋入口隐藏重复楼栋输入，只保留门牌/房号。
  - 字段顺序为：① 月租、② 门牌/房号、③ 房型、④ 拍照/相册。
  - 修复“去补全”后快速记录页 offstage 残留：App 内快速记录入口统一走 GoRoute，保存后先移除快速记录页再进入详情；无 GoRouter 的单页 fallback 不崩溃。
- `lib/features/common/delete_confirmation.dart`
  - 统一删除确认弹窗。
- `lib/features/scan/village_home_page.dart`
  - 首页村卡支持右划确认删除；快速记录入口走 GoRoute 主流程。
- `lib/features/scan/village_detail_page.dart`
  - 楼栋卡支持右划确认删除；村/楼栋入口进入快速记录。
- `lib/features/house/house_list_page.dart`
  - 房源卡支持右划确认删除。
- `lib/data/repositories/village_repository.dart`
  - `deleteVillage` / `deleteBuilding` 级联清理房源和照片。
  - `deleteBuildingIfEmpty` 用于新楼栋保存失败回滚，避免误删已有房源。
- `lib/data/repositories/house_repository.dart`
  - 删除房源时清理照片并 touch 村/楼栋统计，保证 Drift watch 流刷新。

## 测试覆盖

- `test/features/scan_map_page_test.dart`
  - 空表单不创建房源。
  - 必填/非法租金阻止保存。
  - 去补全先校验再创建并进入详情。
  - `skipOffstage:false` 断言去补全后快速记录不残留在 widget tree。
  - 无 GoRouter 单页 fallback 的去补全/保存并离开不崩溃。
  - 村级选择已有楼栋/输入新楼栋并绑定。
  - 新楼栋保存失败安全回滚。
  - 首页无地图/定位文案。
  - 村、楼栋、房源右划确认删除。
- `test/data/village_repository_test.dart`
  - 删除村/楼栋级联清理。
  - `deleteBuildingIfEmpty` 只删除空回滚楼栋。
  - `HouseRepository.delete` 后村统计流刷新。
- QA 文档：
  - `found-house-app/docs/qa/v1.2-test-cases.md`
  - `found-house-app/docs/qa/v1.2-release-manual-checklist.md`

## 双模型审查

- Antigravity：多次通过 `codeagent-wrapper --backend antigravity` 尝试，均因本机缺少 `agy` 命令失败，输出已留档：
  - `review-antigravity-final-final.txt`
  - 错误：`agy command not found in PATH`
- Claude：最终审查完成，输出：
  - `review-claude-final-final.txt`
  - Session：`1c05244d-ae19-433b-abf9-df32c5b82645`
  - 结论：无 Critical，可发布。
  - 非阻断 Warning：
    1. `_saveAndOpenDetail` 当前为 `Navigator.pop()` + `router.push()`，中间用零时长延迟保证顺序；已有 `skipOffstage:false` 回归覆盖，建议后续继续评估 go_router 原生 replace 语义。
    2. `_MissingVillagePage` 的“返回首页”仍直接使用 `context.go('/scan')`；生产主流程有 GoRouter，不阻断发布，后续可补 `maybeOf` fallback。

## 已执行验证（最终代码）

工作目录：`D:\dev\code\foundHouse\found-house-app`

| 命令 | 结果 |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test test/features/scan_map_page_test.dart --reporter expanded` | 11/11 passed |
| `flutter test test/data/village_repository_test.dart --reporter expanded` | 9/9 passed |
| `flutter test --reporter expanded` | 155/155 passed |
| `flutter build apk --release` | 成功，`build\app\outputs\flutter-apk\app-release.apk`，64.6MB |
| `flutter install -d e4e6ad3a --release` | 成功安装 release 到 22081212C |
| `flutter test -d e4e6ad3a integration_test/v1_1_formal_device_flow_test.dart --reporter expanded` | 1/1 passed |
| `flutter test -d e4e6ad3a integration_test/full_device_flow_test.dart --reporter expanded` | 1/1 passed |
| 设备测试后 `flutter install -d e4e6ad3a --release` | 成功重新安装 release，`FINAL_RELEASE_REINSTALL_EXIT_CODE=0` |

备注：设备集成测试过程中 Flutter 会安装 debug 包；日志中出现过 debug/release 签名不一致的 ADB 提示，但两条测试 exit code 均为 0 且 `All tests passed`。测试后已重新安装 release 正式版。

## 发布结论

PRD v1.2 本次需求已实现并通过自动化、构建、真机安装和设备集成测试。最终 APK：

`found-house-app\build\app\outputs\flutter-apk\app-release.apk`
