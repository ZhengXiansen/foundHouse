// W4 决策 UI widget 冒烟测试（列表 / 评分详情 / 对比）。
//
// 目标：套 ProviderScope pumpWidget 不崩即通过，并校验关键可见文案
// （空状态、总分、维度分、红线置顶、对比表与结论）。
//
// 关键：页面消费 drift live query 流（watchAll/watch），其底层 Timer 在测试
// widget 树 dispose 后仍挂起，会触发「A Timer is still pending」断言。故本测试
// 用 Stream.value 覆盖 housesStreamProvider / preferenceProfileProvider（一次性
// 发射后关闭，无挂起 Timer），并直接构造内存领域对象，不经过 drift 数据库。
// 评分详情页的 houseScoreViewProvider 走一次性 getById，用内存库注入即可。

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:found_house_app/features/compare/compare_page.dart';
import 'package:found_house_app/features/house/house_list_page.dart';
import 'package:found_house_app/features/scoring/house_scoring_controller.dart';
import 'package:found_house_app/features/scoring/score_detail_page.dart';

/// 构造最小房源（含费用，避免全缺失时的边界）。
domain.HouseRecord buildHouse({
  required String id,
  required String title,
  domain.FeeInfo? fee,
  List<domain.RiskFlag> riskFlags = const [],
  String villageId = domain.VillageDefaults.unassignedVillageId,
}) {
  return domain.HouseRecord(
    id: id,
    title: title,
    status: 'active',
    villageId: villageId,
    createdAt: 1,
    updatedAt: 1,
    fee: fee ??
        const domain.FeeInfo(
          rentMonthly: 1500,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
    riskFlags: riskFlags,
  );
}

const domain.PreferenceProfile _pref = domain.PreferenceProfile(
  id: 'default',
  maxRentTotal: 5000,
  maxCommuteMinutes: 60,
);

domain.VillageWithStats _villageStat({
  required String id,
  required String name,
  int buildingCount = 0,
  int houseCount = 0,
  int shortlistedCount = 0,
  int revisitCount = 0,
  int unassignedHouseCount = 0,
}) {
  return domain.VillageWithStats(
    village: domain.Village(
      id: id,
      name: name,
      createdAt: 1,
      updatedAt: 1,
    ),
    buildingCount: buildingCount,
    houseCount: houseCount,
    shortlistedCount: shortlistedCount,
    revisitCount: revisitCount,
    unassignedHouseCount: unassignedHouseCount,
  );
}

void main() {
  /// 放大视口，让 ListView/Column 一次性构建全部内容（默认 800x600 会裁剪）。
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// 覆盖高层流 provider 为一次性 Stream.value（无挂起 Timer）。
  Widget wrapStreams(
    Widget child, {
    required List<domain.HouseRecord> houses,
    List<domain.VillageWithStats> villages = const [],
  }) {
    return ProviderScope(
      overrides: [
        housesStreamProvider.overrideWith((ref) => Stream.value(houses)),
        preferenceProfileProvider.overrideWith((ref) => Stream.value(_pref)),
        villagesWithStatsProvider.overrideWith((ref) => Stream.value(villages)),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('房源列表页', () {
    testWidgets('空列表展示引导文案', (tester) async {
      await tester.pumpWidget(wrapStreams(const HouseListPage(), houses: []));
      await tester.pump();
      await tester.pump();
      expect(find.text('还没有房源记录'), findsOneWidget);
      expect(find.text('开始扫楼'), findsOneWidget);
    });

    testWidgets('有房源时渲染卡片与排序分段', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(
        wrapStreams(
          const HouseListPage(),
          houses: [buildHouse(id: 'h1', title: '阳光小区一房')],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('阳光小区一房'), findsOneWidget);
      expect(find.text('推荐'), findsOneWidget);
      expect(find.text('价格'), findsOneWidget);
    });

    testWidgets('可按村筛选复盘房源', (tester) async {
      useTallSurface(tester);
      final villageA = _villageStat(id: 'v-a', name: '上沙村', houseCount: 1);
      final villageB = _villageStat(id: 'v-b', name: '下沙村', houseCount: 1);
      await tester.pumpWidget(
        wrapStreams(
          const HouseListPage(),
          villages: [villageA, villageB],
          houses: [
            buildHouse(id: 'h-a', title: '上沙一房', villageId: 'v-a'),
            buildHouse(id: 'h-b', title: '下沙单间', villageId: 'v-b'),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('上沙一房'), findsOneWidget);
      expect(find.text('下沙单间'), findsOneWidget);

      await tester.tap(find.text('上沙村'));
      await tester.pump();
      await tester.pump();

      expect(find.text('上沙一房'), findsOneWidget);
      expect(find.text('下沙单间'), findsNothing);
    });

    testWidgets('命中 blocker 的房源在列表展示「已淘汰」不隐藏', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(
        wrapStreams(
          const HouseListPage(),
          houses: [
            buildHouse(
              id: 'h1',
              title: '红线房源',
              riskFlags: const [
                domain.RiskFlag(
                  id: 'r1',
                  houseId: 'h1',
                  key: 'risk_non_residential',
                  severity: 'blocker',
                ),
              ],
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('红线房源'), findsOneWidget);
      expect(find.text('已淘汰'), findsWidgets);
    });
  });

  group('对比页', () {
    testWidgets('房源不足 2 套展示提示', (tester) async {
      await tester.pumpWidget(
        wrapStreams(
          const ComparePage(),
          houses: [buildHouse(id: 'h1', title: '仅一套')],
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('至少需要 2 套房源才能对比'), findsOneWidget);
    });

    testWidgets('选中 2 套后展示对比表与导出按钮', (tester) async {
      useTallSurface(tester);
      await tester.pumpWidget(
        wrapStreams(
          const ComparePage(),
          houses: [
            buildHouse(id: 'a', title: '房源A'),
            buildHouse(id: 'b', title: '房源B'),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('房源A').first);
      await tester.pump();
      await tester.tap(find.text('房源B').first);
      await tester.pump();
      await tester.pump();

      expect(find.text('月总成本'), findsOneWidget);
      expect(find.text('导出对比'), findsOneWidget);
      expect(find.textContaining('经纬度'), findsNothing);
    });
  });

  group('评分详情页', () {
    late AppDatabase db;
    late HouseRepository repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      repo = HouseRepository(
        db: db,
        cipher: const NoopFieldCipher(),
        photoStore: PhotoStore(baseDirOverride: Directory.systemTemp),
      );
    });

    tearDown(() async {
      await db.close();
    });

    /// 评分详情用一次性 getById（无 Timer）；偏好流仍覆盖为 Stream.value。
    Widget wrapDetail(Widget child) {
      return ProviderScope(
        overrides: [
          houseRepositoryProvider.overrideWithValue(repo),
          preferenceProfileProvider.overrideWith((ref) => Stream.value(_pref)),
        ],
        child: MaterialApp(home: child),
      );
    }

    testWidgets('展示总分区与维度分', (tester) async {
      useTallSurface(tester);
      final id = await repo.create(title: '待评分房源');
      await repo.updateFee(
        id,
        const domain.FeeInfo(
          rentMonthly: 1500,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
      );
      await tester.pumpWidget(wrapDetail(ScoreDetailPage(houseId: id)));
      await tester.pump();
      await tester.pump();

      expect(find.text('总分'), findsWidgets);
      expect(find.text('维度分'), findsOneWidget);
      expect(find.text('自动评分'), findsOneWidget);
      expect(find.textContaining('POI'), findsNothing);
      expect(find.textContaining('高德'), findsNothing);
    });

    testWidgets('命中 blocker 展示红线置顶', (tester) async {
      useTallSurface(tester);
      final id = await repo.create(title: '红线房源');
      await repo.addRiskFlag(
        id,
        key: 'risk_non_residential',
        severity: 'blocker',
      );
      await tester.pumpWidget(wrapDetail(ScoreDetailPage(houseId: id)));
      await tester.pump();
      await tester.pump();

      expect(find.text('已淘汰：命中红线风险'), findsOneWidget);
    });

    testWidgets('关闭自动评分隐藏维度分', (tester) async {
      useTallSurface(tester);
      final id = await repo.create(title: '可关评分房源');
      await tester.pumpWidget(wrapDetail(ScoreDetailPage(houseId: id)));
      await tester.pump();
      await tester.pump();

      expect(find.text('维度分'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump();
      expect(find.text('自动评分已关闭'), findsOneWidget);
      expect(find.text('维度分'), findsNothing);
    });
  });
}
