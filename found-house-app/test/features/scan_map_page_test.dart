import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/app/app.dart';
import 'package:found_house_app/app/theme.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:found_house_app/data/repositories/village_repository.dart';
import 'package:found_house_app/features/common/delete_confirmation.dart';
import 'package:found_house_app/features/house/house_list_page.dart';
import 'package:found_house_app/features/scan/quick_record_page.dart';
import 'package:found_house_app/features/scan/village_detail_page.dart';
import 'package:found_house_app/features/scan/village_home_page.dart';
import 'package:found_house_app/features/scoring/house_scoring_controller.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('滑动删除在右侧显示，只允许左滑露出，小幅和右滑都会收回且默认不暴露删除语义', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              height: 80,
              child: SwipeDeleteAction(
                onDelete: () async {},
                child: Container(
                  key: const Key('swipe-child'),
                  width: 240,
                  height: 64,
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: const Text('可滑动卡片'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    bool endSemanticsExcluded() => tester
        .widget<ExcludeSemantics>(
          find.byKey(const Key('swipe-delete-end-semantics')),
        )
        .excluding;

    final child = find.byKey(const Key('swipe-child'));
    final initialLeft = tester.getTopLeft(child).dx;
    expect(endSemanticsExcluded(), isTrue);

    await tester.drag(child, const Offset(-20, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(child).dx, initialLeft);
    expect(endSemanticsExcluded(), isTrue);

    await tester.drag(child, const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(child).dx,
      initialLeft,
      reason: '右滑/左向右拖动不应移动内容或露出左侧删除操作',
    );
    expect(endSemanticsExcluded(), isTrue);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.drag(child, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(child).dx - initialLeft,
      moreOrLessEquals(-88, epsilon: 0.1),
    );
    expect(endSemanticsExcluded(), isFalse);
  });

  testWidgets('滑动删除默认不露出红色操作背景，滑动后才显示删除区', (tester) async {
    final boundaryKey = UniqueKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: 320,
                child: SwipeDeleteAction(
                  onDelete: () async {},
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      key: const Key('swipe-visual-card'),
                      height: 64,
                      alignment: Alignment.centerLeft,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: const Text('默认卡片'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      await _countRiskPixels(tester, boundaryKey),
      lessThan(20),
      reason: '未滑动时不能从卡片外边距透出红色删除背景',
    );
    final initialVisualRect = tester.getRect(
      find.byKey(const Key('swipe-visual-card')),
    );

    await tester.drag(
      find.byKey(const Key('swipe-visual-card')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(
      await _countRiskPixels(tester, boundaryKey),
      greaterThan(1000),
      reason: '滑动后应露出红色删除操作区',
    );

    final visualRect =
        tester.getRect(find.byKey(const Key('swipe-visual-card')));
    final actionRect = tester.getRect(
      find.byKey(const Key('swipe-delete-end-action')),
    );
    expect(
      actionRect.top,
      moreOrLessEquals(visualRect.top, epsilon: 0.1),
      reason: '红色删除区顶部必须和可见数据行顶部对齐，不能覆盖卡片外边距',
    );
    expect(
      actionRect.height,
      moreOrLessEquals(initialVisualRect.height, epsilon: 0.1),
      reason: '红色删除区高度必须等于可见数据行高度，不能比分隔/外边距更高',
    );
    expect(
      actionRect.right,
      moreOrLessEquals(initialVisualRect.right, epsilon: 0.1),
      reason: '红色删除区右边缘必须和可见数据行右边缘对齐',
    );
  });

  testWidgets('快速记录空表单不创建房源，必填保存后归属到村', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(
      name: '上沙村',
      status: VillageStatus.scouting,
    );

    await tester.pumpWidget(fixture.wrapApp(const FoundHouseApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('首页'), findsWidgets);
    expect(find.text('上沙村'), findsWidgets);
    expect(find.text('记录房源'), findsWidgets);
    expect(find.text('扫楼地图'), findsNothing);

    await tester
        .tap(find.widgetWithText(FilledButton, '记录房源').hitTestable().first);
    await tester.pump();
    await _pumpFramesUntilFound(tester, find.text('保存并离开'));

    expect(find.text('快速记录'), findsOneWidget);
    expect(find.byKey(const Key('quick-rent-field')), findsOneWidget);
    expect(find.byKey(const Key('quick-room-field')), findsOneWidget);
    final rentLabel = find.text('① 月租 *');
    final roomLabel = find.text('② 门牌/房号 *');
    final layoutLabel = find.text('③ 房型 *');
    final photoLabel = find.text('④ 拍照/相册（可选）');
    expect(rentLabel, findsOneWidget);
    expect(roomLabel, findsOneWidget);
    expect(layoutLabel, findsOneWidget);
    expect(photoLabel, findsOneWidget);
    final buildingField = find.byKey(const Key('quick-building-field'));
    expect(buildingField, findsOneWidget);
    expect(find.text('还没有楼栋；输入楼栋名保存时会自动创建。'), findsOneWidget);
    expect(
      tester.getTopLeft(buildingField).dy,
      lessThan(tester.getTopLeft(rentLabel).dy),
    );
    expect(
      tester.getTopLeft(rentLabel).dy,
      lessThan(tester.getTopLeft(roomLabel).dy),
    );
    expect(
      tester.getTopLeft(roomLabel).dy,
      lessThan(tester.getTopLeft(layoutLabel).dy),
    );
    expect(
      tester.getTopLeft(layoutLabel).dy,
      lessThan(tester.getTopLeft(photoLabel).dy),
    );
    expect(await fixture.houses.getAll(), isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, '保存并离开').hitTestable());
    await tester.pump();
    expect(find.text('请填写月租、门牌/房号、房型'), findsOneWidget);
    expect(await fixture.houses.getAll(), isEmpty);

    await _fillRequiredQuickRecord(tester, rent: '1800', roomNo: '501');
    await _tapSaveAndLeave(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('快速记录', skipOffstage: false), findsNothing);

    final houses = await fixture.houses.getAll();
    expect(houses, hasLength(1));
    expect(houses.single.villageId, villageId);
    expect(houses.single.buildingId, isNull);
    expect(houses.single.fee?.rentMonthly, 1800);
    expect(houses.single.roomNo, '501');
    expect(houses.single.room?.layout, '单间');

    await _unmountApp(tester);
  });

  testWidgets('快速记录拒绝部分必填和非法租金，修改后清除错误提示', (tester) async {
    final cases =
        <({String name, String? rent, String? roomNo, String? layout})>[
      (name: 'only rent', rent: '1800', roomNo: null, layout: null),
      (name: 'only room', rent: null, roomNo: '501', layout: null),
      (name: 'only layout', rent: null, roomNo: null, layout: '单间'),
      (name: 'zero rent', rent: '0', roomNo: '501', layout: '单间'),
      (name: 'negative rent', rent: '-1', roomNo: '501', layout: '单间'),
      (name: 'non numeric rent', rent: 'abc', roomNo: '501', layout: '单间'),
    ];

    for (final invalidCase in cases) {
      final fixture = await _AppFixture.create();
      await fixture.villages.createVillage(name: '边界村-${invalidCase.name}');
      try {
        await tester.pumpWidget(fixture.wrapApp(const FoundHouseApp()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        await tester.tap(
          find.widgetWithText(FilledButton, '记录房源').hitTestable().first,
        );
        await tester.pump();
        await _pumpFramesUntilFound(tester, find.text('保存并离开'));

        if (invalidCase.rent != null) {
          await _enterKeyedText(
            tester,
            const Key('quick-rent-field'),
            invalidCase.rent!,
          );
        }
        if (invalidCase.roomNo != null) {
          await _enterKeyedText(
            tester,
            const Key('quick-room-field'),
            invalidCase.roomNo!,
          );
        }
        if (invalidCase.layout != null) {
          await _selectLayout(tester, invalidCase.layout!);
        }

        await _tapSaveAndLeave(tester);
        expect(find.text('请填写月租、门牌/房号、房型'), findsOneWidget);
        expect(await fixture.houses.getAll(), isEmpty);

        await _enterKeyedText(tester, const Key('quick-rent-field'), '1888');
        expect(find.text('请填写月租、门牌/房号、房型'), findsNothing);
      } finally {
        await _unmountApp(tester);
        await fixture.dispose();
      }
    }
  });

  testWidgets('快速记录去补全会先校验并创建房源再进入详情', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    await fixture.villages.createVillage(
      name: '上下沙村',
      status: VillageStatus.scouting,
    );

    await tester.pumpWidget(fixture.wrapApp(const FoundHouseApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester
        .tap(find.widgetWithText(FilledButton, '记录房源').hitTestable().first);
    await tester.pump();
    await _pumpFramesUntilFound(tester, find.text('去补全'));

    expect(await fixture.houses.getAll(), isEmpty);

    await tester.tap(find.widgetWithText(TextButton, '去补全').hitTestable());
    await tester.pump();
    expect(find.text('请填写月租、门牌/房号、房型'), findsOneWidget);
    expect(await fixture.houses.getAll(), isEmpty);

    await _fillRequiredQuickRecord(tester, rent: '2200', roomNo: '702');
    await tester.tap(find.widgetWithText(TextButton, '去补全').hitTestable());
    await tester.pump();
    expect(tester.takeException(), isNull);
    await _pumpFramesUntilFound(tester, find.text('房源详情'));

    expect(find.text('房源详情'), findsOneWidget);
    expect(find.text('快速记录'), findsNothing);
    expect(find.text('快速记录', skipOffstage: false), findsNothing);
    final houses = await fixture.houses.getAll();
    expect(houses, hasLength(1));

    await tester.tap(find.byTooltip('Back').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('上下沙村'), findsWidgets);
    expect(find.text('快速记录'), findsNothing);

    await _unmountApp(tester);
  });

  testWidgets('快速记录单页 fallback 去补全不依赖 GoRouter', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '单页村');

    await tester.pumpWidget(
      fixture.wrapPage(QuickRecordPage(villageId: villageId)),
    );
    await tester.pump();

    await _fillRequiredQuickRecord(tester, rent: '2100', roomNo: '801');
    await tester.tap(find.widgetWithText(TextButton, '去补全').hitTestable());
    await tester.pump();
    expect(tester.takeException(), isNull);
    await _pumpFramesUntilFound(tester, find.text('房源详情'));

    expect(find.text('房源详情'), findsOneWidget);
    expect(find.text('快速记录', skipOffstage: false), findsNothing);
    expect(await fixture.houses.getAll(), hasLength(1));

    await _unmountApp(tester);
  });

  testWidgets('快速记录单页 fallback 保存并离开不依赖 GoRouter', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '单页保存村');

    await tester.pumpWidget(
      fixture.wrapPage(QuickRecordPage(villageId: villageId)),
    );
    await tester.pump();

    await _fillRequiredQuickRecord(tester, rent: '2300', roomNo: '901');
    await _tapSaveAndLeave(tester);
    expect(tester.takeException(), isNull);
    expect(await fixture.houses.getAll(), hasLength(1));

    await _unmountApp(tester);
  });

  testWidgets('缺失村的快速记录 fallback 返回首页不依赖 GoRouter', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      fixture.wrapPage(const QuickRecordPage(villageId: '')),
    );
    await tester.pump();

    expect(find.text('请先在首页选择一个村再记录房源'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '返回首页').hitTestable());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('请先在首页选择一个村再记录房源'), findsOneWidget);
    expect(await fixture.houses.getAll(), isEmpty);

    await _unmountApp(tester);
  });

  testWidgets('缺失村的快速记录 fallback 可从 Navigator 栈返回上一页', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    await tester.pumpWidget(
      fixture.wrapPage(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const QuickRecordPage(villageId: ''),
                    ),
                  );
                },
                child: const Text('打开缺失村页'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, '打开缺失村页'));
    await tester.pumpAndSettle();
    expect(find.text('请先在首页选择一个村再记录房源'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '返回首页').hitTestable());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('打开缺失村页'), findsOneWidget);
    expect(find.text('请先在首页选择一个村再记录房源'), findsNothing);

    await _unmountApp(tester);
  });

  testWidgets('缺失村的快速记录在 GoRouter 环境返回首页', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final router = GoRouter(
      initialLocation: '/scan/quick-record',
      routes: [
        GoRoute(
          path: '/scan',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('首页村列表')),
          ),
          routes: [
            GoRoute(
              path: 'quick-record',
              builder: (context, state) => const QuickRecordPage(villageId: ''),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      fixture.wrapApp(
        MaterialApp.router(
          theme: buildAppTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('请先在首页选择一个村再记录房源'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '返回首页').hitTestable());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('首页村列表'), findsOneWidget);
    expect(find.text('请先在首页选择一个村再记录房源'), findsNothing);

    await _unmountApp(tester);
  });

  testWidgets('村级快速记录可选择已有楼栋或输入新楼栋后自动创建绑定', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '石牌村');
    final existingBuildingId = await fixture.villages.createBuilding(
      villageId: villageId,
      name: 'A栋',
    );

    await tester.pumpWidget(fixture.wrapApp(const FoundHouseApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester
        .tap(find.widgetWithText(FilledButton, '记录房源').hitTestable().first);
    await tester.pump();
    await _pumpFramesUntilFound(
      tester,
      find.byKey(const Key('quick-building-field')).hitTestable(),
    );
    await tester.tap(find.widgetWithText(ActionChip, 'A栋').hitTestable());
    await tester.pump();
    await _fillRequiredQuickRecord(tester, rent: '1600', roomNo: '301');
    await _tapSaveAndLeave(tester);
    await _pumpFramesUntilFound(tester, find.text('首页'));
    await tester.pump(const Duration(milliseconds: 300));

    var houses = await fixture.houses.getAll();
    expect(houses, hasLength(1));
    expect(houses.single.buildingId, existingBuildingId);
    expect(
      (await fixture.villages.getBuildingsForVillage(villageId)),
      hasLength(1),
    );

    await tester
        .tap(find.widgetWithText(FilledButton, '记录房源').hitTestable().first);
    await tester.pump();
    await _pumpFramesUntilFound(
      tester,
      find.byKey(const Key('quick-building-field')).hitTestable(),
    );
    await _fillRequiredQuickRecord(
      tester,
      rent: '1700',
      roomNo: '402',
      buildingName: 'B栋',
    );
    await _tapSaveAndLeave(tester);
    await _pumpFramesUntilFound(tester, find.text('首页'));
    await tester.pump(const Duration(milliseconds: 300));

    final buildings = await fixture.villages.getBuildingsForVillage(villageId);
    expect(buildings.map((b) => b.name), containsAll(['A栋', 'B栋']));
    houses = await fixture.houses.getAll();
    final newHouse = houses.singleWhere((h) => h.roomNo == '402');
    final newBuilding = buildings.singleWhere((b) => b.name == 'B栋');
    expect(newHouse.buildingId, newBuilding.id);
    expect(newHouse.buildingName, 'B栋');

    await _unmountApp(tester);
  });

  testWidgets('新楼栋创建后房源保存失败会回滚空楼栋', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '回滚村');
    final throwingHouses = _ThrowingHouseRepository(
      db: fixture.db,
      cipher: const NoopFieldCipher(),
      photoStore: fixture.photoStore,
    );

    await tester.pumpWidget(
      fixture.wrapPage(
        QuickRecordPage(villageId: villageId),
        houseRepositoryOverride: throwingHouses,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await _pumpFramesUntilFound(
      tester,
      find.byKey(const Key('quick-building-field')).hitTestable(),
    );

    await _fillRequiredQuickRecord(
      tester,
      rent: '1800',
      roomNo: '501',
      buildingName: '失败回滚楼',
    );
    await _tapSaveAndLeave(tester);
    await _pumpUntil(tester, () async {
      final buildings =
          await fixture.villages.getBuildingsForVillage(villageId);
      final rolledBack =
          buildings.every((building) => building.name != '失败回滚楼');
      return rolledBack && find.textContaining('保存失败').evaluate().isNotEmpty;
    });

    expect(await fixture.houses.getAll(), isEmpty);
    final buildings = await fixture.villages.getBuildingsForVillage(villageId);
    expect(
      buildings.map((building) => building.name),
      isNot(contains('失败回滚楼')),
    );
    expect(find.textContaining('保存失败'), findsWidgets);

    await _unmountApp(tester);
  });

  testWidgets('村首页展示村统计，不出现地图/定位文案', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '岗厦村');
    await fixture.villages.createBuilding(
      villageId: villageId,
      name: 'A栋',
      status: BuildingStatus.needsRevisit,
    );
    await fixture.houses.create(
      title: 'A栋 501',
      villageId: villageId,
      status: 'shortlisted',
    );
    await fixture.houses.create(title: '待分楼栋', villageId: villageId);

    await tester.pumpWidget(fixture.wrapPage(const VillageHomePage()));
    await tester.pump();
    await tester.pump();

    expect(find.text('岗厦村'), findsWidgets);
    expect(find.text('楼栋 1'), findsWidgets);
    expect(find.text('房源 2'), findsWidgets);
    expect(find.text('候选 1'), findsWidgets);
    expect(find.text('待复访 1'), findsWidgets);
    expect(find.text('未分楼栋 2'), findsWidgets);
    expect(find.textContaining('地图'), findsNothing);
    expect(find.textContaining('定位'), findsNothing);

    await _unmountApp(tester);
  });

  testWidgets('点击楼栋卡进入该楼栋房源列表，只有按钮进入快速记录', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '楼栋导航村');
    final buildingAId = await fixture.villages.createBuilding(
      villageId: villageId,
      name: 'A栋',
    );
    final buildingBId = await fixture.villages.createBuilding(
      villageId: villageId,
      name: 'B栋',
    );
    await fixture.houses.create(
      title: 'A栋 501',
      villageId: villageId,
      buildingId: buildingAId,
      buildingName: 'A栋',
      roomNo: '501',
      fee: const domain.FeeInfo(rentMonthly: 1800),
      room: const domain.RoomInfo(layout: '单间'),
    );
    await fixture.houses.create(
      title: 'B栋 601',
      villageId: villageId,
      buildingId: buildingBId,
      buildingName: 'B栋',
      roomNo: '601',
      fee: const domain.FeeInfo(rentMonthly: 2100),
      room: const domain.RoomInfo(layout: '一房一厅'),
    );

    await tester.pumpWidget(
      fixture.wrapPage(VillageDetailPage(villageId: villageId)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('A栋'));
    await tester.pump();
    await _pumpFramesUntilFound(tester, find.text('A栋房源'));

    expect(find.text('A栋房源'), findsOneWidget);
    expect(find.text('快速记录'), findsNothing);
    expect(find.text('A栋 501'), findsOneWidget);
    expect(find.text('B栋 601'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    final buildingCard = find.ancestor(
      of: find.text('A栋'),
      matching: find.byType(Card),
    );
    expect(buildingCard, findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: buildingCard,
            matching: find.text('在此楼记录房源'),
          )
          .hitTestable(),
    );
    await tester.pump();
    await _pumpFramesUntilFound(tester, find.text('快速记录'));

    expect(find.text('快速记录'), findsOneWidget);
    expect(find.text('已归属楼栋：A栋'), findsOneWidget);
    expect(find.byKey(const Key('quick-building-field')), findsNothing);

    await _unmountApp(tester);
  });

  testWidgets('村详情可以新增楼栋并在楼栋下记录房源', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '白石洲');

    await tester.pumpWidget(
      fixture.wrapPage(VillageDetailPage(villageId: villageId)),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('白石洲'), findsWidgets);
    expect(find.text('新增楼栋'), findsWidgets);

    await tester.tap(find.text('新增楼栋').first);
    await tester.pump();
    await tester.enterText(find.byType(TextField), '1号楼');
    await tester.tap(find.text('保存'));
    await tester.pump();
    await tester.pump();

    expect(find.text('1号楼'), findsOneWidget);
    expect(find.text('未扫'), findsWidgets);
    final buildingCard = find.ancestor(
      of: find.text('1号楼'),
      matching: find.byType(Card),
    );
    expect(buildingCard, findsOneWidget);
    expect(
      find.descendant(
        of: buildingCard,
        matching: find.text('在此楼记录房源'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('在此楼记录房源'));
    await tester.pump();
    await _pumpFramesUntilFound(tester, find.text('快速记录'));

    expect(find.text('已归属楼栋：1号楼'), findsOneWidget);
    expect(find.byKey(const Key('quick-building-field')), findsNothing);

    await _fillRequiredQuickRecord(tester, rent: '1900', roomNo: '808');
    await _tapSaveAndLeave(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final houses = await fixture.houses.getAll();
    expect(houses, hasLength(1));
    expect(houses.single.buildingId, isNotNull);
    expect(houses.single.buildingName, '1号楼');

    await _unmountApp(tester);
  });

  testWidgets('村、楼栋和房源卡片支持左划露出右侧删除并确认删除', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '删除村');
    final buildingId = await fixture.villages.createBuilding(
      villageId: villageId,
      name: '待删楼',
    );
    final groupedHouseId = await fixture.houses.create(
      title: '待删楼 301',
      villageId: villageId,
      buildingId: buildingId,
    );
    final unassignedHouseId = await fixture.houses.create(
      title: '未分楼栋 201',
      villageId: villageId,
    );

    await tester.pumpWidget(
      fixture.wrapPage(VillageDetailPage(villageId: villageId)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await _swipeAndConfirmDelete(
      tester,
      ValueKey('building-$buildingId'),
      until: () async =>
          await fixture.villages.getBuildingById(buildingId) == null &&
          await fixture.houses.getById(groupedHouseId) == null,
    );
    expect(await fixture.villages.getBuildingById(buildingId), isNull);
    expect(await fixture.houses.getById(groupedHouseId), isNull);

    await _swipeAndConfirmDelete(
      tester,
      ValueKey('house-$unassignedHouseId'),
      until: () async =>
          await fixture.houses.getById(unassignedHouseId) == null,
    );
    expect(await fixture.houses.getById(unassignedHouseId), isNull);

    await _unmountApp(tester);

    final villageToDeleteId =
        await fixture.villages.createVillage(name: '整村右侧删除');
    final villageHouseId = await fixture.houses.create(
      title: '整村 101',
      villageId: villageToDeleteId,
    );
    await tester.pumpWidget(fixture.wrapPage(const VillageHomePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await _swipeAndConfirmDelete(
      tester,
      ValueKey('village-$villageToDeleteId'),
      until: () async =>
          await fixture.villages.getById(villageToDeleteId) == null &&
          await fixture.houses.getById(villageHouseId) == null,
    );
    expect(await fixture.villages.getById(villageToDeleteId), isNull);
    expect(await fixture.houses.getById(villageHouseId), isNull);

    await _unmountApp(tester);
  });

  testWidgets('房源列表支持左划露出右侧删除并确认删除房源', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '列表删除村');
    final houseId = await fixture.houses.create(
      title: '列表待删 501',
      villageId: villageId,
      roomNo: '501',
      fee: const domain.FeeInfo(rentMonthly: 1800),
      room: const domain.RoomInfo(layout: '单间'),
    );

    await tester.pumpWidget(fixture.wrapPage(const HouseListPage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await _swipeAndConfirmDelete(
      tester,
      ValueKey('house-$houseId'),
      until: () async => await fixture.houses.getById(houseId) == null,
    );
    expect(await fixture.houses.getById(houseId), isNull);

    await _unmountApp(tester);
  });

  testWidgets('村、楼栋和房源卡片右滑不会露出或触发删除', (tester) async {
    final fixture = await _AppFixture.create();
    addTearDown(fixture.dispose);

    final villageId = await fixture.villages.createVillage(name: '右滑不删除村');
    final buildingId = await fixture.villages.createBuilding(
      villageId: villageId,
      name: '右滑保留楼',
    );
    final groupedHouseId = await fixture.houses.create(
      title: '右滑保留楼 301',
      villageId: villageId,
      buildingId: buildingId,
    );
    final unassignedHouseId = await fixture.houses.create(
      title: '右滑保留未分楼栋 201',
      villageId: villageId,
    );

    await tester.pumpWidget(
      fixture.wrapPage(VillageDetailPage(villageId: villageId)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await _rightSwipeDoesNotExposeDelete(
      tester,
      ValueKey('building-$buildingId'),
    );
    expect(await fixture.villages.getBuildingById(buildingId), isNotNull);
    expect(await fixture.houses.getById(groupedHouseId), isNotNull);

    await _rightSwipeDoesNotExposeDelete(
      tester,
      ValueKey('house-$unassignedHouseId'),
    );
    expect(await fixture.houses.getById(unassignedHouseId), isNotNull);

    await _unmountApp(tester);

    final villageToKeepId =
        await fixture.villages.createVillage(name: '整村右滑保留');
    final villageHouseId = await fixture.houses.create(
      title: '整村右滑保留 101',
      villageId: villageToKeepId,
    );
    await tester.pumpWidget(fixture.wrapPage(const VillageHomePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await _rightSwipeDoesNotExposeDelete(
      tester,
      ValueKey('village-$villageToKeepId'),
    );
    expect(await fixture.villages.getById(villageToKeepId), isNotNull);
    expect(await fixture.houses.getById(villageHouseId), isNotNull);

    await _unmountApp(tester);
  });
}

Future<void> _selectLayout(WidgetTester tester, String layout) async {
  final layoutLabel = find.text(layout);
  expect(layoutLabel, findsWidgets);
  await tester.ensureVisible(layoutLabel.first);
  await tester.pump();
  await tester.tap(layoutLabel.hitTestable().first);
  await tester.pump();
}

Future<void> _fillRequiredQuickRecord(
  WidgetTester tester, {
  required String rent,
  required String roomNo,
  String? buildingName,
  String layout = '单间',
}) async {
  await _enterKeyedText(tester, const Key('quick-rent-field'), rent);
  if (buildingName != null) {
    await _enterKeyedText(
      tester,
      const Key('quick-building-field'),
      buildingName,
    );
  }
  await _enterKeyedText(tester, const Key('quick-room-field'), roomNo);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  tester.testTextInput.hide();
  await tester.pump();
  await _selectLayout(tester, layout);
}

Future<int> _countRiskPixels(WidgetTester tester, Key boundaryKey) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundaryKey),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data;
  });
  if (bytes == null) return 0;
  var count = 0;
  const risk = AppColors.risk;
  final riskValue = risk.toARGB32();
  final riskRed = (riskValue >> 16) & 0xff;
  final riskGreen = (riskValue >> 8) & 0xff;
  final riskBlue = riskValue & 0xff;
  for (var i = 0; i < bytes.lengthInBytes; i += 4) {
    final r = bytes.getUint8(i);
    final g = bytes.getUint8(i + 1);
    final b = bytes.getUint8(i + 2);
    if ((r - riskRed).abs() <= 3 &&
        (g - riskGreen).abs() <= 3 &&
        (b - riskBlue).abs() <= 3) {
      count += 1;
    }
  }
  return count;
}

Future<void> _enterKeyedText(
  WidgetTester tester,
  Key key,
  String value,
) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.enterText(finder, value);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

Future<void> _tapSaveAndLeave(WidgetTester tester) async {
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  final button = find.byKey(const Key('quick-save-leave-button'));
  expect(button, findsOneWidget);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button, warnIfMissed: false);
  await tester.pump();
}

Future<void> _rightSwipeDoesNotExposeDelete(
  WidgetTester tester,
  Key actualKey,
) async {
  final target = find.byKey(actualKey);
  expect(target, findsOneWidget);
  await tester.drag(target, const Offset(500, 0));
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsNothing);

  final endSemantics = find.descendant(
    of: target,
    matching: find.byKey(const Key('swipe-delete-end-semantics')),
  );
  expect(endSemantics, findsOneWidget);
  expect(
    tester.widget<ExcludeSemantics>(endSemantics).excluding,
    isTrue,
    reason: '右滑后右侧删除按钮仍应保持语义隐藏，表示未露出',
  );
  expect(
    find.descendant(
      of: target,
      matching: find.byKey(const Key('swipe-delete-start-action')),
    ),
    findsNothing,
    reason: '右滑方向不应存在左侧删除操作区',
  );
}

Future<void> _swipeAndConfirmDelete(
  WidgetTester tester,
  Key actualKey, {
  Offset offset = const Offset(-500, 0),
  Future<bool> Function()? until,
}) async {
  final target = find.byKey(actualKey);
  expect(target, findsOneWidget);
  // Visual hierarchy can grow, but the destructive interaction must remain
  // testable from the viewport before the left-swipe starts.
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.drag(target, offset);
  await tester.pumpAndSettle();
  expect(target, findsOneWidget);
  expect(find.byType(AlertDialog), findsNothing);

  const actionKey = Key('swipe-delete-end-action');
  final deleteAction = find.descendant(
    of: target,
    matching: find.byKey(actionKey),
  );
  expect(deleteAction, findsOneWidget);
  await tester.tap(deleteAction);
  await tester.pumpAndSettle();

  final dialogDeleteButton = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(FilledButton, '删除'),
  );
  expect(dialogDeleteButton, findsOneWidget);
  await tester.tap(dialogDeleteButton);
  await tester.pump();
  if (until != null) {
    await _pumpUntil(tester, until);
  } else {
    await tester.pumpAndSettle();
  }
}

Future<void> _pumpUntil(
  WidgetTester tester,
  Future<bool> Function() predicate, {
  int frames = 80,
}) async {
  for (var i = 0; i < frames; i += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    if (await predicate()) {
      await tester.pumpAndSettle();
      return;
    }
  }
  fail('等待异步删除完成超时');
}

Future<void> _pumpFramesUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30; i += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      await tester.pumpAndSettle();
      return;
    }
  }
}

Future<void> _unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

class _AppFixture {
  _AppFixture._({
    required this.db,
    required this.photoStore,
    required this.houses,
    required this.villages,
  });

  final AppDatabase db;
  final PhotoStore photoStore;
  final HouseRepository houses;
  final VillageRepository villages;

  static Future<_AppFixture> create() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    final photoStore = PhotoStore(baseDirOverride: Directory.systemTemp);
    return _AppFixture._(
      db: db,
      photoStore: photoStore,
      houses: HouseRepository(
        db: db,
        cipher: const NoopFieldCipher(),
        photoStore: photoStore,
      ),
      villages: VillageRepository(db: db, photoStore: photoStore),
    );
  }

  Widget wrapApp(
    Widget child, {
    HouseRepository? houseRepositoryOverride,
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        fieldCipherProvider.overrideWithValue(const NoopFieldCipher()),
        photoStoreProvider.overrideWithValue(photoStore),
        if (houseRepositoryOverride != null)
          houseRepositoryProvider.overrideWithValue(houseRepositoryOverride),
        preferenceProfileProvider.overrideWith(
          (ref) => Stream<domain.PreferenceProfile?>.value(null),
        ),
      ],
      child: child,
    );
  }

  Widget wrapPage(
    Widget child, {
    HouseRepository? houseRepositoryOverride,
  }) {
    return wrapApp(
      MaterialApp(theme: buildAppTheme(), home: child),
      houseRepositoryOverride: houseRepositoryOverride,
    );
  }

  Future<void> dispose() async {
    await db.close();
  }
}

class _ThrowingHouseRepository extends HouseRepository {
  _ThrowingHouseRepository({
    required super.db,
    required super.cipher,
    required super.photoStore,
  });

  @override
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
    throw StateError('forced create failure');
  }
}
