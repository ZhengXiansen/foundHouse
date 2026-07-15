// HouseRepository 单测（W1-2）。
//
// 用 AppDatabase.forTesting(NativeDatabase.memory()) 建内存库，覆盖：
// 新建→读取一致、分区更新、级联删除、敏感字段经 NoopFieldCipher 往返、
// checklist/risk/photo 增删查、watch 更新。

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/crypto_service.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:found_house_app/integrations/oss/oss_photo_uploader.dart';

/// 固定返回成功结果的假上传器，用于验证 tryUploadPhotoAsset 回填元信息。
class _FakePhotoUploader extends PhotoUploader {
  const _FakePhotoUploader();

  @override
  Future<PhotoUploadResult> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  }) async {
    return PhotoUploadResult(
      storageProvider: domain.PhotoStorageProvider.oss,
      remoteUrl: 'https://cdn.example.com/$ownerType/$ownerId/$tag.jpg',
      objectKey: 'photos/$ownerType/$ownerId/$tag.jpg',
    );
  }
}

/// 恒抛异常的假上传器，用于验证失败时静默回退纯本地存储。
class _ThrowingPhotoUploader extends PhotoUploader {
  const _ThrowingPhotoUploader();

  @override
  Future<PhotoUploadResult> uploadPhoto({
    required String ownerType,
    required String ownerId,
    required String tag,
    required String localPath,
  }) async {
    throw const PhotoUploadException(
      statusCode: 500,
      code: 'OSS_UPLOAD_FAILED',
      message: 'boom',
    );
  }
}

class _InMemoryKeyStore implements KeyStore {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}

void main() {
  late AppDatabase db;
  late HouseRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // 内存库需显式开启外键，级联删除依赖此项（forTesting 不走 beforeOpen 的生产路径）。
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      // 测试不触碰真实文件系统：仅删除接口调用，指向临时目录避免副作用。
      photoStore: PhotoStore(baseDirOverride: Directory.systemTemp),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('新建房源后按 id 读取，主表与子对象字段一致', () async {
    final id = await repo.create(
      title: '城中村单间',
      status: 'active',
      latitude: 22.5,
      longitude: 114.0,
      addressText: '深圳市南山区某村',
      buildingName: 'A 栋',
      roomNo: '301',
      fee: const domain.FeeInfo(rentMonthly: 1500, deposit: 1500),
      room: const domain.RoomInfo(
        layout: '单间',
        area: 18.5,
        hasPrivateBathroom: true,
      ),
      contact: const domain.ContactInfo(
        name: '张房东',
        role: '房东',
        phone: '13800001111',
        wechat: 'zhang_wx',
      ),
    );

    final house = await repo.getById(id);
    expect(house, isNotNull);
    expect(house!.title, '城中村单间');
    expect(house.status, 'active');
    expect(house.latitude, 22.5);
    expect(house.addressText, '深圳市南山区某村');
    expect(house.roomNo, '301');
    expect(house.fee?.rentMonthly, 1500);
    expect(house.room?.area, 18.5);
    expect(house.room?.hasPrivateBathroom, true);
    expect(house.contact?.name, '张房东');
    expect(house.contact?.phone, '13800001111');
    expect(house.contact?.wechat, 'zhang_wx');
  });

  test('敏感字段经 NoopFieldCipher 往返一致（明文即密文）', () async {
    final id = await repo.create(
      title: '联系人测试',
      roomNo: '8-2-303',
      contact: const domain.ContactInfo(phone: '13911112222', note: '门口有摄像头'),
    );

    // 领域层读到明文。
    final house = await repo.getById(id);
    expect(house!.roomNo, '8-2-303');
    expect(house.contact?.phone, '13911112222');
    expect(house.contact?.note, '门口有摄像头');

    // 底层行同为明文（Noop 透传）。
    final row = await (db.select(db.contactInfos)
          ..where((t) => t.houseId.equals(id)))
        .getSingle();
    expect(row.phone, '13911112222');
  });

  test('敏感字段经 CryptoFieldCipher 落库为密文，领域层读回明文', () async {
    final encryptedRepo = HouseRepository(
      db: db,
      cipher: CryptoFieldCipher(CryptoService(_InMemoryKeyStore())),
      photoStore: PhotoStore(baseDirOverride: Directory.systemTemp),
    );

    final id = await encryptedRepo.create(
      title: '加密测试',
      roomNo: '8-2-303',
      contact: const domain.ContactInfo(
        phone: '13911112222',
        wechat: 'safe_wx',
        note: '门口有摄像头',
      ),
    );

    final house = await encryptedRepo.getById(id);
    expect(house!.roomNo, '8-2-303');
    expect(house.contact?.phone, '13911112222');
    expect(house.contact?.wechat, 'safe_wx');
    expect(house.contact?.note, '门口有摄像头');

    final houseRow = await (db.select(db.houseRecords)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(houseRow.roomNo, isNot('8-2-303'));

    final contactRow = await (db.select(db.contactInfos)
          ..where((t) => t.houseId.equals(id)))
        .getSingle();
    expect(contactRow.phone, isNot('13911112222'));
    expect(contactRow.wechat, isNot('safe_wx'));
    expect(contactRow.note, isNot('门口有摄像头'));
  });

  test('默认 Provider 装配的仓库会加密敏感字段后落库', () async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        cryptoServiceProvider.overrideWithValue(
          CryptoService(_InMemoryKeyStore()),
        ),
        photoStoreProvider.overrideWithValue(
          PhotoStore(baseDirOverride: Directory.systemTemp),
        ),
      ],
    );
    addTearDown(container.dispose);

    final providerRepo = container.read(houseRepositoryProvider);
    final id = await providerRepo.create(
      title: '默认装配加密测试',
      roomNo: '9-1-808',
      contact: const domain.ContactInfo(phone: '13500001111'),
    );

    final house = await providerRepo.getById(id);
    expect(house!.roomNo, '9-1-808');
    expect(house.contact?.phone, '13500001111');

    final houseRow = await (db.select(db.houseRecords)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    final contactRow = await (db.select(db.contactInfos)
          ..where((t) => t.houseId.equals(id)))
        .getSingle();
    expect(houseRow.roomNo, isNot('9-1-808'));
    expect(contactRow.phone, isNot('13500001111'));
  });

  test('getById 不存在时返回 null', () async {
    expect(await repo.getById('not-exist'), isNull);
  });

  test('分区更新：updateMain / updateFee / updateContact 刷新字段与 updatedAt', () async {
    final id = await repo.create(title: '原标题');
    final before = await repo.getById(id);

    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repo.updateMain(
      id,
      title: const Value('新标题'),
      status: const Value('shortlisted'),
    );
    await repo.updateFee(
      id,
      const domain.FeeInfo(
        rentMonthly: 2000,
        estimatedTotalMonthly: 2300,
      ),
    );
    await repo.updateContact(
      id,
      const domain.ContactInfo(phone: '13700007777'),
    );

    final after = await repo.getById(id);
    expect(after!.title, '新标题');
    expect(after.status, 'shortlisted');
    expect(after.fee?.rentMonthly, 2000);
    expect(after.fee?.estimatedTotalMonthly, 2300);
    expect(after.contact?.phone, '13700007777');
    expect(after.updatedAt, greaterThanOrEqualTo(before!.updatedAt));
  });

  test('checklist 增删查', () async {
    final id = await repo.create(title: 'checklist');
    final c1 = await repo.addChecklistItem(
      id,
      module: 'room',
      key: 'light',
      value: 'good',
    );
    await repo.addChecklistItem(
      id,
      module: 'kitchen',
      key: 'stove',
      value: 'ok',
    );

    var items = await repo.getChecklistItems(id);
    expect(items.length, 2);

    await repo.updateChecklistItem(
      c1,
      value: const Value('bad'),
      note: const Value('偏暗'),
    );
    items = await repo.getChecklistItems(id);
    final updated = items.firstWhere((e) => e.id == c1);
    expect(updated.value, 'bad');
    expect(updated.note, '偏暗');

    await repo.deleteChecklistItem(c1);
    items = await repo.getChecklistItems(id);
    expect(items.length, 1);
  });

  test('risk flag 增删查', () async {
    final id = await repo.create(title: 'risk');
    final r1 = await repo.addRiskFlag(
      id,
      key: 'risk_second_landlord',
      severity: 'warning',
      note: '二房东',
    );
    var flags = await repo.getRiskFlags(id);
    expect(flags.length, 1);
    expect(flags.first.key, 'risk_second_landlord');
    expect(flags.first.source, 'user');

    await repo.deleteRiskFlag(r1);
    flags = await repo.getRiskFlags(id);
    expect(flags, isEmpty);
  });

  test('photo asset 元信息增删查', () async {
    final id = await repo.create(title: 'photo');
    final p1 = await repo.addPhotoAsset(
      id,
      localPath: '/tmp/a.jpg',
      tag: PhotoTag.room,
    );
    await repo.addPhotoAsset(id, localPath: '/tmp/b.jpg', tag: PhotoTag.sign);

    var photos = await repo.getPhotoAssets(id);
    expect(photos.length, 2);

    await repo.deletePhotoAsset(p1);
    photos = await repo.getPhotoAssets(id);
    expect(photos.length, 1);
    expect(photos.first.tag, PhotoTag.sign);
  });


  test('photo asset persists OSS remote metadata', () async {
    final id = await repo.create(title: 'oss-photo');

    await repo.addPhotoAsset(
      id,
      localPath: '/tmp/cache-room.jpg',
      tag: PhotoTag.room,
      storageProvider: domain.PhotoStorageProvider.oss,
      remoteUrl: 'https://cdn.example.com/photos/house/house-1/cache-room.jpg',
      objectKey: 'photos/house/house-1/cache-room.jpg',
    );

    final photos = await repo.getPhotoAssets(id);
    expect(photos, hasLength(1));
    expect(photos.single.storageProvider, domain.PhotoStorageProvider.oss);
    expect(photos.single.remoteUrl, 'https://cdn.example.com/photos/house/house-1/cache-room.jpg');
    expect(photos.single.objectKey, 'photos/house/house-1/cache-room.jpg');
  });

  test('tryUploadPhotoAsset 成功时回填远端元信息且保留本地路径', () async {
    final uploadRepo = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: PhotoStore(baseDirOverride: Directory.systemTemp),
      uploader: const _FakePhotoUploader(),
    );
    final id = await uploadRepo.create(title: 'upload-ok');
    final photoId = await uploadRepo.addPhotoAsset(
      id,
      localPath: '/tmp/local-room.jpg',
      tag: PhotoTag.room,
    );

    final ok = await uploadRepo.tryUploadPhotoAsset(
      photoId,
      ownerType: domain.PhotoOwnerType.house,
      ownerId: id,
      tag: PhotoTag.room,
      localPath: '/tmp/local-room.jpg',
    );

    expect(ok, isTrue);
    final photos = await uploadRepo.getPhotoAssets(id);
    expect(photos, hasLength(1));
    expect(photos.single.storageProvider, domain.PhotoStorageProvider.oss);
    expect(
      photos.single.remoteUrl,
      'https://cdn.example.com/house/$id/${PhotoTag.room}.jpg',
    );
    expect(
      photos.single.objectKey,
      'photos/house/$id/${PhotoTag.room}.jpg',
    );
    // 本地优先：远端回填不得覆盖本地路径。
    expect(photos.single.localPath, '/tmp/local-room.jpg');
  });

  test('tryUploadPhotoAsset 失败时静默回退，照片保持纯本地存储', () async {
    final uploadRepo = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: PhotoStore(baseDirOverride: Directory.systemTemp),
      uploader: const _ThrowingPhotoUploader(),
    );
    final id = await uploadRepo.create(title: 'upload-fail');
    final photoId = await uploadRepo.addPhotoAsset(
      id,
      localPath: '/tmp/local-fail.jpg',
      tag: PhotoTag.room,
    );

    final ok = await uploadRepo.tryUploadPhotoAsset(
      photoId,
      ownerType: domain.PhotoOwnerType.house,
      ownerId: id,
      tag: PhotoTag.room,
      localPath: '/tmp/local-fail.jpg',
    );

    expect(ok, isFalse);
    final photos = await uploadRepo.getPhotoAssets(id);
    expect(photos, hasLength(1));
    // 上传失败：存储位置仍为本地，远端字段为空，本地记录不受影响。
    expect(photos.single.storageProvider, domain.PhotoStorageProvider.local);
    expect(photos.single.remoteUrl, isNull);
    expect(photos.single.objectKey, isNull);
    expect(photos.single.localPath, '/tmp/local-fail.jpg');
  });

  test('默认仓库（OfflinePhotoUploader）tryUploadPhotoAsset 返回 false', () async {
    final id = await repo.create(title: 'upload-default-offline');
    final photoId = await repo.addPhotoAsset(
      id,
      localPath: '/tmp/local-offline.jpg',
      tag: PhotoTag.room,
    );

    final ok = await repo.tryUploadPhotoAsset(
      photoId,
      ownerType: domain.PhotoOwnerType.house,
      ownerId: id,
      tag: PhotoTag.room,
      localPath: '/tmp/local-offline.jpg',
    );

    expect(ok, isFalse);
    final photos = await repo.getPhotoAssets(id);
    expect(photos.single.storageProvider, domain.PhotoStorageProvider.local);
  });

  test('删除房源级联清理全部子表', () async {
    final id = await repo.create(
      title: '待删',
      fee: const domain.FeeInfo(rentMonthly: 1000),
      room: const domain.RoomInfo(layout: '单间'),
      contact: const domain.ContactInfo(phone: '13600006666'),
    );
    await repo.addChecklistItem(id, module: 'room', key: 'light');
    await repo.addRiskFlag(id, key: 'risk_no_contract', severity: 'warning');
    await repo.addPhotoAsset(
      id,
      localPath: '/tmp/x.jpg',
      tag: PhotoTag.building,
    );
    await repo.updateMapSnapshot(
      id,
      const domain.MapSnapshot(commuteJson: '{}'),
    );

    await repo.delete(id);

    expect(await repo.getById(id), isNull);
    // 各子表随外键 cascade 清空。
    expect(await db.select(db.feeInfos).get(), isEmpty);
    expect(await db.select(db.roomInfos).get(), isEmpty);
    expect(await db.select(db.contactInfos).get(), isEmpty);
    expect(await db.select(db.checklistItems).get(), isEmpty);
    expect(await db.select(db.riskFlags).get(), isEmpty);
    expect(await db.select(db.photoAssets).get(), isEmpty);
    expect(await db.select(db.mapSnapshots).get(), isEmpty);
  });

  test('watchById 在子表更新后推送新聚合', () async {
    final id = await repo.create(title: 'watch');
    final stream = repo.watchById(id);

    final emissions = <domain.HouseRecord?>[];
    final sub = stream.listen(emissions.add);

    // 触发主表 updatedAt 变化以驱动 watchSingleOrNull 重新求值。
    await repo.updateFee(id, const domain.FeeInfo(rentMonthly: 1800));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await sub.cancel();
    expect(emissions.isNotEmpty, true);
    expect(emissions.last?.fee?.rentMonthly, 1800);
  });

  test('watchAll 在 checklist item 新增后推送新聚合', () async {
    final id = await repo.create(title: 'checklist-add-watch');
    final iterator = StreamIterator(repo.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), true);
    expect(iterator.current.single.checklistItems, isEmpty);

    await repo.addChecklistItem(
      id,
      module: 'room',
      key: 'light',
      value: 'good',
    );

    expect(
      await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
      true,
    );
    expect(iterator.current.single.checklistItems.single.key, 'light');
    expect(iterator.current.single.checklistItems.single.value, 'good');
  });

  test('watchAll 在 checklist item 更新后推送新聚合', () async {
    final id = await repo.create(title: 'checklist-update-watch');
    final itemId = await repo.addChecklistItem(
      id,
      module: 'room',
      key: 'light',
      value: 'bad',
    );
    final iterator = StreamIterator(repo.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), true);
    expect(iterator.current.single.checklistItems.single.value, 'bad');

    await repo.updateChecklistItem(itemId, value: const Value('good'));

    expect(
      await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
      true,
    );
    expect(iterator.current.single.checklistItems.single.value, 'good');
  });

  test('watchAll 在 checklist item 删除后推送新聚合', () async {
    final id = await repo.create(title: 'checklist-delete-watch');
    final itemId = await repo.addChecklistItem(
      id,
      module: 'room',
      key: 'light',
      value: 'good',
    );
    final iterator = StreamIterator(repo.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), true);
    expect(iterator.current.single.checklistItems.single.key, 'light');

    await repo.deleteChecklistItem(itemId);

    expect(
      await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
      true,
    );
    expect(iterator.current.single.checklistItems, isEmpty);
  });

  test('watchAll 在 photo asset 新增后推送新聚合', () async {
    final id = await repo.create(title: 'photo-add-watch');
    final iterator = StreamIterator(repo.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), true);
    expect(iterator.current.single.photos, isEmpty);

    await repo.addPhotoAsset(id, localPath: '/tmp/a.jpg', tag: 'room');

    expect(
      await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
      true,
    );
    expect(iterator.current.single.photos.single.localPath, '/tmp/a.jpg');
    expect(iterator.current.single.photos.single.tag, 'room');
  });

  test('watchAll 在 photo asset 删除后推送新聚合', () async {
    final id = await repo.create(title: 'photo-delete-watch');
    final photoId = await repo.addPhotoAsset(
      id,
      localPath: '/tmp/a.jpg',
      tag: 'room',
    );
    final iterator = StreamIterator(repo.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), true);
    expect(iterator.current.single.photos.single.localPath, '/tmp/a.jpg');

    await repo.deletePhotoAsset(photoId);

    expect(
      await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
      true,
    );
    expect(iterator.current.single.photos, isEmpty);
  });

  test('watchAll 在 risk flag 新增后推送新聚合', () async {
    final id = await repo.create(title: 'risk-add-watch');
    final iterator = StreamIterator(repo.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), true);
    expect(iterator.current.single.riskFlags, isEmpty);

    await repo.addRiskFlag(
      id,
      key: 'risk_non_residential',
      severity: 'blocker',
    );

    expect(
      await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
      true,
    );
    expect(
      iterator.current.single.riskFlags.single.key,
      'risk_non_residential',
    );
    expect(iterator.current.single.riskFlags.single.severity, 'blocker');
  });

  test('watchAll 在 risk flag 删除后推送新聚合', () async {
    final id = await repo.create(title: 'risk-delete-watch');
    final riskId = await repo.addRiskFlag(
      id,
      key: 'risk_non_residential',
      severity: 'blocker',
    );
    final iterator = StreamIterator(repo.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), true);
    expect(
      iterator.current.single.riskFlags.single.key,
      'risk_non_residential',
    );

    await repo.deleteRiskFlag(riskId);

    expect(
      await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
      true,
    );
    expect(iterator.current.single.riskFlags, isEmpty);
  });
  test('watchAll 按 updatedAt 降序', () async {
    final a = await repo.create(title: 'A');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final b = await repo.create(title: 'B');

    final list = await repo.watchAll().first;
    expect(list.length, 2);
    // 最近创建/更新的 B 在前。
    expect(list.first.id, b);
    expect(list.last.id, a);
  });
}

