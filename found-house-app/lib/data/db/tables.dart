/// Drift 表定义（W1-2 · D1，技术方案 §5.1，冻结项 F9）。
///
/// 命名映射（build.yaml：case_from_dart_to_sql: snake_case）：
///   Dart 属性用 lowerCamelCase（如 [FeeInfo.rentMonthly]），
///   自动生成 snake_case 存储列（rent_monthly），与字段字典逐字段对齐。
///
/// 关键约束：
/// - 字段字典（docs/field-dictionary.md）为字段命名单一事实源，禁止在此另起别名。
/// - 敏感字段（phone/wechat/room_no/敏感 note）以 TextColumn 存**密文**，
///   加解密统一走 CryptoService（W5 · H1），数据库层不感知明文。
/// - 金额统一整数「元」；水电单价用 real；时间戳用毫秒整数。
/// - `*_json` 存 JSON 字符串，读取时反序列化。
library;

import 'package:drift/drift.dart';

/// 村 / 片区：手动扫楼的一级项目。
class Villages extends Table {
  @override
  String get tableName => 'village';

  /// UUID v4 或系统固定 id（未分组）。
  TextColumn get id => text()();

  /// 村名 / 片区名。
  TextColumn get name => text()();

  /// 生命周期：preparing/scouting/paused/completed/archived。
  TextColumn get status => text().withDefault(const Constant('preparing'))();

  /// 区域备注：如范围、入口、管理处位置等。
  TextColumn get areaNote => text().nullable()();

  /// 手动记录的默认通勤分钟。
  IntColumn get commuteMinutes => integer().nullable()();

  /// 通勤备注：如到地铁、公司、常走路线。
  TextColumn get commuteNote => text().nullable()();

  /// 周边标签 JSON：菜市场/地铁/夜宵/噪音等。
  TextColumn get surroundingsTagsJson => text().nullable()();

  /// 主观周边评分。
  IntColumn get surroundingsScore => integer().nullable()();

  /// 环境评分。
  IntColumn get environmentScore => integer().nullable()();

  /// 安全评分。
  IntColumn get safetyScore => integer().nullable()();

  /// 噪音评分。
  IntColumn get noiseScore => integer().nullable()();

  /// 备注。
  TextColumn get note => text().nullable()();

  /// 创建时间（本地毫秒时间戳）。
  IntColumn get createdAt => integer()();

  /// 更新时间（本地毫秒时间戳）。
  IntColumn get updatedAt => integer()();

  /// 最近扫楼/访问时间。
  IntColumn get lastVisitedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 楼栋 / 入口：村内独立扫楼记录，可无房源单独存在。
class Buildings extends Table {
  @override
  String get tableName => 'building';

  /// UUID v4 主键。
  TextColumn get id => text()();

  TextColumn get villageId =>
      text().references(Villages, #id, onDelete: KeyAction.cascade)();

  /// 楼栋 / 入口名。
  TextColumn get name => text()();

  /// 状态：not_scouted/no_vacancy/has_vacancy/contacting/needs_revisit/abandoned。
  TextColumn get status => text().withDefault(const Constant('not_scouted'))();

  /// 标签 JSON：电话没人接/门禁进不去等。
  TextColumn get tagsJson => text().nullable()();

  /// 入口备注。
  TextColumn get entranceNote => text().nullable()();

  /// 总楼层。
  IntColumn get totalFloor => integer().nullable()();

  /// 是否有电梯。
  BoolColumn get hasElevator => boolean().nullable()();

  /// 备注。
  TextColumn get note => text().nullable()();

  /// 创建时间（本地毫秒时间戳）。
  IntColumn get createdAt => integer()();

  /// 更新时间（本地毫秒时间戳）。
  IntColumn get updatedAt => integer()();

  /// 最近扫楼/访问时间。
  IntColumn get lastVisitedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 房源主表。1 条房源的根记录，其余表按 house_id 关联。
class HouseRecords extends Table {
  @override
  String get tableName => 'house_record';

  /// UUID v4 主键。
  TextColumn get id => text()();

  /// 标题：用户标题或自动生成标题。
  TextColumn get title => text()();

  /// 状态：draft/active/shortlisted/rejected/chosen。
  TextColumn get status => text().withDefault(const Constant('draft'))();

  /// 所属村 / 片区。DB 层允许空以兼容旧数据，仓库层自动补“未分组”。
  TextColumn get villageId => text()
      .nullable()
      .references(Villages, #id, onDelete: KeyAction.setNull)();

  /// 所属楼栋 / 入口，可空表示村内未分楼栋房源。
  TextColumn get buildingId => text()
      .nullable()
      .references(Buildings, #id, onDelete: KeyAction.setNull)();

  /// 纬度（遗留字段，V0.2 手动扫楼流程不再展示/依赖）。
  RealColumn get latitude => real().nullable()();

  /// 经度（导出可隐藏精确经纬度）。
  RealColumn get longitude => real().nullable()();

  /// 用户输入地址文本。
  TextColumn get addressText => text().nullable()();

  /// 楼栋或村名。
  TextColumn get buildingName => text().nullable()();

  /// 门牌：存全量原文，脱敏在导出层（F9）。敏感字段，密文存储。
  TextColumn get roomNo => text().nullable()();

  /// 创建时间（本地毫秒时间戳）。
  IntColumn get createdAt => integer()();

  /// 更新时间（本地毫秒时间戳）。
  IntColumn get updatedAt => integer()();

  /// 看房时间。
  IntColumn get visitedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 费用信息（1:1 关联 HouseRecord，house_id 唯一）。
class FeeInfos extends Table {
  @override
  String get tableName => 'fee_info';

  TextColumn get houseId =>
      text().references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 月租（元/月）。
  IntColumn get rentMonthly => integer().nullable()();

  /// 押金（元）。
  IntColumn get deposit => integer().nullable()();

  /// 付款周期（押一付一等）。
  TextColumn get paymentCycle => text().nullable()();

  /// 管理费（元/月）。
  IntColumn get managementFee => integer().nullable()();

  /// 网费（元/月）。
  IntColumn get internetFee => integer().nullable()();

  /// 水费单价（元/吨）；缺失触发保守估值（F2）。
  RealColumn get waterUnitPrice => real().nullable()();

  /// 电费单价（元/度）；缺失触发保守估值（F2）。
  RealColumn get electricityUnitPrice => real().nullable()();

  /// 燃气费（元/月）。
  IntColumn get gasFee => integer().nullable()();

  /// 其他固定费用（元/月）。
  IntColumn get otherFee => integer().nullable()();

  /// 预估月总成本（元/月）：由引擎计算，含缺失补偿（F2）。
  IntColumn get estimatedTotalMonthly => integer().nullable()();

  @override
  Set<Column> get primaryKey => {houseId};
}

/// 房屋信息（1:1 关联 HouseRecord）。
class RoomInfos extends Table {
  @override
  String get tableName => 'room_info';

  TextColumn get houseId =>
      text().references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 房型（单间/一房一厅等）。
  TextColumn get layout => text().nullable()();

  /// 面积（平米）。
  RealColumn get area => real().nullable()();

  /// 所在楼层。
  IntColumn get floor => integer().nullable()();

  /// 楼栋总层数。
  IntColumn get totalFloor => integer().nullable()();

  /// 电梯（硬筛可选条件）。
  BoolColumn get hasElevator => boolean().nullable()();

  /// 朝向。
  TextColumn get orientation => text().nullable()();

  /// 独卫（硬筛可选条件）。
  BoolColumn get hasPrivateBathroom => boolean().nullable()();

  /// 厨房（硬筛可选条件）。
  BoolColumn get hasKitchen => boolean().nullable()();

  /// 能否做饭（硬筛可选条件）。
  BoolColumn get canCook => boolean().nullable()();

  /// 能否养宠（硬筛可选条件）。
  BoolColumn get canPet => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {houseId};
}

/// 联系人信息（1:1 关联 HouseRecord）。phone/wechat 敏感，密文存储（F7）。
class ContactInfos extends Table {
  @override
  String get tableName => 'contact_info';

  TextColumn get houseId =>
      text().references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 称呼。
  TextColumn get name => text().nullable()();

  /// 角色（房东/管理员/中介/二房东/未知）。
  TextColumn get role => text().nullable()();

  /// 电话：敏感字段，本地加密（AES-256-GCM，F7）后存密文。
  TextColumn get phone => text().nullable()();

  /// 微信：敏感字段，本地加密后存密文。
  TextColumn get wechat => text().nullable()();

  /// 身份是否已核验（是否看过证件/授权）。
  BoolColumn get identityVerified => boolean().nullable()();

  /// 备注：用户标记敏感时加密。
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {houseId};
}

/// 看房检查项（1:N 关联 HouseRecord）。
class ChecklistItems extends Table {
  @override
  String get tableName => 'checklist_item';

  /// UUID 主键。
  TextColumn get id => text()();

  TextColumn get houseId =>
      text().references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 模块：room/kitchen/building/contract/risk。
  TextColumn get module => text()();

  /// 检查项编码（见 docs/rules/checklist-template.json）。
  TextColumn get key => text()();

  /// 取值：good/ok/bad/not_seen（risk 模块用 hit/not_hit/not_seen）。
  TextColumn get value => text().nullable()();

  /// 备注。
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 风险标记（1:N 关联 HouseRecord）。
class RiskFlags extends Table {
  @override
  String get tableName => 'risk_flag';

  /// UUID 主键。
  TextColumn get id => text()();

  TextColumn get houseId =>
      text().references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 风险编码（risk_second_landlord 等，见评分规则）。
  TextColumn get key => text()();

  /// 严重度：warning（扣分）/ blocker（硬筛淘汰）。
  TextColumn get severity => text()();

  /// 来源：user / system。
  TextColumn get source => text().withDefault(const Constant('user'))();

  /// 风险说明。
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 照片资源。文件落端侧，此处存路径与元信息。
///
/// V0.2 起使用 ownerType + ownerId 泛化归属：village/building/house。
/// houseId 保留为可空兼容字段，house 照片继续写入以支持旧查询与级联。
class PhotoAssets extends Table {
  @override
  String get tableName => 'photo_asset';

  /// UUID 主键。
  TextColumn get id => text()();

  TextColumn get houseId => text()
      .nullable()
      .references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 归属类型：village/building/house。
  TextColumn get ownerType => text().withDefault(const Constant('house'))();

  /// 归属对象 id。house 照片与 houseId 相同；building/village 照片不写 houseId。
  TextColumn get ownerId => text()();

  /// 端侧文件路径。
  TextColumn get localPath => text()();

  /// 标签：sign/building/room/window/bathroom/meter/contract/damage。
  TextColumn get tag => text()();

  /// 拍摄时间（毫秒时间戳）。
  IntColumn get takenAt => integer()();

  /// 导出时是否去 EXIF。
  BoolColumn get exifRemoved => boolean().withDefault(const Constant(false))();

  /// 存储位置：local（仅端侧）/ oss（已直传对象存储）。默认 local（V1.1 云同步）。
  TextColumn get storageProvider =>
      text().withDefault(const Constant('local'))();

  /// 远端公网可读地址；仅 storageProvider 为 oss 时非空。
  TextColumn get remoteUrl => text().nullable()();

  /// 远端对象键；仅 storageProvider 为 oss 时非空。
  TextColumn get objectKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 地图快照（1:1 关联 HouseRecord）。列表与评分从本地快照读取（不实时调用高德）。
class MapSnapshots extends Table {
  @override
  String get tableName => 'map_snapshot';

  TextColumn get houseId =>
      text().references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 提供方（amap）。
  TextColumn get provider => text().withDefault(const Constant('amap'))();

  /// 通勤路线摘要 JSON（含 transit 主口径，F5）。
  TextColumn get commuteJson => text().nullable()();

  /// 分半径 POI 统计 JSON。
  TextColumn get poiSummaryJson => text().nullable()();

  /// 用户主观修正 JSON。
  TextColumn get userCorrectionJson => text().nullable()();

  /// 获取时间（毫秒时间戳）。
  IntColumn get fetchedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {houseId};
}

/// 评分快照（1:N 关联 HouseRecord，历史冻结 F8）。
///
/// 规则或权重变更时生成新快照、保留旧快照，不自动重算历史房源。
class ScoreSnapshots extends Table {
  @override
  String get tableName => 'score_snapshot';

  /// UUID 主键（一套房可有多条历史快照）。
  TextColumn get id => text()();

  TextColumn get houseId =>
      text().references(HouseRecords, #id, onDelete: KeyAction.cascade)();

  /// 冻结计算时的规则版本（F8）。
  TextColumn get ruleVersion => text()();

  /// 硬筛结果：pass / rejected。
  TextColumn get hardFilterResult => text()();

  /// 硬筛淘汰原因清单 JSON。
  TextColumn get hardFilterReasonsJson => text().nullable()();

  /// 加权总分。
  RealColumn get scoreTotal => real()();

  /// 5 维分项 JSON。
  TextColumn get scoreBreakdownJson => text().nullable()();

  /// 可解释文案 JSON。
  TextColumn get explanationJson => text().nullable()();

  /// 生成时间（毫秒时间戳）。
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 偏好档案（单条默认 profile）。预算硬筛唯一基准为 max_rent_total（月总成本，F1）。
class PreferenceProfiles extends Table {
  @override
  String get tableName => 'preference_profile';

  /// 默认 profile 主键。
  TextColumn get id => text()();

  /// 月总成本上限：预算硬筛唯一基准（F1），非月租口径。
  IntColumn get maxRentTotal => integer().nullable()();

  /// 最大通勤时间（分钟）。
  IntColumn get maxCommuteMinutes => integer().nullable()();

  /// 目的地 JSON：`[{id,label,lat,lng,primary}]`，primary=true 为主要目的地（F5）。
  TextColumn get destinationsJson => text().nullable()();

  /// 硬性条件 JSON：独卫/厨房/电梯/宠物/楼层/押付。
  TextColumn get requiredFeaturesJson => text().nullable()();

  /// 权重 JSON：默认 `{cost:30,commute:20,living:25,nearby:15,risk:10}`（F4）。
  TextColumn get weightsJson => text().nullable()();

  /// 首选通勤方式（walking/bicycling/transit/driving）；空则默认 transit（F5）。
  TextColumn get preferredCommuteMode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
