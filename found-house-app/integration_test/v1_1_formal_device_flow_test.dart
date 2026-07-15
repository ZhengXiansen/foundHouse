import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/app/app.dart';
import 'package:found_house_app/app/router.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/village_repository.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('v1.2 正式版补充真机覆盖：缺失村、多入口、楼栋创建、必填校验、筛选与对比边界', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');

    Future<void> pumpFrames([int count = 8]) async {
      for (var i = 0; i < count; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilFound(Finder finder, {int maxFrames = 50}) async {
      for (var i = 0; i < maxFrames; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) return;
      }
      expect(finder, findsWidgets);
    }

    Future<void> scrollUntilFound(
      Finder finder, {
      double delta = 300,
      int maxScrolls = 18,
    }) async {
      for (var i = 0; i < maxScrolls; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) {
          await tester.ensureVisible(finder.first);
          await tester.pump(const Duration(milliseconds: 100));
          return;
        }
        final scrollables = find.byType(Scrollable);
        expect(scrollables, findsWidgets, reason: '页面应存在可滚动区域');
        await tester.drag(scrollables.last, Offset(0, -delta));
      }
      expect(finder, findsWidgets);
    }

    Future<void> enterByHint(String hint, String value) async {
      final finder = find.widgetWithText(TextField, hint);
      await tester.ensureVisible(finder.first);
      await pumpFrames(2);
      expect(finder, findsOneWidget, reason: '应找到输入框 hint: $hint');
      await tester.enterText(finder, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpFrames(3);
    }

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpFrames(2);
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          fieldCipherProvider.overrideWithValue(const NoopFieldCipher()),
          photoStoreProvider.overrideWithValue(
            PhotoStore(baseDirOverride: Directory.systemTemp),
          ),
        ],
        child: const FoundHouseApp(),
      ),
    );
    await pumpFrames(12);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FoundHouseApp)),
      listen: false,
    );
    final router = container.read(appRouterProvider);
    final villages = container.read(villageRepositoryProvider);
    final houses = container.read(houseRepositoryProvider);

    // 启动默认是首页村列表；旧地图/定位主流程文案不应出现。
    expect(find.text('首页'), findsWidgets);
    expect(find.text('还没有村'), findsOneWidget);
    expect(find.textContaining('扫楼地图'), findsNothing);
    expect(find.textContaining('经纬度'), findsNothing);
    expect(find.textContaining('高德'), findsNothing);

    // 负向入口：直接打开快速记录但没有 villageId 时，必须阻止创建无归属房源。
    router.go('/scan/quick-record');
    await pumpUntilFound(find.text('请先在首页选择一个村再记录房源'));
    expect(find.text('新版流程要求房源必须归属村，楼栋可以后补。'), findsOneWidget);
    expect(await houses.getAll(), isEmpty);
    await tester.tap(find.text('返回首页'));
    await pumpUntilFound(find.text('还没有村'));

    // 准备两个村、六种楼栋状态与显式房源，用于多维度页面校验。
    final shangshaId = await villages.createVillage(
      name: '上沙村',
      status: VillageStatus.scouting,
    );
    final baishizhouId = await villages.createVillage(
      name: '白石洲',
      status: VillageStatus.preparing,
    );
    final firstBuildingId = await villages.createBuilding(
      villageId: shangshaId,
      name: '1号楼',
      status: BuildingStatus.notScouted,
    );
    await villages.createBuilding(
      villageId: shangshaId,
      name: '2号楼',
      status: BuildingStatus.noVacancy,
    );
    await villages.createBuilding(
      villageId: shangshaId,
      name: '3号楼',
      status: BuildingStatus.hasVacancy,
    );
    await villages.createBuilding(
      villageId: shangshaId,
      name: '4号楼',
      status: BuildingStatus.contacting,
    );
    await villages.createBuilding(
      villageId: shangshaId,
      name: '5号楼',
      status: BuildingStatus.needsRevisit,
    );
    await villages.createBuilding(
      villageId: shangshaId,
      name: '6号楼',
      status: BuildingStatus.abandoned,
    );
    await houses.create(
      title: '上沙候选',
      villageId: shangshaId,
      status: 'active',
      fee: const domain.FeeInfo(rentMonthly: 1800),
      room: const domain.RoomInfo(layout: '单间'),
    );
    await houses.create(
      title: '白石洲候选',
      villageId: baishizhouId,
      status: 'active',
      fee: const domain.FeeInfo(rentMonthly: 2300),
      room: const domain.RoomInfo(layout: '一房一厅'),
    );
    await pumpFrames(10);

    router.go(AppRoutes.scan);
    await pumpUntilFound(find.text('村列表'));
    expect(find.text('上沙村'), findsWidgets);
    expect(find.text('白石洲'), findsWidgets);
    expect(find.text('房源 1'), findsWidgets);
    expect(find.textContaining('定位'), findsNothing);
    expect(find.textContaining('第三方地图'), findsNothing);

    // 多入口 1：首页村卡片/继续扫楼入口记录未分楼栋房源。
    final baishizhouCard = find
        .ancestor(of: find.text('白石洲').first, matching: find.byType(Card))
        .first;
    final homeRecordButton = find
        .descendant(of: baishizhouCard, matching: find.text('记录房源'))
        .hitTestable()
        .first;
    await tester.tap(homeRecordButton);
    await pumpUntilFound(find.text('快速记录'));
    expect(find.text('可选择已有楼栋或输入新楼栋；留空则保存为未分楼栋房源。'), findsOneWidget);
    await enterByHint('如 1800', '1500');
    await enterByHint('如 A栋、东门、巷口自建楼；留空则未分楼栋', '东门自建楼');
    await enterByHint('如 501、3楼右手边', '301');
    await tester.tap(find.text('单间').hitTestable().first);
    await pumpFrames(4);
    await tester.tap(find.text('保存并离开'));
    await pumpUntilFound(find.text('首页'));
    final homeEntryHouse = (await houses.getAll()).singleWhere(
      (house) => house.roomNo == '301',
    );
    expect(homeEntryHouse.villageId, baishizhouId);
    final baishizhouBuildings =
        await villages.getBuildingsForVillage(baishizhouId);
    final createdBuilding = baishizhouBuildings.singleWhere(
      (building) => building.name == '东门自建楼',
    );
    expect(homeEntryHouse.buildingId, createdBuilding.id);
    expect(homeEntryHouse.buildingName, '东门自建楼');
    expect(homeEntryHouse.fee?.rentMonthly, 1500);

    // 村详情展示楼栋全状态，并能从村级动作记录未分楼栋房源。
    router.go('/scan/villages/$shangshaId');
    await pumpUntilFound(find.text('楼栋'));
    for (final label in ['未扫', '无空房', '有空房', '联系中', '待复访', '放弃']) {
      await scrollUntilFound(find.text(label), delta: 260);
      expect(find.text(label), findsWidgets);
    }

    router.go('/scan/villages/$shangshaId');
    await scrollUntilFound(find.text('记录房源'), delta: -260);
    await tester.tap(find.text('记录房源').hitTestable().first);
    await pumpUntilFound(find.text('快速记录'));
    expect(find.text('可选择已有楼栋或输入新楼栋；留空则保存为未分楼栋房源。'), findsOneWidget);
    await enterByHint('如 1800', '1600');
    await enterByHint('如 501、3楼右手边', '村级入口401');
    await tester.tap(find.text('一房一厅').hitTestable().first);
    await pumpFrames(4);
    await tester.tap(find.text('保存并离开'));
    await pumpUntilFound(find.text('上沙村'));
    final villageEntryHouse = (await houses.getAll()).singleWhere(
      (house) => house.roomNo == '村级入口401',
    );
    expect(villageEntryHouse.villageId, shangshaId);
    expect(villageEntryHouse.buildingId, isNull);
    expect(villageEntryHouse.fee?.rentMonthly, 1600);
    expect(villageEntryHouse.room?.layout, '一房一厅');

    // 多入口 2：楼栋卡片入口记录房源，必须写入 buildingId。
    router.go('/scan/villages/$shangshaId');
    await scrollUntilFound(find.text('1号楼'), delta: -260);
    final buildingCard =
        find.ancestor(of: find.text('1号楼'), matching: find.byType(Card)).first;
    final buildingRecordButton = find
        .descendant(of: buildingCard, matching: find.text('在此楼记录房源'))
        .hitTestable()
        .first;
    await tester.tap(buildingRecordButton);
    await pumpUntilFound(find.text('已归属楼栋：1号楼'));
    await enterByHint('如 1800', '1700');
    await enterByHint('如 501、3楼右手边', '楼栋入口501');
    await tester.tap(find.text('单间').hitTestable().first);
    await pumpFrames(4);
    await tester.tap(find.text('保存并离开'));
    await pumpUntilFound(find.text('上沙村'));
    final buildingEntryHouse = (await houses.getAll()).singleWhere(
      (house) => house.roomNo == '楼栋入口501',
    );
    expect(buildingEntryHouse.villageId, shangshaId);
    expect(buildingEntryHouse.buildingId, firstBuildingId);
    expect(buildingEntryHouse.fee?.rentMonthly, 1700);
    expect(buildingEntryHouse.room?.layout, '单间');

    // 房源页：村筛选、排序入口与筛选空态。
    final emptyVillageId = await villages.createVillage(name: '岗厦村');
    expect(emptyVillageId, isNotEmpty);
    router.go(AppRoutes.houses);
    await pumpUntilFound(find.text('推荐'));
    expect(find.text('价格'), findsOneWidget);
    expect(find.text('通勤'), findsOneWidget);
    expect(find.text('最近'), findsOneWidget);
    expect(find.text('上沙候选'), findsOneWidget);
    expect(find.text('白石洲候选'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '白石洲'));
    await pumpFrames(8);
    expect(find.text('白石洲候选'), findsOneWidget);
    expect(find.text('上沙候选'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, '全部'));
    await pumpFrames(6);
    await tester.drag(find.byType(Scrollable).first, const Offset(-500, 0));
    await pumpFrames(4);
    final gangxiaChip = find.widgetWithText(ChoiceChip, '岗厦村');
    await pumpUntilFound(gangxiaChip);
    await tester.tap(gangxiaChip);
    await pumpFrames(8);
    expect(find.text('这个村还没有房源记录'), findsOneWidget);

    // 对比页：未选够 2 套时给出边界提示；选够后出现正式对比表和脱敏导出提示。
    router.go(AppRoutes.compare);
    await pumpUntilFound(find.text('选择要对比的房源（至少 2 套）'));
    expect(find.text('选择房源开始对比'), findsOneWidget);
    expect(find.textContaining('在上方至少选择 2 套房源'), findsOneWidget);
    await tester.tap(find.text('上沙候选').hitTestable().first);
    await pumpFrames(6);
    expect(find.text('选择房源开始对比'), findsOneWidget);
    await tester.tap(find.text('白石洲候选').hitTestable().first);
    await pumpFrames(8);
    expect(find.text('月总成本'), findsOneWidget);
    expect(find.text('总分'), findsOneWidget);
    expect(find.text('导出默认隐藏联系人、门牌、详细地址'), findsOneWidget);
    expect(find.textContaining('扫楼地图'), findsNothing);
    expect(find.textContaining('定位失败'), findsNothing);
  });
}
