// 领域模型（W1-2 · D1）。
//
// 与 UI/引擎及 Drift 生成的行类解耦的纯数据类，作为仓库对外返回的领域对象。
// 命名严格对齐字段字典（docs/field-dictionary.md，冻结项 F9），不另起别名。
// 敏感字段（roomNo/phone/wechat/敏感 note）在领域层为**明文**：
// 仓库读取时经 FieldCipher 解密后填入，写入时经 FieldCipher 加密后落库（F7）。
//
// 与 Drift 行类的互转集中在 mappers.dart，本文件不依赖 drift。
library;

/// 系统村常量。
class VillageDefaults {
  const VillageDefaults._();

  static const String unassignedVillageId = 'system-unassigned-village';
}

/// 村生命周期状态。
class VillageStatus {
  const VillageStatus._();

  static const String preparing = 'preparing';
  static const String scouting = 'scouting';
  static const String paused = 'paused';
  static const String completed = 'completed';
  static const String archived = 'archived';
}

/// 楼栋扫楼状态。
class BuildingStatus {
  const BuildingStatus._();

  static const String notScouted = 'not_scouted';
  static const String noVacancy = 'no_vacancy';
  static const String hasVacancy = 'has_vacancy';
  static const String contacting = 'contacting';
  static const String needsRevisit = 'needs_revisit';
  static const String abandoned = 'abandoned';
}

/// 照片归属类型。
class PhotoOwnerType {
  const PhotoOwnerType._();

  static const String village = 'village';
  static const String building = 'building';
  static const String house = 'house';
}

/// 照片存储位置：本地端侧 / OSS 远端（V1.1 云同步显式开启能力）。
///
/// 默认 [local]：文件仅落端侧，[PhotoAsset.remoteUrl]/[PhotoAsset.objectKey] 为空。
/// [oss]：文件已直传对象存储，remoteUrl 为公网可读地址，objectKey 为对象键。
class PhotoStorageProvider {
  const PhotoStorageProvider._();

  static const String local = 'local';
  static const String oss = 'oss';

  static const List<String> all = [local, oss];

  static bool isValid(String value) => all.contains(value);
}

/// 村 / 片区：手动扫楼的一级项目。
class Village {
  const Village({
    required this.id,
    required this.name,
    this.status = VillageStatus.preparing,
    this.areaNote,
    this.commuteMinutes,
    this.commuteNote,
    this.surroundingsTags = const [],
    this.surroundingsScore,
    this.environmentScore,
    this.safetyScore,
    this.noiseScore,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.lastVisitedAt,
  });

  final String id;
  final String name;
  final String status;
  final String? areaNote;
  final int? commuteMinutes;
  final String? commuteNote;
  final List<String> surroundingsTags;
  final int? surroundingsScore;
  final int? environmentScore;
  final int? safetyScore;
  final int? noiseScore;
  final String? note;
  final int createdAt;
  final int updatedAt;
  final int? lastVisitedAt;
}

/// 楼栋 / 入口：村内独立扫楼记录。
class Building {
  const Building({
    required this.id,
    required this.villageId,
    required this.name,
    this.status = BuildingStatus.notScouted,
    this.tags = const [],
    this.entranceNote,
    this.totalFloor,
    this.hasElevator,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.lastVisitedAt,
  });

  final String id;
  final String villageId;
  final String name;
  final String status;
  final List<String> tags;
  final String? entranceNote;
  final int? totalFloor;
  final bool? hasElevator;
  final String? note;
  final int createdAt;
  final int updatedAt;
  final int? lastVisitedAt;
}

/// 村首页/详情统计 DTO。
class VillageWithStats {
  const VillageWithStats({
    required this.village,
    required this.buildingCount,
    required this.houseCount,
    required this.shortlistedCount,
    required this.revisitCount,
    required this.unassignedHouseCount,
  });

  final Village village;
  final int buildingCount;
  final int houseCount;
  final int shortlistedCount;
  final int revisitCount;
  final int unassignedHouseCount;
}

/// 房源聚合根：house_record 主表字段 + 各关联子对象。
///
/// 1:1 子对象（fee/room/contact/mapSnapshot）可空；
/// 1:N 子对象（checklistItems/riskFlags/photos）以列表承载，缺省为空列表。
class HouseRecord {
  const HouseRecord({
    required this.id,
    required this.title,
    this.status = 'draft',
    this.villageId = VillageDefaults.unassignedVillageId,
    this.buildingId,
    this.latitude,
    this.longitude,
    this.addressText,
    this.buildingName,
    this.roomNo,
    required this.createdAt,
    required this.updatedAt,
    this.visitedAt,
    this.fee,
    this.room,
    this.contact,
    this.mapSnapshot,
    this.checklistItems = const [],
    this.riskFlags = const [],
    this.photos = const [],
  });

  /// UUID v4 主键。
  final String id;

  /// 标题：用户标题或自动生成标题。
  final String title;

  /// 状态：draft/active/shortlisted/rejected/chosen。
  final String status;

  /// 所属村 / 片区。
  final String villageId;

  /// 所属楼栋 / 入口；为空表示村内未分楼栋房源。
  final String? buildingId;

  /// 纬度（遗留字段，V0.2 手动扫楼流程不再展示/依赖）。
  final double? latitude;

  /// 经度。
  final double? longitude;

  /// 用户输入地址文本。
  final String? addressText;

  /// 楼栋或村名。
  final String? buildingName;

  /// 门牌（敏感字段，领域层为明文；落库前加密）。
  final String? roomNo;

  /// 创建时间（本地毫秒时间戳）。
  final int createdAt;

  /// 更新时间（本地毫秒时间戳）。
  final int updatedAt;

  /// 看房时间。
  final int? visitedAt;

  /// 费用信息（1:1）。
  final FeeInfo? fee;

  /// 房屋信息（1:1）。
  final RoomInfo? room;

  /// 联系人信息（1:1）。
  final ContactInfo? contact;

  /// 地图快照（1:1）。
  final MapSnapshot? mapSnapshot;

  /// 看房检查项（1:N）。
  final List<ChecklistItem> checklistItems;

  /// 风险标记（1:N）。
  final List<RiskFlag> riskFlags;

  /// 照片资源（1:N）。
  final List<PhotoAsset> photos;
}

/// 费用信息（1:1 关联 HouseRecord）。金额单位「元」，水电单价用 double。
class FeeInfo {
  const FeeInfo({
    this.rentMonthly,
    this.deposit,
    this.paymentCycle,
    this.managementFee,
    this.internetFee,
    this.waterUnitPrice,
    this.electricityUnitPrice,
    this.gasFee,
    this.otherFee,
    this.estimatedTotalMonthly,
  });

  /// 月租（元/月）。
  final int? rentMonthly;

  /// 押金（元）。
  final int? deposit;

  /// 付款周期（押一付一等）。
  final String? paymentCycle;

  /// 管理费（元/月）。
  final int? managementFee;

  /// 网费（元/月）。
  final int? internetFee;

  /// 水费单价（元/吨）。
  final double? waterUnitPrice;

  /// 电费单价（元/度）。
  final double? electricityUnitPrice;

  /// 燃气费（元/月）。
  final int? gasFee;

  /// 其他固定费用（元/月）。
  final int? otherFee;

  /// 预估月总成本（元/月）：由引擎计算写回，仓库仅存取。
  final int? estimatedTotalMonthly;
}

/// 房屋信息（1:1 关联 HouseRecord）。
class RoomInfo {
  const RoomInfo({
    this.layout,
    this.area,
    this.floor,
    this.totalFloor,
    this.hasElevator,
    this.orientation,
    this.hasPrivateBathroom,
    this.hasKitchen,
    this.canCook,
    this.canPet,
  });

  /// 房型（单间/一房一厅等）。
  final String? layout;

  /// 面积（平米）。
  final double? area;

  /// 所在楼层。
  final int? floor;

  /// 楼栋总层数。
  final int? totalFloor;

  /// 电梯。
  final bool? hasElevator;

  /// 朝向。
  final String? orientation;

  /// 独卫。
  final bool? hasPrivateBathroom;

  /// 厨房。
  final bool? hasKitchen;

  /// 能否做饭。
  final bool? canCook;

  /// 能否养宠。
  final bool? canPet;
}

/// 联系人信息（1:1 关联 HouseRecord）。phone/wechat/敏感 note 领域层为明文。
class ContactInfo {
  const ContactInfo({
    this.name,
    this.role,
    this.phone,
    this.wechat,
    this.identityVerified,
    this.note,
  });

  /// 称呼。
  final String? name;

  /// 角色（房东/管理员/中介/二房东/未知）。
  final String? role;

  /// 电话（敏感字段，明文）。
  final String? phone;

  /// 微信（敏感字段，明文）。
  final String? wechat;

  /// 身份是否已核验。
  final bool? identityVerified;

  /// 备注（用户标记敏感时加密存储，领域层为明文）。
  final String? note;
}

/// 看房检查项（1:N 关联 HouseRecord）。
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.houseId,
    required this.module,
    required this.key,
    this.value,
    this.note,
  });

  /// UUID 主键。
  final String id;

  /// 关联房源 ID。
  final String houseId;

  /// 模块：room/kitchen/building/contract/risk。
  final String module;

  /// 检查项编码。
  final String key;

  /// 取值：good/ok/bad/not_seen（risk 模块用 hit/not_hit/not_seen）。
  final String? value;

  /// 备注。
  final String? note;
}

/// 风险标记（1:N 关联 HouseRecord）。
class RiskFlag {
  const RiskFlag({
    required this.id,
    required this.houseId,
    required this.key,
    required this.severity,
    this.source = 'user',
    this.note,
  });

  /// UUID 主键。
  final String id;

  /// 关联房源 ID。
  final String houseId;

  /// 风险编码（risk_second_landlord 等）。
  final String key;

  /// 严重度：warning（扣分）/ blocker（硬筛淘汰）。
  final String severity;

  /// 来源：user / system。
  final String source;

  /// 风险说明。
  final String? note;
}

/// 照片资源。文件落端侧，此处存路径与元信息。
class PhotoAsset {
  const PhotoAsset({
    required this.id,
    required this.houseId,
    required this.ownerType,
    required this.ownerId,
    required this.localPath,
    required this.tag,
    required this.takenAt,
    this.exifRemoved = false,
    this.storageProvider = PhotoStorageProvider.local,
    this.remoteUrl,
    this.objectKey,
  });

  /// UUID 主键。
  final String id;

  /// 兼容字段：house 照片关联房源 ID；村/楼栋照片为空。
  final String? houseId;

  /// 归属类型：village/building/house。
  final String ownerType;

  /// 归属对象 id。
  final String ownerId;

  /// 端侧文件路径。
  final String localPath;

  /// 标签：sign/building/room/window/bathroom/meter/contract/damage。
  final String tag;

  /// 拍摄时间（毫秒时间戳）。
  final int takenAt;

  /// 导出时是否去 EXIF。
  final bool exifRemoved;

  /// 存储位置：local（仅端侧）/ oss（已直传对象存储）。默认 local。
  final String storageProvider;

  /// 远端公网可读地址；仅 [storageProvider] 为 oss 时非空。
  final String? remoteUrl;

  /// 远端对象键；仅 [storageProvider] 为 oss 时非空。
  final String? objectKey;
}

/// 地图快照（1:1 关联 HouseRecord）。列表与评分从本地快照读取。
class MapSnapshot {
  const MapSnapshot({
    this.provider = 'amap',
    this.commuteJson,
    this.poiSummaryJson,
    this.userCorrectionJson,
    this.fetchedAt,
  });

  /// 提供方（amap）。
  final String provider;

  /// 通勤路线摘要 JSON。
  final String? commuteJson;

  /// 分半径 POI 统计 JSON。
  final String? poiSummaryJson;

  /// 用户主观修正 JSON。
  final String? userCorrectionJson;

  /// 获取时间（毫秒时间戳）。
  final int? fetchedAt;
}

/// 偏好档案（单条默认 profile）。预算硬筛唯一基准为 maxRentTotal（月总成本，F1）。
class PreferenceProfile {
  const PreferenceProfile({
    required this.id,
    this.maxRentTotal,
    this.maxCommuteMinutes,
    this.destinationsJson,
    this.requiredFeaturesJson,
    this.weightsJson,
    this.preferredCommuteMode,
  });

  /// 默认 profile 主键。
  final String id;

  /// 月总成本上限：预算硬筛唯一基准（F1），非月租口径。
  final int? maxRentTotal;

  /// 最大通勤时间（分钟）。
  final int? maxCommuteMinutes;

  /// 目的地 JSON：`[{id,label,lat,lng,primary}]`（F5）。
  final String? destinationsJson;

  /// 硬性条件 JSON：独卫/厨房/电梯/宠物/楼层/押付。
  final String? requiredFeaturesJson;

  /// 权重 JSON：默认 `{cost:30,commute:20,living:25,nearby:15,risk:10}`（F4）。
  final String? weightsJson;

  /// 首选通勤方式（walking/bicycling/transit/driving）；空则默认 transit（F5）。
  final String? preferredCommuteMode;
}
