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
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android 真机主流程：村首页、楼栋、快速记录、详情、Checklist、偏好、对比', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');

    Future<void> pumpFrames([int count = 8]) async {
      for (var i = 0; i < count; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilFound(Finder finder, {int maxFrames = 40}) async {
      for (var i = 0; i < maxFrames; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) return;
      }
      expect(finder, findsWidgets);
    }

    Future<void> scrollUntilFound(
      Finder finder, {
      double delta = 300,
      int maxScrolls = 24,
    }) async {
      final scrollable = find.byType(Scrollable).last;
      for (var i = 0; i < maxScrolls; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) {
          await tester.ensureVisible(finder);
          await tester.pump(const Duration(milliseconds: 100));
          if (finder.evaluate().isNotEmpty) return;
        }
        await tester.drag(scrollable, Offset(0, -delta));
      }
      expect(finder, findsWidgets);
    }

    Future<void> enterByHint(String hint, String value) async {
      final finder = find.widgetWithText(TextField, hint);
      await tester.ensureVisible(finder);
      await pumpFrames(2);
      expect(finder, findsOneWidget, reason: '应找到输入框 hint: $hint');
      await tester.enterText(finder, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpFrames(2);
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
    final houses = container.read(houseRepositoryProvider);
    final villages = container.read(villageRepositoryProvider);
    final preferences = container.read(preferenceRepositoryProvider);

    // 新版主流程：启动默认进入首页/村列表，不再出现地图或定位依赖文案。
    expect(find.text('首页'), findsWidgets);
    expect(find.text('还没有村'), findsOneWidget);
    expect(find.text('新增村'), findsWidgets);
    expect(find.text('房源'), findsOneWidget);
    expect(find.text('对比'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.textContaining('扫楼地图'), findsNothing);
    expect(find.textContaining('定位'), findsNothing);

    // 手动新增村。
    await tester.tap(find.text('新增村').last);
    await pumpFrames(4);
    await tester.enterText(find.widgetWithText(TextField, '村名'), '白石洲');
    await tester.tap(find.text('保存'));
    await pumpUntilFound(find.text('白石洲'));
    final villageList = await villages.getVillagesWithStats();
    final village =
        villageList.singleWhere((item) => item.village.name == '白石洲').village;

    // 进入村详情并新增楼栋。
    await tester.tap(find.text('进入村'));
    await pumpUntilFound(find.text('新增楼栋'));
    expect(find.text('白石洲'), findsWidgets);

    await tester.tap(find.text('新增楼栋').first);
    await pumpFrames(4);
    await tester.enterText(find.widgetWithText(TextField, '楼栋/入口名'), '1号楼');
    await tester.tap(find.text('保存'));
    await pumpUntilFound(find.text('1号楼'));
    expect(find.text('在此楼记录房源'), findsOneWidget);

    final buildingList = await villages.getBuildingsForVillage(village.id);
    final building = buildingList.singleWhere((item) => item.name == '1号楼');

    // 在具体楼栋下快速记录，并通过“去补全”进入房源详情。
    await tester.tap(find.text('在此楼记录房源'));
    await pumpUntilFound(find.text('快速记录'));
    expect(find.text('已归属楼栋：1号楼'), findsOneWidget);
    await enterByHint('如 1800', '1800');
    await enterByHint('如 501、3楼右手边', '701');
    await scrollUntilFound(find.text('单间'));
    await tester.tap(find.text('单间'));
    await pumpFrames(6);
    await tester.tap(find.text('去补全'));
    await pumpUntilFound(find.text('房源详情'));
    // 真机 route replacement 退出动画结束前，旧 AppBar 文案可能短暂仍在树中。
    await pumpFrames(8);
    expect(find.text('快速记录'), findsNothing);

    final afterQuickRecord = await houses.getAll();
    expect(afterQuickRecord, isNotEmpty);
    final quickRecord = afterQuickRecord.firstWhere(
      (house) =>
          house.villageId == village.id && house.buildingId == building.id,
    );
    expect(quickRecord.fee?.rentMonthly, 1800);
    expect(quickRecord.roomNo, '701');
    expect(quickRecord.room?.layout, '单间');

    // 详情页基础字段防抖自动保存。
    await enterByHint('如 城中村单间 · 白石洲', '真机测试 A');
    await enterByHint('街道门牌或大致位置', '南山测试街 9 号');
    await enterByHint('如 302', '701');
    await pumpFrames(8); // 等待 500ms 防抖保存。
    final edited = await houses.getById(quickRecord.id);
    expect(edited, isNotNull);
    expect(edited!.title, '真机测试 A');
    expect(edited.addressText, '南山测试街 9 号');
    expect(edited.roomNo, '701');
    expect(edited.villageId, village.id);
    expect(edited.buildingId, building.id);

    // Checklist 记录普通检查项，随后风险摘要能响应子表变化刷新。
    await tester.ensureVisible(find.text('看房清单'));
    await pumpFrames(2);
    await tester.tap(find.text('看房清单'));
    await pumpUntilFound(find.text('采光'));
    await tester.tap(find.text('好').first);
    await pumpFrames(6);
    final checklistItems = await houses.getChecklistItems(quickRecord.id);
    expect(
      checklistItems.where((item) => item.key == 'room_lighting').single.value,
      'good',
    );

    await houses.addRiskFlag(
      quickRecord.id,
      key: 'risk_non_residential',
      severity: 'blocker',
    );
    await tester.pageBack();
    await pumpUntilFound(find.text('房源详情'));
    await pumpFrames(6);
    final riskFlags = await houses.getRiskFlags(quickRecord.id);
    expect(
      riskFlags.where((flag) => flag.severity == 'blocker'),
      isNotEmpty,
    );
    await scrollUntilFound(find.text('风险'), delta: 350);
    expect(find.text('风险'), findsOneWidget);
    expect(find.textContaining('红线'), findsWidgets);

    // 补充第二套用于列表与对比。
    final secondId = await houses.create(
      title: '真机测试 B',
      status: 'active',
      villageId: village.id,
      addressText: '科技园测试点',
      fee: const domain.FeeInfo(
        rentMonthly: 2200,
        deposit: 2200,
        waterUnitPrice: 5,
        electricityUnitPrice: 1,
      ),
      room: const domain.RoomInfo(
        layout: '一房一厅',
        area: 28,
        hasPrivateBathroom: true,
        hasKitchen: true,
      ),
    );
    expect(await houses.getById(secondId), isNotNull);
    await pumpFrames(8);

    // 房源列表展示记录与排序入口，并可进入详情。
    router.go(AppRoutes.houses);
    await pumpUntilFound(find.text('推荐'));
    expect(find.text('价格'), findsOneWidget);
    final visibleHouseATitle = find.text('真机测试 A').hitTestable().first;
    expect(visibleHouseATitle, findsOneWidget);
    await tester.tap(visibleHouseATitle);
    await pumpUntilFound(find.text('房源详情'));

    // 偏好设置保存预算/通勤/目的地。
    router.go('/settings/preference');
    await pumpUntilFound(find.text('偏好设置'));
    await enterByHint('如 2500', '3200');
    await enterByHint('如 45', '35');
    await enterByHint('如 科技园', '科技园');
    await tester.tap(find.text('保存').first);
    await pumpFrames(12);
    final pref = await preferences.load();
    expect(pref, isNotNull);
    expect(pref!.maxRentTotal, 3200);
    expect(pref.maxCommuteMinutes, 35);
    expect(pref.destinationsJson, contains('科技园'));

    // 对比选择两套房源，展示表格、总分/成本与脱敏导出提示。
    router.go(AppRoutes.compare);
    await pumpUntilFound(find.text('选择要对比的房源（至少 2 套）'));
    await tester.tap(find.text('真机测试 A').hitTestable().first);
    await pumpFrames(4);
    await tester.tap(find.text('真机测试 B').hitTestable().first);
    await pumpFrames(8);
    expect(find.text('月总成本'), findsOneWidget);
    expect(find.text('总分'), findsOneWidget);
    expect(find.text('风险/淘汰'), findsOneWidget);
    expect(find.text('已淘汰(红线)'), findsOneWidget);
    expect(find.text('导出默认隐藏联系人、门牌、详细地址'), findsOneWidget);
    expect(find.text('导出对比'), findsOneWidget);

    // 隐私说明页展示关键脱敏/加密策略。
    router.go('/settings/privacy');
    await pumpUntilFound(find.text('隐私设置'));
    await pumpFrames(4);
    await scrollUntilFound(find.text('本地优先'), delta: -350);
    expect(find.text('本地优先'), findsOneWidget);
    expect(find.text('敏感字段加密'), findsOneWidget);
    await scrollUntilFound(find.text('隐藏联系人'), delta: 350);
    expect(find.text('隐藏联系人'), findsOneWidget);
  });
}
