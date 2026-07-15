# V0.2 手动村扫楼模式方案

## 目标
产品上彻底下线地图定位与第三方地图 API，转为离线优先的“村 -> 楼栋 -> 房源”扫楼台账。

## 信息架构
- 首页：继续扫楼卡片 + 村列表进度统计。
- 村详情：楼栋扫楼工作台。
- 楼栋详情：楼栋状态、标签、备注、楼栋照片、下属房源。
- 快速记录：村必选，楼栋可选/后补，月租 + 拍照 + 房型为核心，可填楼栋/入口和门牌/房号。
- 房源：全局复盘列表，可按村筛选。
- 对比：候选房源对比。

## 数据模型草案
- villages：id, name, status, area_note, commute_minutes, commute_note, surroundings_tags_json, surroundings_score, environment_score, safety_score, noise_score, note, created_at, updated_at, last_visited_at。
- buildings：id, village_id, name, status, tags_json, entrance_note, total_floor, has_elevator, note, created_at, updated_at, last_visited_at。
- house_record 增加：village_id 必填，building_id 可空。
- photo_asset 建议改为通用 owner：owner_type(village/building/house), owner_id；保留 tag/local_path/taken_at/exif_removed。

## 地图下线策略
第一阶段只做业务下线：用户看不到地图/定位/经纬度/刷新/地图失败，不调用地图 API/BFF。底层 latitude/longitude/map_snapshot 先保留不用，降低迁移风险。
第二阶段新流程稳定后，逐步清理 MapRepository/Amap/BFF map/map_snapshot 与相关测试。

## 迁移策略
自动创建“未分组”村，将所有旧房源挂到未分组，building_id 为空，显示为未分楼栋房源。

## 验收主流程
1. 新增村。
2. 首页展示继续扫楼和村统计。
3. 进入村详情。
4. 新增楼栋并标记状态。
5. 楼栋可无房源独立存在。
6. 在村或楼栋下快速记录房源。
7. 房源必须归属村，楼栋可后补。
8. 楼栋/房源都可拍照。
9. 房源列表可按村复盘。
10. 全流程不出现地图、定位、经纬度、地图 API 失败。
