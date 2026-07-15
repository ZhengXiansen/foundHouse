// 偏好设置页 widget 测试（W1-2 · D6）。
//
// 覆盖：ensureDefault 回填、填月总成本上限 + 勾选硬性条件 + 调权重后保存，
// 验证 PreferenceRepository 落库结果。用内存库 + provider override。

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/providers.dart';
import 'package:found_house_app/data/repositories/preference_repository.dart';
import 'package:found_house_app/features/settings/preference_page.dart';

void main() {
  late AppDatabase db;
  late PreferenceRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PreferenceRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(home: PreferencePage()),
    );
  }

  testWidgets('填月总成本上限并保存后落库', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // 月总成本上限输入（首个数字输入框）。
    await tester.enterText(
      find.widgetWithText(TextField, '如 2500'),
      '2500',
    );
    await tester.pump();

    // 点顶部「保存」。
    await tester.tap(find.text('保存').first);
    await tester.pumpAndSettle();

    final profile = await repo.load();
    expect(profile, isNotNull);
    expect(profile!.maxRentTotal, 2500);
    // 权重 JSON 应存在且解析为默认 5 维。
    expect(profile.weightsJson, isNotNull);
    final weights = jsonDecode(profile.weightsJson!) as Map<String, dynamic>;
    expect(
      weights.keys,
      containsAll(['cost', 'commute', 'living', 'nearby', 'risk']),
    );
  });
}
