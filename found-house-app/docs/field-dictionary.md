# 房源字段字典 v0.1（单一事实源）

> 对应冻结项 F9。本表为客户端 Drift schema、后端契约、导出脱敏、评分引擎共同引用的字段命名单一事实源。
> 与《租房扫楼产品落地细节与技术实现方案.md》§5.1 表结构逐字段对齐。
> 命名规范：存储层（SQLite/Drift）用 `snake_case`；Dart 模型属性用 `lowerCamelCase`（Drift 自动映射）；JSON 序列化字段沿用 snake_case。

## 通用约定

- 主键 `id`：UUID v4 字符串（text）。
- 时间戳：本地毫秒时间戳（integer, `DateTime.millisecondsSinceEpoch`）。
- 布尔：Drift `boolean`，SQLite 底层存 0/1。
- 金额：整数分位保留为「元」的 integer；单价（水/电）用 real。
- `*_json` 字段：存 JSON 字符串，读取时反序列化。
- 敏感字段（见下表「敏感」列）：写入前经 `CryptoService.encryptField` 加密（F7）；导出默认脱敏（F9 / §10.2）。

## HouseRecord（房源主表）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 可空 | 敏感 | 导出脱敏 | 说明 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 房源ID | id | id | text | 否 | 否 | 否 | UUID |
| 标题 | title | title | text | 否 | 否 | 否 | 用户标题或自动标题 |
| 状态 | status | status | text | 否 | 否 | 否 | draft/active/shortlisted/rejected/chosen |
| 纬度 | latitude | latitude | real | 是 | 否 | 是 | 导出可隐藏精确经纬度 |
| 经度 | longitude | longitude | real | 是 | 否 | 是 | 导出可隐藏精确经纬度 |
| 地址文本 | address_text | addressText | text | 是 | 否 | 否 | 用户输入地址 |
| 楼栋/村名 | building_name | buildingName | text | 是 | 否 | 否 | 楼栋或村名 |
| 门牌 | room_no | roomNo | text | 是 | 是 | 是 | 存全量原文，脱敏在导出层 |
| 创建时间 | created_at | createdAt | integer | 否 | 否 | 否 | 本地时间戳 |
| 更新时间 | updated_at | updatedAt | integer | 否 | 否 | 否 | 本地时间戳 |
| 看房时间 | visited_at | visitedAt | integer | 是 | 否 | 否 | 看房时间 |

> 状态机：draft（草稿）→ active（已补全）→ shortlisted（候选）/ rejected（淘汰）/ chosen（已选）。硬筛命中 blocker 或超限 → rejected（保留原因，不隐藏）。

## FeeInfo（费用，1:1 关联 HouseRecord）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 可空 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 房源ID | house_id | houseId | text | 否 | 关联 HouseRecord |
| 月租 | rent_monthly | rentMonthly | integer | 是 | 元/月 |
| 押金 | deposit | deposit | integer | 是 | 元 |
| 付款周期 | payment_cycle | paymentCycle | text | 是 | 押一付一等 |
| 管理费 | management_fee | managementFee | integer | 是 | 元/月 |
| 网费 | internet_fee | internetFee | integer | 是 | 元/月 |
| 水费单价 | water_unit_price | waterUnitPrice | real | 是 | 元/吨；缺失触发保守估值（F2） |
| 电费单价 | electricity_unit_price | electricityUnitPrice | real | 是 | 元/度；缺失触发保守估值（F2） |
| 燃气费 | gas_fee | gasFee | integer | 是 | 元/月 |
| 其他固定费用 | other_fee | otherFee | integer | 是 | 元/月 |
| 预估月总成本 | estimated_total_monthly | estimatedTotalMonthly | integer | 是 | 由引擎计算，含缺失补偿（F2） |

> 派生标记（不落表，运行时计算）：`has_missing_fee`（缺水电单价时 true）、`missing_critical`（缺失关键项清单）。

## RoomInfo（房屋，1:1）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 可空 | 说明 |
| --- | --- | --- | --- | --- | --- |
| 房源ID | house_id | houseId | text | 否 | 关联 |
| 房型 | layout | layout | text | 是 | 单间/一房一厅等 |
| 面积 | area | area | real | 是 | 平米 |
| 楼层 | floor | floor | integer | 是 | 所在楼层 |
| 总楼层 | total_floor | totalFloor | integer | 是 | 楼栋总层数 |
| 电梯 | has_elevator | hasElevator | boolean | 是 | 硬筛可选条件 |
| 朝向 | orientation | orientation | text | 是 | 朝向 |
| 独卫 | has_private_bathroom | hasPrivateBathroom | boolean | 是 | 硬筛可选条件 |
| 厨房 | has_kitchen | hasKitchen | boolean | 是 | 硬筛可选条件 |
| 能否做饭 | can_cook | canCook | boolean | 是 | 硬筛可选条件 |
| 能否养宠 | can_pet | canPet | boolean | 是 | 硬筛可选条件 |

## ContactInfo（联系人，1:1）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 可空 | 敏感 | 说明 |
| --- | --- | --- | --- | --- | --- | --- |
| 房源ID | house_id | houseId | text | 否 | 否 | 关联 |
| 称呼 | name | name | text | 是 | 否 | 称呼 |
| 角色 | role | role | text | 是 | 否 | 房东/管理员/中介/二房东/未知 |
| 电话 | phone | phone | text | 是 | **是** | 本地加密（AES-256-GCM，F7）|
| 微信 | wechat | wechat | text | 是 | **是** | 本地加密 |
| 身份已核验 | identity_verified | identityVerified | boolean | 是 | 否 | 是否看过证件/授权 |
| 备注 | note | note | text | 是 | 可选 | 用户标记敏感时加密 |

## ChecklistItem（检查项，1:N）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 说明 |
| --- | --- | --- | --- | --- |
| ID | id | id | text | UUID |
| 房源ID | house_id | houseId | text | 关联 |
| 模块 | module | module | text | room/kitchen/building/contract/risk |
| 检查项编码 | key | key | text | 见 checklist 模板 |
| 取值 | value | value | text | good/ok/bad/not_seen |
| 备注 | note | note | text | 备注 |

## RiskFlag（风险标记，1:N）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 说明 |
| --- | --- | --- | --- | --- |
| ID | id | id | text | UUID |
| 房源ID | house_id | houseId | text | 关联 |
| 风险编码 | key | key | text | risk_second_landlord 等，见评分规则 |
| 严重度 | severity | severity | text | warning（扣分）/ blocker（硬筛淘汰）|
| 来源 | source | source | text | user / system |
| 说明 | note | note | text | 风险说明 |

## PhotoAsset（照片，1:N）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 敏感 | 说明 |
| --- | --- | --- | --- | --- | --- |
| ID | id | id | text | 否 | UUID |
| 房源ID | house_id | houseId | text | 否 | 关联 |
| 本地路径 | local_path | localPath | text | 否 | 端侧文件路径 |
| 标签 | tag | tag | text | 否 | sign/building/room/window/bathroom/meter/contract/damage |
| 拍摄时间 | taken_at | takenAt | integer | 否 | 时间戳 |
| EXIF已移除 | exif_removed | exifRemoved | boolean | 否 | 导出时是否去 EXIF |

> 合同照片（tag=contract）、门牌相关照片导出默认隐藏（UI §5.10「包含合同照片」默认关）。

## MapSnapshot（地图快照，1:1）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 说明 |
| --- | --- | --- | --- | --- |
| 房源ID | house_id | houseId | text | 关联 |
| 提供方 | provider | provider | text | amap |
| 通勤JSON | commute_json | commuteJson | text | 路线摘要（含 transit 主口径，F5）|
| POI摘要JSON | poi_summary_json | poiSummaryJson | text | 分半径 POI 统计 |
| 用户修正JSON | user_correction_json | userCorrectionJson | text | 主观修正 |
| 获取时间 | fetched_at | fetchedAt | integer | 时间戳 |

## ScoreSnapshot（评分快照，1:N，历史冻结 F8）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 说明 |
| --- | --- | --- | --- | --- |
| 房源ID | house_id | houseId | text | 关联 |
| 规则版本 | rule_version | ruleVersion | text | 冻结计算时版本（F8）|
| 硬筛结果 | hard_filter_result | hardFilterResult | text | pass / rejected |
| 硬筛原因JSON | hard_filter_reasons_json | hardFilterReasonsJson | text | 淘汰原因清单 |
| 总分 | score_total | scoreTotal | real | 加权总分 |
| 分项JSON | score_breakdown_json | scoreBreakdownJson | text | 5 维分项 |
| 解释JSON | explanation_json | explanationJson | text | 可解释文案 |

> 规则或权重变更时生成新快照、保留旧快照，不自动重算历史房源（F8）。

## PreferenceProfile（偏好，单条默认 profile）

| 中文名 | 存储字段 | Dart 属性 | 类型 | 说明 |
| --- | --- | --- | --- | --- |
| ID | id | id | text | 默认 profile |
| 月总成本上限 | max_rent_total | maxRentTotal | integer | **预算硬筛唯一基准（F1）**，非月租 |
| 最大通勤时间 | max_commute_minutes | maxCommuteMinutes | integer | 分钟 |
| 目的地JSON | destinations_json | destinationsJson | text | `[{id,label,lat,lng,primary}]`，primary=true 为主要目的地（F5）|
| 硬性条件JSON | required_features_json | requiredFeaturesJson | text | 独卫/厨房/电梯/宠物/楼层/押付 |
| 权重JSON | weights_json | weightsJson | text | 默认 `{cost:30,commute:20,living:25,nearby:15,risk:10}`（F4）|
| 首选通勤方式 | preferred_commute_mode | preferredCommuteMode | text | 可空；空则默认 transit（F5）|

> `preferred_commute_mode` 为在原 §5.1 基础上按 F5 新增的偏好项，取值 walking/bicycling/transit/driving。
