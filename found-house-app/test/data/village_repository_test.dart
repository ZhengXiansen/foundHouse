import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:found_house_app/data/repositories/village_repository.dart';

void main() {
  late AppDatabase db;
  late HouseRepository houses;
  late VillageRepository villages;
  late PhotoStore photoStore;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    tempDir =
        await Directory.systemTemp.createTemp('found_house_village_repo_test_');
    photoStore = PhotoStore(baseDirOverride: tempDir);
    houses = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: photoStore,
    );
    villages = VillageRepository(
      db: db,
      photoStore: photoStore,
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('creates default unassigned village and attaches legacy house drafts',
      () async {
    final houseId = await houses.create(title: '旧流程草稿');

    final house = await houses.getById(houseId);
    expect(house, isNotNull);
    expect(house!.villageId, VillageRepository.unassignedVillageId);
    expect(house.buildingId, isNull);

    final unassigned =
        await villages.getById(VillageRepository.unassignedVillageId);
    expect(unassigned, isNotNull);
    expect(unassigned!.name, '未分组');

    final summary = await villages.getVillageWithStats(unassigned.id);
    expect(summary!.houseCount, 1);
    expect(summary.buildingCount, 0);
  });

  test('building is a standalone scouting record and updates village stats',
      () async {
    final villageId = await villages.createVillage(
      name: '白石洲',
      status: VillageStatus.scouting,
      commuteMinutes: 35,
      surroundingsTags: const ['地铁', '菜市场'],
    );

    final buildingId = await villages.createBuilding(
      villageId: villageId,
      name: '东三巷 8 号',
      status: BuildingStatus.noVacancy,
      tags: const ['电话没人接'],
      note: '晚上再来',
    );

    final summary = await villages.getVillageWithStats(villageId);
    expect(summary, isNotNull);
    expect(summary!.village.name, '白石洲');
    expect(summary.village.status, VillageStatus.scouting);
    expect(summary.village.commuteMinutes, 35);
    expect(summary.village.surroundingsTags, ['地铁', '菜市场']);
    expect(summary.buildingCount, 1);
    expect(summary.houseCount, 0);
    expect(summary.revisitCount, 0);

    final building = await villages.getBuildingById(buildingId);
    expect(building, isNotNull);
    expect(building!.name, '东三巷 8 号');
    expect(building.status, BuildingStatus.noVacancy);
    expect(building.tags, ['电话没人接']);
    expect(building.note, '晚上再来');
  });

  test('house must belong to village and may optionally belong to building',
      () async {
    final villageId = await villages.createVillage(
      name: '岗厦村',
      status: VillageStatus.scouting,
    );
    final buildingId = await villages.createBuilding(
      villageId: villageId,
      name: 'A 入口',
      status: BuildingStatus.hasVacancy,
    );

    final groupedHouseId = await houses.create(
      villageId: villageId,
      buildingId: buildingId,
      title: 'A 入口 302',
      status: 'shortlisted',
      roomNo: '302',
      fee: const domain.FeeInfo(rentMonthly: 1800),
    );
    final ungroupedHouseId = await houses.create(
      villageId: villageId,
      title: '先记一套未分楼栋',
    );

    final grouped = await houses.getById(groupedHouseId);
    final ungrouped = await houses.getById(ungroupedHouseId);
    expect(grouped!.villageId, villageId);
    expect(grouped.buildingId, buildingId);
    expect(grouped.roomNo, '302');
    expect(ungrouped!.villageId, villageId);
    expect(ungrouped.buildingId, isNull);

    final summary = await villages.getVillageWithStats(villageId);
    expect(summary!.houseCount, 2);
    expect(summary.shortlistedCount, 1);
    expect(summary.unassignedHouseCount, 1);
  });

  test('building photos are independent owner records without a house',
      () async {
    final villageId = await villages.createVillage(name: '上沙村');
    final buildingId = await villages.createBuilding(
      villageId: villageId,
      name: '7 巷入口',
    );

    await villages.addPhotoAsset(
      ownerType: PhotoOwnerType.building,
      ownerId: buildingId,
      localPath: '/tmp/building.jpg',
      tag: PhotoTag.building,
    );

    final photos = await villages.getPhotosForOwner(
      ownerType: PhotoOwnerType.building,
      ownerId: buildingId,
    );
    expect(photos, hasLength(1));
    expect(photos.single.ownerType, PhotoOwnerType.building);
    expect(photos.single.ownerId, buildingId);
    expect(photos.single.houseId, isNull);
  });

  test('deleteBuilding removes building, its houses and stored photos',
      () async {
    final villageId = await villages.createVillage(name: '级联村');
    final buildingId = await villages.createBuilding(
      villageId: villageId,
      name: 'A栋',
    );
    final houseId = await houses.create(
      villageId: villageId,
      buildingId: buildingId,
      title: 'A栋 301',
      roomNo: '301',
      fee: const domain.FeeInfo(rentMonthly: 1800),
      room: const domain.RoomInfo(layout: '单间'),
    );

    final source = File('${tempDir.path}${Platform.pathSeparator}source.jpg');
    await source.writeAsString('fake image');
    final buildingPhoto = await photoStore.savePhotoForOwner(
      PhotoOwnerType.building,
      buildingId,
      source.path,
      PhotoTag.building,
    );
    await villages.addPhotoAsset(
      ownerType: PhotoOwnerType.building,
      ownerId: buildingId,
      localPath: buildingPhoto.localPath,
      tag: PhotoTag.building,
    );
    final housePhoto = await photoStore.savePhoto(
      houseId,
      source.path,
      PhotoTag.room,
    );
    await houses.addPhotoAsset(
      houseId,
      localPath: housePhoto.localPath,
      tag: PhotoTag.room,
    );

    await villages.deleteBuilding(buildingId);

    expect(await villages.getBuildingById(buildingId), isNull);
    expect(await houses.getById(houseId), isNull);
    expect(
      await photoStore.listByOwner(PhotoOwnerType.building, buildingId),
      isEmpty,
    );
    expect(await photoStore.listByHouse(houseId), isEmpty);
    final summary = await villages.getVillageWithStats(villageId);
    expect(summary!.buildingCount, 0);
    expect(summary.houseCount, 0);
  });

  test('deleteBuildingIfEmpty only removes empty rollback buildings', () async {
    final villageId = await villages.createVillage(name: '安全回滚村');
    final emptyBuildingId = await villages.createBuilding(
      villageId: villageId,
      name: '空楼栋',
    );
    final occupiedBuildingId = await villages.createBuilding(
      villageId: villageId,
      name: '有房楼栋',
    );
    final houseId = await houses.create(
      villageId: villageId,
      buildingId: occupiedBuildingId,
      title: '有房楼栋 501',
    );

    expect(await villages.deleteBuildingIfEmpty(emptyBuildingId), isTrue);
    expect(await villages.getBuildingById(emptyBuildingId), isNull);

    expect(await villages.deleteBuildingIfEmpty(occupiedBuildingId), isFalse);
    expect(await villages.getBuildingById(occupiedBuildingId), isNotNull);
    expect(await houses.getById(houseId), isNotNull);
  });

  test('deleteVillage removes village, buildings, houses and stored photos',
      () async {
    final villageId = await villages.createVillage(name: '整村删除');
    final buildingId = await villages.createBuilding(
      villageId: villageId,
      name: 'B栋',
    );
    final groupedHouseId = await houses.create(
      villageId: villageId,
      buildingId: buildingId,
      title: 'B栋 501',
    );
    final unassignedHouseId = await houses.create(
      villageId: villageId,
      title: '未分楼栋 201',
    );

    final source =
        File('${tempDir.path}${Platform.pathSeparator}source-village.jpg');
    await source.writeAsString('fake image');
    final villagePhoto = await photoStore.savePhotoForOwner(
      PhotoOwnerType.village,
      villageId,
      source.path,
      PhotoTag.sign,
    );
    await villages.addPhotoAsset(
      ownerType: PhotoOwnerType.village,
      ownerId: villageId,
      localPath: villagePhoto.localPath,
      tag: PhotoTag.sign,
    );
    final groupedPhoto = await photoStore.savePhoto(
      groupedHouseId,
      source.path,
      PhotoTag.room,
    );
    await houses.addPhotoAsset(
      groupedHouseId,
      localPath: groupedPhoto.localPath,
      tag: PhotoTag.room,
    );

    await villages.deleteVillage(villageId);

    expect(await villages.getById(villageId), isNull);
    expect(await villages.getBuildingById(buildingId), isNull);
    expect(await houses.getById(groupedHouseId), isNull);
    expect(await houses.getById(unassignedHouseId), isNull);
    expect(
      await photoStore.listByOwner(PhotoOwnerType.village, villageId),
      isEmpty,
    );
    expect(await photoStore.listByHouse(groupedHouseId), isEmpty);
  });

  test(
    'watchVillagesWithStats emits updated counts after house repository delete',
    () async {
      final villageId = await villages.createVillage(name: '首页统计刷新村');
      final buildingId = await villages.createBuilding(
        villageId: villageId,
        name: '1 栋',
      );
      final houseId = await houses.create(
        villageId: villageId,
        buildingId: buildingId,
        title: '1 栋 101',
      );
      final iterator = StreamIterator(villages.watchVillagesWithStats());
      addTearDown(iterator.cancel);

      expect(await iterator.moveNext(), true);
      var entry = iterator.current.singleWhere(
        (item) => item.village.id == villageId,
      );
      expect(entry.houseCount, 1);

      await houses.delete(houseId);
      expect(
        await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
        true,
      );
      entry =
          iterator.current.singleWhere((item) => item.village.id == villageId);
      expect(entry.houseCount, 0);
      expect(entry.buildingCount, 1);
    },
  );

  test(
    'watchVillageWithStats emits when child building and house data changes',
    () async {
      final villageId = await villages.createVillage(name: '流式村');
      final iterator =
          StreamIterator(villages.watchVillageWithStats(villageId));
      addTearDown(iterator.cancel);

      expect(await iterator.moveNext(), true);
      expect(iterator.current!.buildingCount, 0);
      expect(iterator.current!.houseCount, 0);

      await villages.createBuilding(villageId: villageId, name: '1 栋');
      expect(
        await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
        true,
      );
      expect(iterator.current!.buildingCount, 1);

      await houses.create(villageId: villageId, title: '101');
      expect(
        await iterator.moveNext().timeout(const Duration(milliseconds: 300)),
        true,
      );
      expect(iterator.current!.houseCount, 1);
    },
  );
}
