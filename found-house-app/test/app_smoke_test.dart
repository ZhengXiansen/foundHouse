import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/app/app.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/features/scoring/house_scoring_controller.dart';

Future<void> _pumpTestApp(WidgetTester tester) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        housesStreamProvider.overrideWith(
          (ref) => Stream.value(const <domain.HouseRecord>[]),
        ),
        villagesWithStatsProvider.overrideWith(
          (ref) => Stream.value(const <domain.VillageWithStats>[]),
        ),
        preferenceProfileProvider.overrideWith(
          (ref) => Stream<domain.PreferenceProfile?>.value(null),
        ),
      ],
      child: const FoundHouseApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('应用启动后默认进入「首页」Tab 且底部导航含 4 个一级入口', (tester) async {
    await _pumpTestApp(tester);

    // 底部导航 4 个一级入口（新版信息架构）。
    expect(find.text('首页'), findsWidgets);
    expect(find.text('房源'), findsOneWidget);
    expect(find.text('对比'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // 启动默认落在村列表首页，不再展示地图/定位工作台。
    // 启动默认落在村列表首页；无村时为空态（不展示页头 heading）。
    expect(find.text('还没有村'), findsOneWidget);
    expect(find.textContaining('离线也能记'), findsOneWidget);
    expect(find.text('新增村'), findsWidgets);
    expect(find.text('扫楼地图'), findsNothing);
    expect(find.textContaining('定位'), findsNothing);
  });

  testWidgets('切换到「房源」Tab 展示房源列表占位', (tester) async {
    await _pumpTestApp(tester);

    await tester.tap(find.text('房源'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('还没有房源记录'), findsOneWidget);
    expect(
      find.textContaining('先在首页新增一个村，再记录你现场看到的候选房'),
      findsOneWidget,
    );
    expect(find.text('开始扫楼'), findsOneWidget);
  });

  testWidgets('切换到「我的」Tab 不展示地图或定位服务入口', (tester) async {
    await _pumpTestApp(tester);

    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('我的'), findsWidgets);
    expect(find.textContaining('地图'), findsNothing);
    expect(find.textContaining('定位'), findsNothing);
    expect(find.textContaining('经纬度'), findsNothing);
    expect(find.textContaining('高德'), findsNothing);
  });

  testWidgets('隐私设置不展示定位或经纬度文案', (tester) async {
    await _pumpTestApp(tester);

    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final privacySettings = find.text('隐私设置');
    await tester.ensureVisible(privacySettings);
    await tester.pumpAndSettle();
    await tester.tap(privacySettings);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('隐私设置'), findsWidgets);
    expect(find.textContaining('定位'), findsNothing);
    expect(find.textContaining('经纬度'), findsNothing);
    expect(find.textContaining('地图'), findsNothing);
  });
}
