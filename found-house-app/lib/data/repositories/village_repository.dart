// 村/楼栋仓库（V0.2 手动扫楼流程）。
//
// 封装 Village / Building / owner-aware PhotoAsset 的读写与统计查询。
// HouseRecord 的具体房源 CRUD 仍由 HouseRepository 负责；本仓库只提供
// 村、楼栋、聚合统计和非房源照片归属能力。

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../local_files/photo_store.dart';
import '../models/house_models.dart' as domain;
import '../models/mappers.dart' as m;

export '../models/house_models.dart'
    show BuildingStatus, PhotoOwnerType, VillageStatus;

/// 村 / 楼栋读写仓库。
class VillageRepository {
  VillageRepository({
    required AppDatabase db,
    required PhotoStore photoStore,
    Uuid? uuid,
  })  : _db = db,
        _photoStore = photoStore,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final PhotoStore _photoStore;
  final Uuid _uuid;

  static const String unassignedVillageId =
      domain.VillageDefaults.unassignedVillageId;

  // -------------------------------------------------------------------------
  // Village
  // -------------------------------------------------------------------------

  Future<String> createVillage({
    required String name,
    String status = domain.VillageStatus.preparing,
    String? areaNote,
    int? commuteMinutes,
    String? commuteNote,
    List<String> surroundingsTags = const [],
    int? surroundingsScore,
    int? environmentScore,
    int? safetyScore,
    int? noiseScore,
    String? note,
    int? createdAt,
    int? updatedAt,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final ts = createdAt ?? now;
    await _db.into(_db.villages).insert(
          VillagesCompanion.insert(
            id: id,
            name: name,
            status: Value(status),
            areaNote: Value(areaNote),
            commuteMinutes: Value(commuteMinutes),
            commuteNote: Value(commuteNote),
            surroundingsTagsJson: Value(_encodeStringList(surroundingsTags)),
            surroundingsScore: Value(surroundingsScore),
            environmentScore: Value(environmentScore),
            safetyScore: Value(safetyScore),
            noiseScore: Value(noiseScore),
            note: Value(note),
            createdAt: ts,
            updatedAt: updatedAt ?? ts,
          ),
        );
    return id;
  }

  Future<void> ensureUnassignedVillage() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.into(_db.villages).insert(
          VillagesCompanion.insert(
            id: unassignedVillageId,
            name: '未分组',
            status: const Value(domain.VillageStatus.preparing),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<domain.Village?> getById(String id) async {
    final row = await (_db.select(_db.villages)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : m.villageFromRow(row);
  }

  Future<List<domain.VillageWithStats>> getVillagesWithStats() async {
    final rows = await (_db.select(_db.villages)
          ..orderBy([
            (t) => OrderingTerm.desc(t.lastVisitedAt),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
    final result = <domain.VillageWithStats>[];
    for (final row in rows) {
      result.add(await _statsForVillageRow(row));
    }
    return result;
  }

  Stream<List<domain.VillageWithStats>> watchVillagesWithStats() {
    final query = _db.select(_db.villages)
      ..orderBy([
        (t) => OrderingTerm.desc(t.lastVisitedAt),
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);
    return query.watch().asyncMap((rows) async {
      final result = <domain.VillageWithStats>[];
      for (final row in rows) {
        result.add(await _statsForVillageRow(row));
      }
      return result;
    });
  }

  Future<domain.VillageWithStats?> getVillageWithStats(String villageId) async {
    final row = await (_db.select(_db.villages)
          ..where((t) => t.id.equals(villageId)))
        .getSingleOrNull();
    if (row == null) return null;
    return _statsForVillageRow(row);
  }

  /// Watch 覆盖 village / building / house_record 三张表，避免只 watch 主表
  /// 导致子表变化后的统计 stale（见 .ccg/spec/guides）。
  Stream<domain.VillageWithStats?> watchVillageWithStats(String villageId) {
    return _db
        .customSelect(
          'SELECT 1 AS tick',
          readsFrom: {_db.villages, _db.buildings, _db.houseRecords},
        )
        .watch()
        .asyncMap((_) => getVillageWithStats(villageId));
  }

  /// 删除村及其楼栋、房源和照片。
  ///
  /// 由于 HouseRecord 对 village/building 的外键均为 setNull，不能依赖 DB
  /// cascade；删除村时需要先显式删除村内全部房源，再删楼栋、村和
  /// owner-aware 照片元信息。
  Future<void> deleteVillage(String villageId) async {
    final village = await (_db.select(_db.villages)
          ..where((t) => t.id.equals(villageId)))
        .getSingleOrNull();
    if (village == null) return;

    final buildingRows = await (_db.select(_db.buildings)
          ..where((t) => t.villageId.equals(villageId)))
        .get();
    final buildingIds =
        buildingRows.map((row) => row.id).toList(growable: false);
    final houseRows = await (_db.select(_db.houseRecords)
          ..where((t) => t.villageId.equals(villageId)))
        .get();
    final houseIds = houseRows.map((row) => row.id).toList(growable: false);

    for (final houseId in houseIds) {
      await _photoStore.deleteByHouse(houseId);
      await _photoStore.deleteByOwner(domain.PhotoOwnerType.house, houseId);
    }
    for (final buildingId in buildingIds) {
      await _photoStore.deleteByOwner(
        domain.PhotoOwnerType.building,
        buildingId,
      );
    }
    await _photoStore.deleteByOwner(domain.PhotoOwnerType.village, villageId);

    await _db.transaction(() async {
      await (_db.delete(_db.photoAssets)
            ..where(
              (t) =>
                  t.ownerType.equals(domain.PhotoOwnerType.village) &
                  t.ownerId.equals(villageId),
            ))
          .go();
      if (buildingIds.isNotEmpty) {
        await (_db.delete(_db.photoAssets)
              ..where(
                (t) =>
                    t.ownerType.equals(domain.PhotoOwnerType.building) &
                    t.ownerId.isIn(buildingIds),
              ))
            .go();
      }
      if (houseIds.isNotEmpty) {
        await (_db.delete(_db.houseRecords)..where((t) => t.id.isIn(houseIds)))
            .go();
      }
      await (_db.delete(_db.buildings)
            ..where((t) => t.villageId.equals(villageId)))
          .go();
      await (_db.delete(_db.villages)..where((t) => t.id.equals(villageId)))
          .go();
    });
  }

  // -------------------------------------------------------------------------
  // Building
  // -------------------------------------------------------------------------

  Future<String> createBuilding({
    required String villageId,
    required String name,
    String status = domain.BuildingStatus.notScouted,
    List<String> tags = const [],
    String? entranceNote,
    int? totalFloor,
    bool? hasElevator,
    String? note,
    int? createdAt,
    int? updatedAt,
  }) async {
    await _requireVillage(villageId);
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final ts = createdAt ?? now;
    await _db.transaction(() async {
      await _db.into(_db.buildings).insert(
            BuildingsCompanion.insert(
              id: id,
              villageId: villageId,
              name: name,
              status: Value(status),
              tagsJson: Value(_encodeStringList(tags)),
              entranceNote: Value(entranceNote),
              totalFloor: Value(totalFloor),
              hasElevator: Value(hasElevator),
              note: Value(note),
              createdAt: ts,
              updatedAt: updatedAt ?? ts,
            ),
          );
      await _touchVillage(villageId);
    });
    return id;
  }

  Future<domain.Building?> getBuildingById(String id) async {
    final row = await (_db.select(_db.buildings)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : m.buildingFromRow(row);
  }

  Future<List<domain.Building>> getBuildingsForVillage(String villageId) async {
    final rows = await (_db.select(_db.buildings)
          ..where((t) => t.villageId.equals(villageId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.lastVisitedAt),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
    return rows.map(m.buildingFromRow).toList(growable: false);
  }

  Stream<List<domain.Building>> watchBuildingsForVillage(String villageId) {
    final query = _db.select(_db.buildings)
      ..where((t) => t.villageId.equals(villageId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.lastVisitedAt),
        (t) => OrderingTerm.desc(t.updatedAt),
      ]);
    return query.watch().map(
          (rows) => rows.map(m.buildingFromRow).toList(growable: false),
        );
  }

  /// 删除楼栋及其名下房源。
  ///
  /// HouseRecord 的 villageId/buildingId 外键是 setNull，为避免删除楼栋后
  /// 房源变成孤儿，这里显式删除该楼栋下的房源、房源照片目录，以及楼栋
  /// owner-aware 照片元信息/目录。
  Future<void> deleteBuilding(String buildingId) async {
    final building = await (_db.select(_db.buildings)
          ..where((t) => t.id.equals(buildingId)))
        .getSingleOrNull();
    if (building == null) return;

    final houseRows = await (_db.select(_db.houseRecords)
          ..where((t) => t.buildingId.equals(buildingId)))
        .get();
    final houseIds = houseRows.map((row) => row.id).toList(growable: false);

    for (final houseId in houseIds) {
      await _photoStore.deleteByHouse(houseId);
      await _photoStore.deleteByOwner(domain.PhotoOwnerType.house, houseId);
    }
    await _photoStore.deleteByOwner(
      domain.PhotoOwnerType.building,
      buildingId,
    );

    await _db.transaction(() async {
      if (houseIds.isNotEmpty) {
        await (_db.delete(_db.houseRecords)..where((t) => t.id.isIn(houseIds)))
            .go();
      }
      await (_db.delete(_db.photoAssets)
            ..where(
              (t) =>
                  t.ownerType.equals(domain.PhotoOwnerType.building) &
                  t.ownerId.equals(buildingId),
            ))
          .go();
      await (_db.delete(_db.buildings)..where((t) => t.id.equals(buildingId)))
          .go();
      await _touchVillage(building.villageId);
    });
  }

  /// 仅当楼栋仍为空时删除它，用于快速记录创建房源失败后的新楼栋回滚。
  ///
  /// 与 [deleteBuilding] 不同，本方法不会级联删除房源；如果楼栋下已经
  /// 出现房源，则返回 false 并保留楼栋，避免回滚过程误删已有数据。
  Future<bool> deleteBuildingIfEmpty(String buildingId) async {
    final deleted = await _db.transaction(() async {
      final building = await (_db.select(_db.buildings)
            ..where((t) => t.id.equals(buildingId)))
          .getSingleOrNull();
      if (building == null) return false;

      final occupied = await (_db.select(_db.houseRecords)
            ..where((t) => t.buildingId.equals(buildingId))
            ..limit(1))
          .getSingleOrNull();
      if (occupied != null) return false;

      await (_db.delete(_db.photoAssets)
            ..where(
              (t) =>
                  t.ownerType.equals(domain.PhotoOwnerType.building) &
                  t.ownerId.equals(buildingId),
            ))
          .go();
      await (_db.delete(_db.buildings)..where((t) => t.id.equals(buildingId)))
          .go();
      await _touchVillage(building.villageId);
      return true;
    });

    if (deleted) {
      await _photoStore.deleteByOwner(
        domain.PhotoOwnerType.building,
        buildingId,
      );
    }
    return deleted;
  }

  Future<void> updateBuildingStatus(
    String buildingId, {
    required String status,
    List<String>? tags,
    String? note,
  }) async {
    final row = await (_db.select(_db.buildings)
          ..where((t) => t.id.equals(buildingId)))
        .getSingleOrNull();
    if (row == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      await (_db.update(_db.buildings)..where((t) => t.id.equals(buildingId)))
          .write(
        BuildingsCompanion(
          status: Value(status),
          tagsJson: tags == null
              ? const Value.absent()
              : Value(_encodeStringList(tags)),
          note: note == null ? const Value.absent() : Value(note),
          updatedAt: Value(now),
          lastVisitedAt: Value(now),
        ),
      );
      await _touchVillage(row.villageId);
    });
  }

  // -------------------------------------------------------------------------
  // PhotoAsset：owner-aware 元信息
  // -------------------------------------------------------------------------

  Future<String> addPhotoAsset({
    required String ownerType,
    required String ownerId,
    required String localPath,
    required String tag,
    int? takenAt,
    bool exifRemoved = false,
  }) async {
    if (!PhotoTag.isValid(tag)) {
      throw ArgumentError.value(tag, 'tag', '非法照片标签');
    }
    await _requireOwner(ownerType: ownerType, ownerId: ownerId);

    final id = _uuid.v4();
    final houseId = ownerType == domain.PhotoOwnerType.house ? ownerId : null;
    await _db.transaction(() async {
      await _db.into(_db.photoAssets).insert(
            PhotoAssetsCompanion.insert(
              id: id,
              houseId: Value(houseId),
              ownerType: Value(ownerType),
              ownerId: ownerId,
              localPath: localPath,
              tag: tag,
              takenAt: takenAt ?? DateTime.now().millisecondsSinceEpoch,
              exifRemoved: Value(exifRemoved),
            ),
          );
      await _touchOwner(ownerType: ownerType, ownerId: ownerId);
    });
    return id;
  }

  Future<List<domain.PhotoAsset>> getPhotosForOwner({
    required String ownerType,
    required String ownerId,
  }) async {
    final rows = await (_db.select(_db.photoAssets)
          ..where(
            (t) => t.ownerType.equals(ownerType) & t.ownerId.equals(ownerId),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]))
        .get();
    return rows.map(m.photoAssetFromRow).toList(growable: false);
  }

  Future<void> deletePhotoAsset(String id) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.photoAssets)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      await _photoStore.deleteFile(row.localPath);
      await (_db.delete(_db.photoAssets)..where((t) => t.id.equals(id))).go();
      await _touchOwner(ownerType: row.ownerType, ownerId: row.ownerId);
    });
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<domain.VillageWithStats> _statsForVillageRow(Village row) async {
    final villageId = row.id;
    final buildingCount = await _countBuildings((t) {
      return t.villageId.equals(villageId);
    });
    final houseCount = await _countHouses((t) {
      return t.villageId.equals(villageId);
    });
    final shortlistedCount = await _countHouses((t) {
      return t.villageId.equals(villageId) & t.status.equals('shortlisted');
    });
    final revisitBuildingCount = await _countBuildings((t) {
      return t.villageId.equals(villageId) &
          t.status.equals(domain.BuildingStatus.needsRevisit);
    });
    final unassignedHouseCount = await _countHouses((t) {
      return t.villageId.equals(villageId) & t.buildingId.isNull();
    });
    return domain.VillageWithStats(
      village: m.villageFromRow(row),
      buildingCount: buildingCount,
      houseCount: houseCount,
      shortlistedCount: shortlistedCount,
      revisitCount: revisitBuildingCount,
      unassignedHouseCount: unassignedHouseCount,
    );
  }

  Future<int> _countBuildings(
    Expression<bool> Function($BuildingsTable table) predicate,
  ) async {
    final countExp = _db.buildings.id.count();
    final query = _db.selectOnly(_db.buildings)..addColumns([countExp]);
    query.where(predicate(_db.buildings));
    return query.map((row) => row.read(countExp) ?? 0).getSingle();
  }

  Future<int> _countHouses(
    Expression<bool> Function($HouseRecordsTable table) predicate,
  ) async {
    final countExp = _db.houseRecords.id.count();
    final query = _db.selectOnly(_db.houseRecords)..addColumns([countExp]);
    query.where(predicate(_db.houseRecords));
    return query.map((row) => row.read(countExp) ?? 0).getSingle();
  }

  Future<void> _requireVillage(String villageId) async {
    final exists = await (_db.select(_db.villages)
          ..where((t) => t.id.equals(villageId)))
        .getSingleOrNull();
    if (exists == null) {
      throw ArgumentError.value(villageId, 'villageId', '村不存在');
    }
  }

  Future<void> _requireOwner({
    required String ownerType,
    required String ownerId,
  }) async {
    switch (ownerType) {
      case domain.PhotoOwnerType.village:
        await _requireVillage(ownerId);
        return;
      case domain.PhotoOwnerType.building:
        final building = await getBuildingById(ownerId);
        if (building == null) {
          throw ArgumentError.value(ownerId, 'ownerId', '楼栋不存在');
        }
        return;
      case domain.PhotoOwnerType.house:
        final house = await (_db.select(_db.houseRecords)
              ..where((t) => t.id.equals(ownerId)))
            .getSingleOrNull();
        if (house == null) {
          throw ArgumentError.value(ownerId, 'ownerId', '房源不存在');
        }
        return;
      default:
        throw ArgumentError.value(ownerType, 'ownerType', '非法照片归属类型');
    }
  }

  Future<void> _touchOwner({
    required String ownerType,
    required String ownerId,
  }) async {
    switch (ownerType) {
      case domain.PhotoOwnerType.village:
        await _touchVillage(ownerId);
        return;
      case domain.PhotoOwnerType.building:
        final building = await (_db.select(_db.buildings)
              ..where((t) => t.id.equals(ownerId)))
            .getSingleOrNull();
        if (building == null) return;
        await _touchBuilding(ownerId);
        await _touchVillage(building.villageId);
        return;
      case domain.PhotoOwnerType.house:
        final house = await (_db.select(_db.houseRecords)
              ..where((t) => t.id.equals(ownerId)))
            .getSingleOrNull();
        if (house == null) return;
        final now = DateTime.now().millisecondsSinceEpoch;
        await (_db.update(_db.houseRecords)..where((t) => t.id.equals(ownerId)))
            .write(HouseRecordsCompanion(updatedAt: Value(now)));
        final villageId = house.villageId;
        if (villageId != null) await _touchVillage(villageId);
        final buildingId = house.buildingId;
        if (buildingId != null) await _touchBuilding(buildingId);
        return;
    }
  }

  Future<void> _touchVillage(String villageId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.villages)..where((t) => t.id.equals(villageId)))
        .write(
      VillagesCompanion(
        updatedAt: Value(now),
        lastVisitedAt: Value(now),
      ),
    );
  }

  Future<void> _touchBuilding(String buildingId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.buildings)..where((t) => t.id.equals(buildingId)))
        .write(
      BuildingsCompanion(
        updatedAt: Value(now),
        lastVisitedAt: Value(now),
      ),
    );
  }
}

String? _encodeStringList(List<String> values) {
  return values.isEmpty ? null : jsonEncode(values);
}
