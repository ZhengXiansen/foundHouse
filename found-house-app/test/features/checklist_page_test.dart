// Checklist 页 widget 测试（W1-2 · D5）。
//
// 覆盖：模板五模块渲染、点选四态写库、risk 命中联动 RiskFlag、
// 再次点击取消作答删除该项。用内存库 + provider override 注入真实仓库。

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/crypto/field_cipher.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/local_files/photo_store.dart';
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/house_repository.dart';
import 'package:found_house_app/features/checklist/checklist_page.dart';
import 'package:found_house_app/features/checklist/checklist_template.dart';

void main() {
  late AppDatabase db;
  late HouseRepository repo;
  late String houseId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    repo = HouseRepository(
      db: db,
      cipher: const NoopFieldCipher(),
      photoStore: PhotoStore(baseDirOverride: Directory.systemTemp),
    );
    houseId = await repo.create(title: '测试房源');
  });

  tearDown(() async {
    await db.close();
  });

  /// 用注入了内存库仓库的 ProviderScope 包裹被测页面。
  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [houseRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: child),
    );
  }

  /// 放大测试视口，让 ListView 一次性构建全部模块（默认 800x600 会裁掉下方模块）。
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('渲染模板全部五模块标题', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(wrap(ChecklistPage(houseId: houseId)));
    await tester.pumpAndSettle();

    for (final module in kChecklistTemplate) {
      expect(find.text(module.label), findsWidgets);
    }
  });

  testWidgets('点选检查项写入 ChecklistItem，再次点击取消删除', (tester) async {
    await tester.pumpWidget(wrap(ChecklistPage(houseId: houseId)));
    await tester.pumpAndSettle();

    // 点第一个「好」按钮（room 模块首项 采光）。
    await tester.tap(find.text('好').first);
    await tester.pumpAndSettle();

    var items = await repo.getChecklistItems(houseId);
    expect(items.length, 1);
    expect(items.first.value, ChecklistValue.good);

    // 再次点同一按钮 → 取消作答，删除该项。
    await tester.tap(find.text('好').first);
    await tester.pumpAndSettle();

    items = await repo.getChecklistItems(houseId);
    expect(items, isEmpty);
  });

  testWidgets('risk 模块选「命中」联动写入 RiskFlag，取消命中删除', (tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(wrap(ChecklistPage(houseId: houseId)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('命中').first);
    await tester.pumpAndSettle();

    var risks = await repo.getRiskFlags(houseId);
    expect(risks.length, 1);

    // 取消命中（再次点击）→ 删除 RiskFlag。
    await tester.tap(find.text('命中').first);
    await tester.pumpAndSettle();

    risks = await repo.getRiskFlags(houseId);
    expect(risks, isEmpty);
  });
}
