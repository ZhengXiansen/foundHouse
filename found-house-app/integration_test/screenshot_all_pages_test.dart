// 全页面截图（真机）：预置数据后逐页导航，每页 takeScreenshot 落盘到 img/。
//
// 配套 test_driver/screenshot_driver.dart 的 onScreenshot 回调写 PNG。
// 运行：flutter drive --driver test_driver/screenshot_driver.dart \
//   --target integration_test/screenshot_all_pages_test.dart -d <deviceId>
//
// 覆盖页面：首页村列表 / 村详情 / 快速记录 / 楼栋房源列表 / 房源列表 /
// 房源详情 / 看房清单 / 评分详情 / 对比 / 我的 / 偏好 / 隐私 / OSS 云存储。
// scan_map_page 是已下线地图版首页（继承 VillageHomePage），不重复截图。

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/app/app.dart';
import 'package:found_house_app/app/router.dart';
import 'package:found_house_app/app/theme.dart';
import 'package:found_house_app/app/theme_preferences.dart';
import 'package:found_house_app/data/crypto/crypto_service.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/village_repository.dart';
import 'package:found_house_app/integrations/oss/oss_config.dart';
import 'package:integration_test/integration_test.dart';

/// 内存 KeyStore：OSS 配置注入，不触碰真机安全存储通道。
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
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('截取 app 内所有页面', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    final keyStore = _InMemoryKeyStore();
    final ossStore = OssConfigStore(keyStore);
    final themeStore = ThemePreferenceStore(keyStore);
    // 预置一份完整 OSS 配置，让 OSS 页截图有内容（enabled 但用测试值）。
    await ossStore.save(
      const OssConfig(
        enabled: true,
        endpoint: 'oss-cn-shenzhen.aliyuncs.com',
        bucket: 'my-found-house',
        accessKeyId: 'LTAI-demo-id',
        accessKeySecret: 'demo-secret',
        pathPrefix: 'photos/',
      ),
    );

    // Android 真机需先把 Flutter surface 转为可截图的 image（iOS 无需）。
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }

    var shotIndex = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      shotIndex++;
      final label = '${shotIndex.toString().padLeft(2, '0')}-$name';
      await binding.takeScreenshot(label);
    }

    Future<void> pumpFrames([int count = 10]) async {
      for (var i = 0; i < count; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> pumpUntilFound(Finder finder, {int maxFrames = 60}) async {
      for (var i = 0; i < maxFrames; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (finder.evaluate().isNotEmpty) return;
      }
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
          ossConfigStoreProvider.overrideWithValue(ossStore),
          themePreferenceStoreProvider.overrideWithValue(themeStore),
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
    final prefs = container.read(preferenceRepositoryProvider);
    await prefs.ensureDefault();

    // ---- 预置数据：一个村 + 楼栋 + 两套房源（含费用/房屋信息）。----
    final villageId = await villages.createVillage(
      name: '上沙村',
      status: VillageStatus.scouting,
    );
    final buildingId = await villages.createBuilding(
      villageId: villageId,
      name: '1号楼',
      status: BuildingStatus.hasVacancy,
    );
    await villages.createBuilding(
      villageId: villageId,
      name: '2号楼',
      status: BuildingStatus.contacting,
    );
    final houseId = await houses.create(
      title: '上沙村1号楼 301',
      villageId: villageId,
      buildingId: buildingId,
      status: 'active',
      roomNo: '301',
      fee: const domain.FeeInfo(
        rentMonthly: 1800,
        deposit: 1800,
        waterUnitPrice: 5,
        electricityUnitPrice: 1.2,
      ),
      room: const domain.RoomInfo(
        layout: '一房一厅',
        area: 32,
        floor: 3,
        totalFloor: 7,
        hasPrivateBathroom: true,
        hasKitchen: true,
      ),
      contact: const domain.ContactInfo(name: '张房东', role: '房东'),
    );
    await houses.addChecklistItem(
      houseId,
      module: 'room',
      key: 'water_pressure',
      value: 'good',
    );
    await houses.create(
      title: '上沙村2号楼 502',
      villageId: villageId,
      status: 'active',
      roomNo: '502',
      fee: const domain.FeeInfo(rentMonthly: 2300, deposit: 2300),
      room: const domain.RoomInfo(layout: '单间', area: 20),
    );
    await pumpFrames(10);

    // ---- 1. 首页村列表 ----
    router.go(AppRoutes.scan);
    await pumpUntilFound(find.text('上沙村'));
    await shot('home-village-list');

    // ---- 2. 村详情 ----
    router.go('/scan/villages/$villageId');
    await pumpUntilFound(find.text('楼栋'));
    await shot('village-detail');

    // ---- 3. 楼栋房源列表 ----
    router.goNamed(
      AppRoutes.buildingHouseListName,
      pathParameters: {'villageId': villageId, 'buildingId': buildingId},
      queryParameters: {'buildingName': '1号楼'},
    );
    await pumpFrames(12);
    await shot('building-house-list');

    // ---- 4. 快速记录 ----
    router.go('/scan/quick-record?villageId=$villageId');
    await pumpUntilFound(find.text('快速记录'));
    await shot('quick-record');

    // ---- 5. 房源列表 ----
    router.go(AppRoutes.houses);
    await pumpUntilFound(find.text('上沙村1号楼 301'));
    await shot('house-list');

    // ---- 6. 房源详情 ----
    router.go('/houses/$houseId');
    await pumpFrames(14);
    await shot('house-detail');

    // ---- 7. 看房清单（房源详情内 push，无独立路由）----
    final checklistEntry = find.text('看房清单');
    if (checklistEntry.evaluate().isNotEmpty) {
      await tester.ensureVisible(checklistEntry.first);
      await pumpFrames(2);
      await tester.tap(checklistEntry.first);
      await pumpUntilFound(find.text('看房清单'));
      await shot('checklist');
      // 返回房源详情。
      await tester.pageBack();
      await pumpFrames(8);
    }

    // ---- 8. 评分详情 ----
    router.go('/houses/$houseId/score');
    await pumpFrames(14);
    await shot('score-detail');

    // ---- 9. 对比 ----
    router.go(AppRoutes.compare);
    await pumpUntilFound(find.textContaining('对比'));
    await pumpFrames(4);
    // 选够两套，展示对比表。
    final h1 = find.text('上沙村1号楼 301');
    final h2 = find.text('上沙村2号楼 502');
    if (h1.evaluate().isNotEmpty) {
      await tester.tap(h1.first);
      await pumpFrames(4);
    }
    if (h2.evaluate().isNotEmpty) {
      await tester.tap(h2.first);
      await pumpFrames(6);
    }
    await shot('compare');

    // ---- 10. 我的（设置首页）----
    router.go(AppRoutes.settings);
    await pumpUntilFound(find.text('OSS 云存储'));
    await shot('settings');
    await tester.tap(find.text('薄荷云朵'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('界面主题'))).colorScheme.primary,
      AppThemePreset.mintCloud.primary,
    );
    await shot('settings-mint-theme');

    // ---- 11. 偏好设置 ----
    router.goNamed(AppRoutes.preferenceName);
    await pumpFrames(14);
    await shot('preference');

    // ---- 12. 隐私设置 ----
    router.go(AppRoutes.settings);
    await pumpFrames(6);
    router.goNamed(AppRoutes.privacyName);
    await pumpFrames(12);
    await shot('privacy');

    // ---- 13. OSS 云存储 ----
    router.go(AppRoutes.settings);
    await pumpFrames(6);
    router.goNamed(AppRoutes.ossSettingsName);
    await pumpUntilFound(find.text('启用 OSS 上传'));
    await shot('oss-settings');
  });
}
