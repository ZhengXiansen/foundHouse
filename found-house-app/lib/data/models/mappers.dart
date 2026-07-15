// 领域模型 ↔ Drift 行类/Companion 互转（W1-2 · D1）。
//
// 集中承载映射，使领域模型（house_models.dart）不依赖 drift。
// 敏感字段（roomNo/phone/wechat/note）的加解密统一经 FieldCipher（F7）：
//   - 行 → 领域：解密密文得明文；
//   - 领域 → Companion：加密明文得密文。
// 命名严格对齐字段字典（F9）。

import 'dart:convert';

import 'package:drift/drift.dart';

import '../crypto/field_cipher.dart';
import '../db/app_database.dart' as db;
import 'house_models.dart' as domain;

List<String> _decodeStringList(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const [];
  }
  final decoded = jsonDecode(raw);
  if (decoded is! List<dynamic>) {
    return const [];
  }
  return decoded.whereType<String>().toList(growable: false);
}

String? _encodeStringList(List<String> values) {
  return values.isEmpty ? null : jsonEncode(values);
}

// ---------------------------------------------------------------------------
// Village / Building
// ---------------------------------------------------------------------------

domain.Village villageFromRow(db.Village row) {
  return domain.Village(
    id: row.id,
    name: row.name,
    status: row.status,
    areaNote: row.areaNote,
    commuteMinutes: row.commuteMinutes,
    commuteNote: row.commuteNote,
    surroundingsTags: _decodeStringList(row.surroundingsTagsJson),
    surroundingsScore: row.surroundingsScore,
    environmentScore: row.environmentScore,
    safetyScore: row.safetyScore,
    noiseScore: row.noiseScore,
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lastVisitedAt: row.lastVisitedAt,
  );
}

db.VillagesCompanion villageToCompanion(domain.Village model) {
  return db.VillagesCompanion(
    id: Value(model.id),
    name: Value(model.name),
    status: Value(model.status),
    areaNote: Value(model.areaNote),
    commuteMinutes: Value(model.commuteMinutes),
    commuteNote: Value(model.commuteNote),
    surroundingsTagsJson: Value(_encodeStringList(model.surroundingsTags)),
    surroundingsScore: Value(model.surroundingsScore),
    environmentScore: Value(model.environmentScore),
    safetyScore: Value(model.safetyScore),
    noiseScore: Value(model.noiseScore),
    note: Value(model.note),
    createdAt: Value(model.createdAt),
    updatedAt: Value(model.updatedAt),
    lastVisitedAt: Value(model.lastVisitedAt),
  );
}

domain.Building buildingFromRow(db.Building row) {
  return domain.Building(
    id: row.id,
    villageId: row.villageId,
    name: row.name,
    status: row.status,
    tags: _decodeStringList(row.tagsJson),
    entranceNote: row.entranceNote,
    totalFloor: row.totalFloor,
    hasElevator: row.hasElevator,
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lastVisitedAt: row.lastVisitedAt,
  );
}

db.BuildingsCompanion buildingToCompanion(domain.Building model) {
  return db.BuildingsCompanion(
    id: Value(model.id),
    villageId: Value(model.villageId),
    name: Value(model.name),
    status: Value(model.status),
    tagsJson: Value(_encodeStringList(model.tags)),
    entranceNote: Value(model.entranceNote),
    totalFloor: Value(model.totalFloor),
    hasElevator: Value(model.hasElevator),
    note: Value(model.note),
    createdAt: Value(model.createdAt),
    updatedAt: Value(model.updatedAt),
    lastVisitedAt: Value(model.lastVisitedAt),
  );
}

/// HouseRecord 行 → 领域对象（不含子对象；子对象由仓库按需组装）。
///
/// [roomNo] 为敏感字段，经 [cipher] 解密为明文后填入领域对象。
Future<domain.HouseRecord> houseRecordFromRow(
  db.HouseRecord row,
  FieldCipher cipher, {
  domain.FeeInfo? fee,
  domain.RoomInfo? room,
  domain.ContactInfo? contact,
  domain.MapSnapshot? mapSnapshot,
  List<domain.ChecklistItem> checklistItems = const [],
  List<domain.RiskFlag> riskFlags = const [],
  List<domain.PhotoAsset> photos = const [],
}) async {
  return domain.HouseRecord(
    id: row.id,
    title: row.title,
    status: row.status,
    villageId: row.villageId ?? domain.VillageDefaults.unassignedVillageId,
    buildingId: row.buildingId,
    latitude: row.latitude,
    longitude: row.longitude,
    addressText: row.addressText,
    buildingName: row.buildingName,
    roomNo: await cipher.decrypt(row.roomNo),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    visitedAt: row.visitedAt,
    fee: fee,
    room: room,
    contact: contact,
    mapSnapshot: mapSnapshot,
    checklistItems: checklistItems,
    riskFlags: riskFlags,
    photos: photos,
  );
}

/// HouseRecord 领域对象 → 主表 Companion（仅主表字段，不含子表）。
///
/// [roomNo] 经 [cipher] 加密为密文后落库。
Future<db.HouseRecordsCompanion> houseRecordToCompanion(
  domain.HouseRecord model,
  FieldCipher cipher,
) async {
  return db.HouseRecordsCompanion(
    id: Value(model.id),
    title: Value(model.title),
    status: Value(model.status),
    villageId: Value(model.villageId),
    buildingId: Value(model.buildingId),
    latitude: Value(model.latitude),
    longitude: Value(model.longitude),
    addressText: Value(model.addressText),
    buildingName: Value(model.buildingName),
    roomNo: Value(await cipher.encrypt(model.roomNo)),
    createdAt: Value(model.createdAt),
    updatedAt: Value(model.updatedAt),
    visitedAt: Value(model.visitedAt),
  );
}

// ---------------------------------------------------------------------------
// FeeInfo
// ---------------------------------------------------------------------------

domain.FeeInfo feeInfoFromRow(db.FeeInfo row) {
  return domain.FeeInfo(
    rentMonthly: row.rentMonthly,
    deposit: row.deposit,
    paymentCycle: row.paymentCycle,
    managementFee: row.managementFee,
    internetFee: row.internetFee,
    waterUnitPrice: row.waterUnitPrice,
    electricityUnitPrice: row.electricityUnitPrice,
    gasFee: row.gasFee,
    otherFee: row.otherFee,
    estimatedTotalMonthly: row.estimatedTotalMonthly,
  );
}

db.FeeInfosCompanion feeInfoToCompanion(String houseId, domain.FeeInfo model) {
  return db.FeeInfosCompanion(
    houseId: Value(houseId),
    rentMonthly: Value(model.rentMonthly),
    deposit: Value(model.deposit),
    paymentCycle: Value(model.paymentCycle),
    managementFee: Value(model.managementFee),
    internetFee: Value(model.internetFee),
    waterUnitPrice: Value(model.waterUnitPrice),
    electricityUnitPrice: Value(model.electricityUnitPrice),
    gasFee: Value(model.gasFee),
    otherFee: Value(model.otherFee),
    estimatedTotalMonthly: Value(model.estimatedTotalMonthly),
  );
}

// ---------------------------------------------------------------------------
// RoomInfo
// ---------------------------------------------------------------------------

domain.RoomInfo roomInfoFromRow(db.RoomInfo row) {
  return domain.RoomInfo(
    layout: row.layout,
    area: row.area,
    floor: row.floor,
    totalFloor: row.totalFloor,
    hasElevator: row.hasElevator,
    orientation: row.orientation,
    hasPrivateBathroom: row.hasPrivateBathroom,
    hasKitchen: row.hasKitchen,
    canCook: row.canCook,
    canPet: row.canPet,
  );
}

db.RoomInfosCompanion roomInfoToCompanion(
  String houseId,
  domain.RoomInfo model,
) {
  return db.RoomInfosCompanion(
    houseId: Value(houseId),
    layout: Value(model.layout),
    area: Value(model.area),
    floor: Value(model.floor),
    totalFloor: Value(model.totalFloor),
    hasElevator: Value(model.hasElevator),
    orientation: Value(model.orientation),
    hasPrivateBathroom: Value(model.hasPrivateBathroom),
    hasKitchen: Value(model.hasKitchen),
    canCook: Value(model.canCook),
    canPet: Value(model.canPet),
  );
}

// ---------------------------------------------------------------------------
// ContactInfo（phone/wechat/note 敏感，经 FieldCipher）
// ---------------------------------------------------------------------------

Future<domain.ContactInfo> contactInfoFromRow(
  db.ContactInfo row,
  FieldCipher cipher,
) async {
  return domain.ContactInfo(
    name: row.name,
    role: row.role,
    phone: await cipher.decrypt(row.phone),
    wechat: await cipher.decrypt(row.wechat),
    identityVerified: row.identityVerified,
    note: await cipher.decrypt(row.note),
  );
}

Future<db.ContactInfosCompanion> contactInfoToCompanion(
  String houseId,
  domain.ContactInfo model,
  FieldCipher cipher,
) async {
  return db.ContactInfosCompanion(
    houseId: Value(houseId),
    name: Value(model.name),
    role: Value(model.role),
    phone: Value(await cipher.encrypt(model.phone)),
    wechat: Value(await cipher.encrypt(model.wechat)),
    identityVerified: Value(model.identityVerified),
    note: Value(await cipher.encrypt(model.note)),
  );
}

// ---------------------------------------------------------------------------
// ChecklistItem
// ---------------------------------------------------------------------------

domain.ChecklistItem checklistItemFromRow(db.ChecklistItem row) {
  return domain.ChecklistItem(
    id: row.id,
    houseId: row.houseId,
    module: row.module,
    key: row.key,
    value: row.value,
    note: row.note,
  );
}

db.ChecklistItemsCompanion checklistItemToCompanion(
  domain.ChecklistItem model,
) {
  return db.ChecklistItemsCompanion(
    id: Value(model.id),
    houseId: Value(model.houseId),
    module: Value(model.module),
    key: Value(model.key),
    value: Value(model.value),
    note: Value(model.note),
  );
}

// ---------------------------------------------------------------------------
// RiskFlag
// ---------------------------------------------------------------------------

domain.RiskFlag riskFlagFromRow(db.RiskFlag row) {
  return domain.RiskFlag(
    id: row.id,
    houseId: row.houseId,
    key: row.key,
    severity: row.severity,
    source: row.source,
    note: row.note,
  );
}

db.RiskFlagsCompanion riskFlagToCompanion(domain.RiskFlag model) {
  return db.RiskFlagsCompanion(
    id: Value(model.id),
    houseId: Value(model.houseId),
    key: Value(model.key),
    severity: Value(model.severity),
    source: Value(model.source),
    note: Value(model.note),
  );
}

// ---------------------------------------------------------------------------
// PhotoAsset
// ---------------------------------------------------------------------------

domain.PhotoAsset photoAssetFromRow(db.PhotoAsset row) {
  return domain.PhotoAsset(
    id: row.id,
    houseId: row.houseId,
    ownerType: row.ownerType,
    ownerId: row.ownerId,
    localPath: row.localPath,
    tag: row.tag,
    takenAt: row.takenAt,
    exifRemoved: row.exifRemoved,
    storageProvider: row.storageProvider,
    remoteUrl: row.remoteUrl,
    objectKey: row.objectKey,
  );
}

db.PhotoAssetsCompanion photoAssetToCompanion(domain.PhotoAsset model) {
  return db.PhotoAssetsCompanion(
    id: Value(model.id),
    houseId: Value(model.houseId),
    ownerType: Value(model.ownerType),
    ownerId: Value(model.ownerId),
    localPath: Value(model.localPath),
    tag: Value(model.tag),
    takenAt: Value(model.takenAt),
    exifRemoved: Value(model.exifRemoved),
    storageProvider: Value(model.storageProvider),
    remoteUrl: Value(model.remoteUrl),
    objectKey: Value(model.objectKey),
  );
}

// ---------------------------------------------------------------------------
// MapSnapshot
// ---------------------------------------------------------------------------

domain.MapSnapshot mapSnapshotFromRow(db.MapSnapshot row) {
  return domain.MapSnapshot(
    provider: row.provider,
    commuteJson: row.commuteJson,
    poiSummaryJson: row.poiSummaryJson,
    userCorrectionJson: row.userCorrectionJson,
    fetchedAt: row.fetchedAt,
  );
}

db.MapSnapshotsCompanion mapSnapshotToCompanion(
  String houseId,
  domain.MapSnapshot model,
) {
  return db.MapSnapshotsCompanion(
    houseId: Value(houseId),
    provider: Value(model.provider),
    commuteJson: Value(model.commuteJson),
    poiSummaryJson: Value(model.poiSummaryJson),
    userCorrectionJson: Value(model.userCorrectionJson),
    fetchedAt: Value(model.fetchedAt),
  );
}

// ---------------------------------------------------------------------------
// PreferenceProfile（无敏感字段）
// ---------------------------------------------------------------------------

domain.PreferenceProfile preferenceProfileFromRow(db.PreferenceProfile row) {
  return domain.PreferenceProfile(
    id: row.id,
    maxRentTotal: row.maxRentTotal,
    maxCommuteMinutes: row.maxCommuteMinutes,
    destinationsJson: row.destinationsJson,
    requiredFeaturesJson: row.requiredFeaturesJson,
    weightsJson: row.weightsJson,
    preferredCommuteMode: row.preferredCommuteMode,
  );
}

db.PreferenceProfilesCompanion preferenceProfileToCompanion(
  domain.PreferenceProfile model,
) {
  return db.PreferenceProfilesCompanion(
    id: Value(model.id),
    maxRentTotal: Value(model.maxRentTotal),
    maxCommuteMinutes: Value(model.maxCommuteMinutes),
    destinationsJson: Value(model.destinationsJson),
    requiredFeaturesJson: Value(model.requiredFeaturesJson),
    weightsJson: Value(model.weightsJson),
    preferredCommuteMode: Value(model.preferredCommuteMode),
  );
}
