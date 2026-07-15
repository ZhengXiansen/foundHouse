// PreferenceRepository 单测（W1-2）。
//
// 覆盖：首启 ensureDefault 建默认 profile（权重 30/20/25/15/10、通勤方式留空）、
// 幂等（重复调用不新建）、save/load 往返、save 强制单条主键。

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/db/app_database.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/data/repositories/preference_repository.dart';

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

  test('首启 load 为 null', () async {
    expect(await repo.load(), isNull);
  });

  test('ensureDefault 建默认 profile：权重 30/20/25/15/10，通勤方式留空', () async {
    final profile = await repo.ensureDefault();
    expect(profile.id, PreferenceRepository.defaultProfileId);
    expect(profile.preferredCommuteMode, isNull);

    final weights = jsonDecode(profile.weightsJson!) as Map<String, dynamic>;
    expect(weights['cost'], 30);
    expect(weights['commute'], 20);
    expect(weights['living'], 25);
    expect(weights['nearby'], 15);
    expect(weights['risk'], 10);
  });

  test('ensureDefault 幂等：重复调用不新建第二条', () async {
    await repo.ensureDefault();
    await repo.ensureDefault();
    final rows = await db.select(db.preferenceProfiles).get();
    expect(rows.length, 1);
  });

  test('save/load 往返一致', () async {
    await repo.ensureDefault();
    await repo.save(
      const domain.PreferenceProfile(
        id: PreferenceRepository.defaultProfileId,
        maxRentTotal: 2500,
        maxCommuteMinutes: 45,
        preferredCommuteMode: 'driving',
        weightsJson:
            '{"cost":40,"commute":20,"living":20,"nearby":10,"risk":10}',
      ),
    );

    final loaded = await repo.load();
    expect(loaded!.maxRentTotal, 2500);
    expect(loaded.maxCommuteMinutes, 45);
    expect(loaded.preferredCommuteMode, 'driving');
  });

  test('save 强制单条主键：非默认 id 也归一化为 default', () async {
    await repo.save(
      const domain.PreferenceProfile(id: 'other', maxRentTotal: 3000),
    );
    final rows = await db.select(db.preferenceProfiles).get();
    expect(rows.length, 1);
    expect(rows.first.id, PreferenceRepository.defaultProfileId);
    expect(rows.first.maxRentTotal, 3000);
  });

  test('watch 推送最新偏好', () async {
    await repo.ensureDefault();
    final future = repo.watch().firstWhere((p) => p?.maxRentTotal == 2800);
    await repo.save(
      const domain.PreferenceProfile(
        id: PreferenceRepository.defaultProfileId,
        maxRentTotal: 2800,
      ),
    );
    final profile = await future;
    expect(profile?.maxRentTotal, 2800);
  });
}
