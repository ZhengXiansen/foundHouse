import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/app/theme.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:found_house_app/data/repositories/village_repository.dart';
import 'package:found_house_app/features/house/house_list_page.dart';
import 'package:found_house_app/features/scan/village_detail_page.dart';
import 'package:found_house_app/features/scan/village_home_page.dart';
import 'package:found_house_app/features/scoring/house_scoring_controller.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android 真机：村、楼栋、房源卡片左滑露出右侧删除，右滑不触发', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    final photoStore = PhotoStore(baseDirOverride: Directory.systemTemp);
    final villages = VillageRepository(db: db, photoStore: photoStore);
    final houses = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: photoStore,
    );

    Future<void> pumpFrames([int count = 8]) async {
      for (var i = 0; i < count; i += 1) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpPage(Widget page) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            fieldCipherProvider.overrideWithValue(const NoopFieldCipher()),
            photoStoreProvider.overrideWithValue(photoStore),
            preferenceProfileProvider.overrideWith(
              (ref) => Stream<domain.PreferenceProfile?>.value(null),
            ),
          ],
          child: MaterialApp(theme: buildAppTheme(), home: page),
        ),
      );
      await pumpFrames(8);
    }

    Future<void> pumpUntil(
      Future<bool> Function() predicate, {
      String reason = 'condition',
      int frames = 80,
    }) async {
      for (var i = 0; i < frames; i += 1) {
        await tester.pump(const Duration(milliseconds: 100));
        if (await predicate()) return;
      }
      fail('Timed out waiting for $reason');
    }

    Future<void> rightSwipeDoesNotExposeDelete(Key key) async {
      final target = find.byKey(key);
      expect(target, findsOneWidget);
      await tester.ensureVisible(target);
      await pumpFrames(2);
      await tester.timedDrag(
        target,
        const Offset(520, 0),
        const Duration(milliseconds: 350),
      );
      await pumpFrames(8);
      expect(target, findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find.descendant(
          of: target,
          matching: find.byKey(const Key('swipe-delete-start-action')),
        ),
        findsNothing,
        reason: '右滑方向不应存在左侧删除按钮',
      );
      final endSemantics = find.descendant(
        of: target,
        matching: find.byKey(const Key('swipe-delete-end-semantics')),
      );
      expect(endSemantics, findsOneWidget);
      expect(tester.widget<ExcludeSemantics>(endSemantics).excluding, isTrue);
    }

    Future<void> swipeAndConfirmDelete(
      Key key,
      Future<bool> Function() deleted,
    ) async {
      final target = find.byKey(key);
      expect(target, findsOneWidget);
      await tester.ensureVisible(target);
      await pumpFrames(2);
      await tester.timedDrag(
        target,
        const Offset(-520, 0),
        const Duration(milliseconds: 350),
      );
      await pumpFrames(8);
      expect(target, findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      final deleteAction = find.descendant(
        of: target,
        matching: find.byKey(const Key('swipe-delete-end-action')),
      );
      expect(deleteAction, findsOneWidget, reason: '左滑后应在右侧露出删除按钮');
      final targetRect = tester.getRect(target);
      final actionRect = tester.getRect(deleteAction);
      expect(
        actionRect.top,
        greaterThan(targetRect.top),
        reason: '真机上红色删除区顶部应落在可见卡片内，而不是占满外层行距',
      );
      expect(
        actionRect.height,
        lessThan(targetRect.height),
        reason: '真机上红色删除区高度应小于含 margin 的外层行高，避免比分隔后的数据行更高',
      );
      expect(
        actionRect.right,
        lessThanOrEqualTo(targetRect.right),
        reason: '真机上删除区应贴在右侧/尾部，而不是出现在左侧',
      );
      expect(
        actionRect.left,
        greaterThan(targetRect.left),
        reason: '真机上删除区应是右侧固定宽度操作区',
      );
      await tester.tap(deleteAction);
      await pumpFrames(8);

      final dialogDeleteButton = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, '删除'),
      );
      expect(dialogDeleteButton, findsOneWidget, reason: '点击露出的删除按钮后应弹出确认');
      await tester.tap(dialogDeleteButton);
      await pumpFrames(4);
      await pumpUntil(deleted, reason: 'delete $key');
    }

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpFrames(2);
      await db.close();
    });

    final villageId = await villages.createVillage(name: '真机右侧删除村');
    final buildingId = await villages.createBuilding(
      villageId: villageId,
      name: '真机待删楼',
    );
    final groupedHouseId = await houses.create(
      title: '真机待删楼 301',
      villageId: villageId,
      buildingId: buildingId,
    );
    final unassignedHouseId = await houses.create(
      title: '真机未分楼栋 201',
      villageId: villageId,
      fee: const domain.FeeInfo(rentMonthly: 1600),
      room: const domain.RoomInfo(layout: '单间'),
    );

    await pumpPage(VillageDetailPage(villageId: villageId));
    await rightSwipeDoesNotExposeDelete(ValueKey('building-$buildingId'));
    expect(await villages.getBuildingById(buildingId), isNotNull);
    expect(await houses.getById(groupedHouseId), isNotNull);
    await swipeAndConfirmDelete(
      ValueKey('building-$buildingId'),
      () async =>
          await villages.getBuildingById(buildingId) == null &&
          await houses.getById(groupedHouseId) == null,
    );
    await rightSwipeDoesNotExposeDelete(ValueKey('house-$unassignedHouseId'));
    expect(await houses.getById(unassignedHouseId), isNotNull);
    await swipeAndConfirmDelete(
      ValueKey('house-$unassignedHouseId'),
      () async => await houses.getById(unassignedHouseId) == null,
    );

    final listVillageId = await villages.createVillage(name: '真机房源列表村');
    final listHouseId = await houses.create(
      title: '真机列表待删 501',
      villageId: listVillageId,
      roomNo: '501',
      fee: const domain.FeeInfo(rentMonthly: 1800),
      room: const domain.RoomInfo(layout: '单间'),
    );
    await pumpPage(const HouseListPage());
    await rightSwipeDoesNotExposeDelete(ValueKey('house-$listHouseId'));
    expect(await houses.getById(listHouseId), isNotNull);
    await swipeAndConfirmDelete(
      ValueKey('house-$listHouseId'),
      () async => await houses.getById(listHouseId) == null,
    );

    final villageToDeleteId = await villages.createVillage(name: '真机整村删除');
    final villageHouseId = await houses.create(
      title: '真机整村 101',
      villageId: villageToDeleteId,
    );
    await pumpPage(const VillageHomePage());
    await rightSwipeDoesNotExposeDelete(ValueKey('village-$villageToDeleteId'));
    expect(await villages.getById(villageToDeleteId), isNotNull);
    expect(await houses.getById(villageHouseId), isNotNull);
    await swipeAndConfirmDelete(
      ValueKey('village-$villageToDeleteId'),
      () async =>
          await villages.getById(villageToDeleteId) == null &&
          await houses.getById(villageHouseId) == null,
    );
  });
}
