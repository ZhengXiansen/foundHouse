# Requirements — fix manual village flow review findings

## User goal

先整理需要修复的问题，然后进行修复，修复完成再进行全局 review，最后做真机测试。

## Confirmed iteration scope

本轮聚焦上一轮全局 review 中影响交付可信度或用户体验的小中型问题：

### P0 / 本轮必须处理

1. Drift v1 -> v2 schema migration 缺少显式回归测试。
   - 构造 v1 旧 schema 和旧数据。
   - 用当前 AppDatabase 打开触发升级。
   - 验证旧房源归入 system-unassigned-village。
   - 验证旧照片迁移为 owner_type = house、owner_id = old house_id，并保留 house_id 兼容字段。
   - 验证 HouseRepository.getPhotoAssets(oldHouseId) 仍能读取旧照片。
2. QuickRecordPage 保存后进入详情的导航上下文脆弱。
   - 当前风险：pop 后继续使用被 pop route 的 BuildContext push 详情页。
   - 改为更稳健的 replacement/go 导航，并补 widget 回归测试。
3. 过期 map-first 文档需要标注或同步。
   - 至少在 CLAUDE.md、found-house-app/CLAUDE.md、found-house-app/README.md 等旧入口顶部标明历史状态，以 租房扫楼产品PRDv1.1.md 为准。

### P1 / 本轮优先处理的小改

4. VillageDetailPage 楼栋卡片按钮布局错位风险。
   - 将“在此楼记录房源”动作放回对应楼栋 Card 内部，避免先渲染所有 Card 再渲染所有按钮。
   - 保证现有 scan/village widget 测试仍可点击对应动作。

## Deferred / backlog

以下范围较大，本轮只记录，不直接实现，除非用户另行要求：

- 未分楼栋房源迁移/归档到某栋楼的用户操作。
- 村/楼栋照片上传、浏览、删除 UI。
- 村/楼栋编辑、归档、删除策略与危险操作确认。
- 地图/AMap/BFF 底层代码的 phase-2 物理清理。

## Acceptance criteria

- 修复项均有对应测试或明确说明为何仅文档变更。
- `flutter analyze` 通过。
- `flutter test` 通过。
- 生成本轮 review.md，记录全局 review 结论、验证证据、外部双模型审查状态/降级原因。
- Android 真机或可用设备验证完成；若无设备，记录 `adb devices` / `flutter devices` 证据和阻塞原因。
- CCG 任务归档到 `.ccg/tasks/archive/2026-07/`。
