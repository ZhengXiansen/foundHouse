// 房源仓库（W1-2 · D2，技术方案 §8「HouseRepository 只负责读写，不含评分」）。
//
// 封装 HouseRecord 及其关联表（FeeInfo/RoomInfo/ContactInfo/ChecklistItem/
// RiskFlag/PhotoAsset/MapSnapshot）的 CRUD 与查询，返回领域对象（house_models.dart）。
//
// 关键约束：
// - 只读写，不含评分/硬筛业务逻辑（那是 FilterEngine/ScoreEngine）。
// - 敏感字段（roomNo/phone/wechat/note）读写统一经 [FieldCipher]（F7），
//   页面不直接读写密文。
// - 删除房源时子表随外键 cascade 删除，照片文件另经 PhotoStore 清理（W5 · H3）。

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../integrations/oss/oss_photo_uploader.dart';
import '../crypto/field_cipher.dart';
import '../db/app_database.dart';
import '../local_files/photo_store.dart';
import '../models/house_models.dart' as domain;
import '../models/mappers.dart' as m;

/// 房源读写仓库。依赖注入 [AppDatabase] + [FieldCipher] + [PhotoStore]。
///
/// [uploader] 为可选的照片对象存储直传实现，缺省 [OfflinePhotoUploader]
/// （未配置云上传，纯本地存储）。生产由 provider 按 signer 配置注入 OSS 实现。
class HouseRepository {
  HouseRepository({
    required AppDatabase db,
    required FieldCipher cipher,
    required PhotoStore photoStore,
    PhotoUploader uploader = const OfflinePhotoUploader(),
    Uuid? uuid,
  })  : _db = db,
        _cipher = cipher,
        _photoStore = photoStore,
        _uploader = uploader,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final FieldCipher _cipher;
  final PhotoStore _photoStore;
  final PhotoUploader _uploader;
  final Uuid _uuid;

  static const String _unassignedVillageId =
      domain.VillageDefaults.unassignedVillageId;

  Future<void> _ensureUnassignedVillage() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.into(_db.villages).insert(
          VillagesCompanion.insert(
            id: _unassignedVillageId,
            name: '未分组',
            status: const Value(domain.VillageStatus.preparing),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _validateBuildingBelongsToVillage({
    required String villageId,
    required String? buildingId,
  }) async {
    if (buildingId == null) return;
    final building = await (_db.select(_db.buildings)
          ..where((t) => t.id.equals(buildingId)))
        .getSingleOrNull();
    if (building == null) {
      throw ArgumentError.value(buildingId, 'buildingId', '楼栋不存在');
    }
    if (building.villageId != villageId) {
      throw ArgumentError.value(buildingId, 'buildingId', '楼栋不属于指定村');
    }
  }

  Future<void> _touchVillage(String villageId) async {
    await (_db.update(_db.villages)..where((t) => t.id.equals(villageId)))
        .write(
      VillagesCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        lastVisitedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> _touchBuilding(String buildingId) async {
    await (_db.update(_db.buildings)..where((t) => t.id.equals(buildingId)))
        .write(
      BuildingsCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        lastVisitedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 创建
  // -------------------------------------------------------------------------

  /// 新建房源：生成 uuid、写主表与已给出的 1:1 子表，返回新房源 id。
  ///
  /// [createdAt]/[updatedAt] 缺省取当前时间；子对象为空则不写对应子表。
  /// 敏感字段经 [FieldCipher] 加密后落库。
  Future<String> create({
    required String title,
    String status = 'draft',
    String? villageId,
    String? buildingId,
    double? latitude,
    double? longitude,
    String? addressText,
    String? buildingName,
    String? roomNo,
    int? visitedAt,
    domain.FeeInfo? fee,
    domain.RoomInfo? room,
    domain.ContactInfo? contact,
    int? createdAt,
    int? updatedAt,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final ts = createdAt ?? now;
    final resolvedVillageId = villageId ?? _unassignedVillageId;
    final encryptedRoomNo = await _cipher.encrypt(roomNo);

    if (resolvedVillageId == _unassignedVillageId) {
      await _ensureUnassignedVillage();
    }
    await _validateBuildingBelongsToVillage(
      villageId: resolvedVillageId,
      buildingId: buildingId,
    );

    await _db.transaction(() async {
      await _db.into(_db.houseRecords).insert(
            HouseRecordsCompanion.insert(
              id: id,
              title: title,
              status: Value(status),
              villageId: Value(resolvedVillageId),
              buildingId: Value(buildingId),
              latitude: Value(latitude),
              longitude: Value(longitude),
              addressText: Value(addressText),
              buildingName: Value(buildingName),
              roomNo: Value(encryptedRoomNo),
              createdAt: ts,
              updatedAt: updatedAt ?? ts,
              visitedAt: Value(visitedAt),
            ),
          );

      if (fee != null) {
        await _db.into(_db.feeInfos).insert(m.feeInfoToCompanion(id, fee));
      }
      if (room != null) {
        await _db.into(_db.roomInfos).insert(m.roomInfoToCompanion(id, room));
      }
      if (contact != null) {
        await _db
            .into(_db.contactInfos)
            .insert(await m.contactInfoToCompanion(id, contact, _cipher));
      }
      await _touchVillage(resolvedVillageId);
      if (buildingId != null) {
        await _touchBuilding(buildingId);
      }
    });

    return id;
  }

  // -------------------------------------------------------------------------
  // 分区更新
  // -------------------------------------------------------------------------

  /// 更新主表字段（部分字段用 [Value.absent] 保持不变）。同时刷新 updatedAt。
  Future<void> updateMain(
    String houseId, {
    Value<String> title = const Value.absent(),
    Value<String> status = const Value.absent(),
    Value<String> villageId = const Value.absent(),
    Value<String?> buildingId = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> addressText = const Value.absent(),
    Value<String?> buildingName = const Value.absent(),
    Value<String?> roomNo = const Value.absent(),
    Value<int?> visitedAt = const Value.absent(),
  }) async {
    final current = await (_db.select(_db.houseRecords)
          ..where((t) => t.id.equals(houseId)))
        .getSingleOrNull();
    if (current == null) return;

    final resolvedVillageId = villageId.present
        ? villageId.value
        : current.villageId ?? _unassignedVillageId;
    final resolvedBuildingId =
        buildingId.present ? buildingId.value : current.buildingId;
    if (resolvedVillageId == _unassignedVillageId) {
      await _ensureUnassignedVillage();
    }
    await _validateBuildingBelongsToVillage(
      villageId: resolvedVillageId,
      buildingId: resolvedBuildingId,
    );

    final encryptedRoomNo = roomNo.present
        ? Value(await _cipher.encrypt(roomNo.value))
        : const Value<String?>.absent();
    final companion = HouseRecordsCompanion(
      title: title,
      status: status,
      villageId: villageId.present
          ? Value<String?>(villageId.value)
          : const Value<String?>.absent(),
      buildingId: buildingId,
      latitude: latitude,
      longitude: longitude,
      addressText: addressText,
      buildingName: buildingName,
      // roomNo 敏感：present 时加密其明文；absent 保持不变。
      roomNo: encryptedRoomNo,
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      visitedAt: visitedAt,
    );
    await _db.transaction(() async {
      await (_db.update(_db.houseRecords)..where((t) => t.id.equals(houseId)))
          .write(companion);
      await _touchVillage(resolvedVillageId);
      if (resolvedBuildingId != null) {
        await _touchBuilding(resolvedBuildingId);
      }
    });
  }

  /// upsert 费用信息（1:1）。写入后刷新主表 updatedAt。
  Future<void> updateFee(String houseId, domain.FeeInfo fee) async {
    await _db.transaction(() async {
      await _db
          .into(_db.feeInfos)
          .insertOnConflictUpdate(m.feeInfoToCompanion(houseId, fee));
      await _touch(houseId);
    });
  }

  /// upsert 房屋信息（1:1）。
  Future<void> updateRoom(String houseId, domain.RoomInfo room) async {
    await _db.transaction(() async {
      await _db
          .into(_db.roomInfos)
          .insertOnConflictUpdate(m.roomInfoToCompanion(houseId, room));
      await _touch(houseId);
    });
  }

  /// upsert 联系人信息（1:1）。phone/wechat/note 敏感，经 FieldCipher 加密。
  Future<void> updateContact(String houseId, domain.ContactInfo contact) async {
    await _db.transaction(() async {
      await _db.into(_db.contactInfos).insertOnConflictUpdate(
            await m.contactInfoToCompanion(houseId, contact, _cipher),
          );
      await _touch(houseId);
    });
  }

  /// upsert 地图快照（1:1）。地图结果先落本地快照，列表与评分从此读取。
  Future<void> updateMapSnapshot(
    String houseId,
    domain.MapSnapshot snapshot,
  ) async {
    await _db.transaction(() async {
      await _db.into(_db.mapSnapshots).insertOnConflictUpdate(
            m.mapSnapshotToCompanion(houseId, snapshot),
          );
      await _touch(houseId);
    });
  }

  /// 刷新主表 updatedAt 为当前时间。
  Future<void> _touch(String houseId) async {
    final row = await (_db.select(_db.houseRecords)
          ..where((t) => t.id.equals(houseId)))
        .getSingleOrNull();
    await (_db.update(_db.houseRecords)..where((t) => t.id.equals(houseId)))
        .write(
      HouseRecordsCompanion(
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    final villageId = row?.villageId;
    if (villageId != null) {
      await _touchVillage(villageId);
    }
    final buildingId = row?.buildingId;
    if (buildingId != null) {
      await _touchBuilding(buildingId);
    }
  }

  // -------------------------------------------------------------------------
  // ChecklistItem 增删查
  // -------------------------------------------------------------------------

  /// 新增检查项，返回生成的 id，并刷新主表 updatedAt 以驱动聚合流。
  Future<String> addChecklistItem(
    String houseId, {
    required String module,
    required String key,
    String? value,
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.checklistItems).insert(
            ChecklistItemsCompanion.insert(
              id: id,
              houseId: houseId,
              module: module,
              key: key,
              value: Value(value),
              note: Value(note),
            ),
          );
      await _touch(houseId);
    });
    return id;
  }

  /// 更新检查项取值/备注，并刷新主表 updatedAt 以驱动聚合流。
  Future<void> updateChecklistItem(
    String id, {
    Value<String?> value = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.checklistItems)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      await (_db.update(_db.checklistItems)..where((t) => t.id.equals(id)))
          .write(ChecklistItemsCompanion(value: value, note: note));
      await _touch(row.houseId);
    });
  }

  /// 删除检查项，并刷新主表 updatedAt 以驱动聚合流。
  Future<void> deleteChecklistItem(String id) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.checklistItems)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      await (_db.delete(_db.checklistItems)..where((t) => t.id.equals(id)))
          .go();
      await _touch(row.houseId);
    });
  }

  /// 查某房源的全部检查项。
  Future<List<domain.ChecklistItem>> getChecklistItems(String houseId) async {
    final rows = await (_db.select(_db.checklistItems)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    return rows.map(m.checklistItemFromRow).toList();
  }

  // -------------------------------------------------------------------------
  // RiskFlag 增删查
  // -------------------------------------------------------------------------

  /// 新增风险标记，返回生成的 id，并刷新主表 updatedAt 以驱动聚合流。
  Future<String> addRiskFlag(
    String houseId, {
    required String key,
    required String severity,
    String source = 'user',
    String? note,
  }) async {
    final id = _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.riskFlags).insert(
            RiskFlagsCompanion.insert(
              id: id,
              houseId: houseId,
              key: key,
              severity: severity,
              source: Value(source),
              note: Value(note),
            ),
          );
      await _touch(houseId);
    });
    return id;
  }

  /// 删除风险标记，并刷新主表 updatedAt 以驱动聚合流。
  Future<void> deleteRiskFlag(String id) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.riskFlags)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      await (_db.delete(_db.riskFlags)..where((t) => t.id.equals(id))).go();
      await _touch(row.houseId);
    });
  }

  /// 查某房源的全部风险标记。
  Future<List<domain.RiskFlag>> getRiskFlags(String houseId) async {
    final rows = await (_db.select(_db.riskFlags)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    return rows.map(m.riskFlagFromRow).toList();
  }

  // -------------------------------------------------------------------------
  // PhotoAsset 增删查（元信息落库；文件读写走 PhotoStore）
  // -------------------------------------------------------------------------

  /// 记录一条照片资产元信息（文件已由 PhotoStore 落盘）。返回生成的 id。
  /// 同时刷新主表 updatedAt 以驱动聚合流。
  Future<String> addPhotoAsset(
    String houseId, {
    required String localPath,
    required String tag,
    int? takenAt,
    bool exifRemoved = false,
    String storageProvider = domain.PhotoStorageProvider.local,
    String? remoteUrl,
    String? objectKey,
  }) async {
    final id = _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.photoAssets).insert(
            PhotoAssetsCompanion.insert(
              id: id,
              houseId: Value(houseId),
              ownerType: const Value(domain.PhotoOwnerType.house),
              ownerId: houseId,
              localPath: localPath,
              tag: tag,
              takenAt: takenAt ?? DateTime.now().millisecondsSinceEpoch,
              exifRemoved: Value(exifRemoved),
              storageProvider: Value(storageProvider),
              remoteUrl: Value(remoteUrl),
              objectKey: Value(objectKey),
            ),
          );
      await _touch(houseId);
    });
    return id;
  }

  /// 回填某照片的远端存储元信息（直传成功后调用）。照片不存在时静默返回。
  ///
  /// 只更新 storage_provider/remote_url/object_key，不触碰 local_path：
  /// 本地文件始终保留，远端仅作冗余（本地优先原则）。
  Future<void> updatePhotoStorage(
    String photoId, {
    required String storageProvider,
    String? remoteUrl,
    String? objectKey,
  }) async {
    await (_db.update(_db.photoAssets)..where((t) => t.id.equals(photoId)))
        .write(
      PhotoAssetsCompanion(
        storageProvider: Value(storageProvider),
        remoteUrl: Value(remoteUrl),
        objectKey: Value(objectKey),
      ),
    );
  }

  /// 尝试将已落盘的照片直传对象存储，成功则回填远端元信息，返回是否上传成功。
  ///
  /// 本地优先：无论上传成败，本地文件与元信息都已先行落库，此步纯属增强。
  /// 未配置（[OfflinePhotoUploader]）或任何网络/服务异常都静默吞掉并返回
  /// false，绝不影响本地记录闭环。调用方据返回值决定是否提示“已同步云端”。
  Future<bool> tryUploadPhotoAsset(
    String photoId, {
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  }) async {
    try {
      final result = await _uploader.uploadPhoto(
        ownerType: ownerType,
        ownerId: ownerId,
        tag: tag,
        localPath: localPath,
      );
      await updatePhotoStorage(
        photoId,
        storageProvider: result.storageProvider,
        remoteUrl: result.remoteUrl,
        objectKey: result.objectKey,
      );
      return true;
    } on PhotoUploadException {
      // 未配置或上传失败：保持纯本地存储，不影响记录。
      return false;
    } catch (_) {
      // 兜底：任何异常都不能破坏本地记录闭环。
      return false;
    }
  }

  /// 删除单条照片元信息（不负责文件删除，调用方按需清理磁盘），并刷新聚合流。
  Future<void> deletePhotoAsset(String id) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.photoAssets)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      await (_db.delete(_db.photoAssets)..where((t) => t.id.equals(id))).go();
      final houseId = row.houseId;
      if (houseId != null) {
        await _touch(houseId);
      }
    });
  }

  /// 查某房源的全部照片元信息。
  Future<List<domain.PhotoAsset>> getPhotoAssets(String houseId) async {
    final rows = await (_db.select(_db.photoAssets)
          ..where(
            (t) =>
                (t.ownerType.equals(domain.PhotoOwnerType.house) &
                    t.ownerId.equals(houseId)) |
                t.houseId.equals(houseId),
          ))
        .get();
    return rows.map(m.photoAssetFromRow).toList();
  }

  // -------------------------------------------------------------------------
  // 读取聚合根
  // -------------------------------------------------------------------------

  /// 按 id 组装聚合根（含全部子对象，敏感字段已解密）。房源不存在返回 null。
  Future<domain.HouseRecord?> getById(String houseId) async {
    final row = await (_db.select(_db.houseRecords)
          ..where((t) => t.id.equals(houseId)))
        .getSingleOrNull();
    if (row == null) return null;
    return _assemble(row);
  }

  /// 列出全部房源聚合根，按 updatedAt 降序。
  Future<List<domain.HouseRecord>> getAll() async {
    final rows = await (_db.select(_db.houseRecords)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
    final result = <domain.HouseRecord>[];
    for (final row in rows) {
      result.add(await _assemble(row));
    }
    return result;
  }

  /// watch 单房源聚合根：主表行变化时重查子表并组装。房源删除后发 null。
  Stream<domain.HouseRecord?> watchById(String houseId) {
    final query = _db.select(_db.houseRecords)
      ..where((t) => t.id.equals(houseId));
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      return _assemble(row);
    });
  }

  /// watch 全部房源聚合根（按 updatedAt 降序）。
  Stream<List<domain.HouseRecord>> watchAll() {
    final query = _db.select(_db.houseRecords)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().asyncMap((rows) async {
      final result = <domain.HouseRecord>[];
      for (final row in rows) {
        result.add(await _assemble(row));
      }
      return result;
    });
  }

  /// 组装聚合根：查各子表并映射，敏感字段经 FieldCipher 解密。
  Future<domain.HouseRecord> _assemble(HouseRecord row) async {
    final houseId = row.id;

    final feeRow = await (_db.select(_db.feeInfos)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();
    final roomRow = await (_db.select(_db.roomInfos)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();
    final contactRow = await (_db.select(_db.contactInfos)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();
    final mapRow = await (_db.select(_db.mapSnapshots)
          ..where((t) => t.houseId.equals(houseId)))
        .getSingleOrNull();

    final checklistRows = await (_db.select(_db.checklistItems)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final riskRows = await (_db.select(_db.riskFlags)
          ..where((t) => t.houseId.equals(houseId)))
        .get();
    final photoRows = await (_db.select(_db.photoAssets)
          ..where((t) => t.houseId.equals(houseId)))
        .get();

    final contact = contactRow == null
        ? null
        : await m.contactInfoFromRow(contactRow, _cipher);

    return m.houseRecordFromRow(
      row,
      _cipher,
      fee: feeRow == null ? null : m.feeInfoFromRow(feeRow),
      room: roomRow == null ? null : m.roomInfoFromRow(roomRow),
      contact: contact,
      mapSnapshot: mapRow == null ? null : m.mapSnapshotFromRow(mapRow),
      checklistItems: checklistRows.map(m.checklistItemFromRow).toList(),
      riskFlags: riskRows.map(m.riskFlagFromRow).toList(),
      photos: photoRows.map(m.photoAssetFromRow).toList(),
    );
  }

  // -------------------------------------------------------------------------
  // 删除
  // -------------------------------------------------------------------------

  /// 删除房源：子表随外键 cascade 删除；照片文件目录经 PhotoStore 清理。
  ///
  /// 先读取父级归属并清理磁盘照片，再在同一事务里删除主表并 touch
  /// village/building，确保首页 / 村详情这类统计流能感知房源数量变化。
  Future<void> delete(String houseId) async {
    final row = await (_db.select(_db.houseRecords)
          ..where((t) => t.id.equals(houseId)))
        .getSingleOrNull();
    if (row == null) return;

    await _photoStore.deleteByHouse(houseId);
    await _photoStore.deleteByOwner(domain.PhotoOwnerType.house, houseId);

    await _db.transaction(() async {
      await (_db.delete(_db.houseRecords)..where((t) => t.id.equals(houseId)))
          .go();
      final villageId = row.villageId;
      if (villageId != null) {
        await _touchVillage(villageId);
      }
      final buildingId = row.buildingId;
      if (buildingId != null) {
        await _touchBuilding(buildingId);
      }
    });
  }
}
