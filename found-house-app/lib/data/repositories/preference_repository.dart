// 偏好仓库（W1-2 · D2，技术方案 §5.1）。
//
// 读写单条默认 PreferenceProfile——月总成本上限（maxRentTotal，F1 唯一预算基准）、
// 最大通勤时间、目的地 JSON、硬性条件 JSON、评分权重 JSON（默认 30/20/25/15/10）、
// 首选通勤方式（空=transit，F5）。首启无偏好时创建默认 profile。
//
// 关键约束：只读写、不含硬筛/评分逻辑；权重变更由上层触发重算并保留旧快照（F8）。

import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/house_models.dart' as domain;
import '../models/mappers.dart' as m;

/// 偏好读写仓库。单条默认 profile，主键固定为 [defaultProfileId]。
class PreferenceRepository {
  PreferenceRepository({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  /// 默认 profile 固定主键（单条约束：始终读写这一条）。
  static const String defaultProfileId = 'default';

  /// 默认权重（F4，与 docs/rules/score-rule-v0.json 一致，整数百分比）。
  static const Map<String, int> defaultWeights = {
    'cost': 30,
    'commute': 20,
    'living': 25,
    'nearby': 15,
    'risk': 10,
  };

  /// 默认权重 JSON 字符串。
  static String get defaultWeightsJson => jsonEncode(defaultWeights);

  /// 确保默认 profile 存在：无则以默认权重创建，返回当前（或新建的）profile。
  ///
  /// 默认 preferredCommuteMode 留空（读取时按 transit 处理，F5）。
  Future<domain.PreferenceProfile> ensureDefault() async {
    final existing = await load();
    if (existing != null) return existing;

    await _db.into(_db.preferenceProfiles).insert(
          PreferenceProfilesCompanion.insert(
            id: defaultProfileId,
            weightsJson: Value(defaultWeightsJson),
          ),
        );
    final created = await load();
    // load 紧接 insert，理论上非空；防御性兜底返回内存态默认对象。
    return created ??
        domain.PreferenceProfile(
          id: defaultProfileId,
          weightsJson: defaultWeightsJson,
        );
  }

  /// 读取默认 profile；不存在返回 null。
  Future<domain.PreferenceProfile?> load() async {
    final row = await (_db.select(_db.preferenceProfiles)
          ..where((t) => t.id.equals(defaultProfileId)))
        .getSingleOrNull();
    if (row == null) return null;
    return m.preferenceProfileFromRow(row);
  }

  /// watch 默认 profile；不存在发 null。
  Stream<domain.PreferenceProfile?> watch() {
    final query = _db.select(_db.preferenceProfiles)
      ..where((t) => t.id.equals(defaultProfileId));
    return query.watchSingleOrNull().map(
          (row) => row == null ? null : m.preferenceProfileFromRow(row),
        );
  }

  /// 保存偏好（upsert）。强制主键为 [defaultProfileId]，保证单条约束。
  Future<void> save(domain.PreferenceProfile profile) async {
    final normalized = profile.id == defaultProfileId
        ? profile
        : domain.PreferenceProfile(
            id: defaultProfileId,
            maxRentTotal: profile.maxRentTotal,
            maxCommuteMinutes: profile.maxCommuteMinutes,
            destinationsJson: profile.destinationsJson,
            requiredFeaturesJson: profile.requiredFeaturesJson,
            weightsJson: profile.weightsJson,
            preferredCommuteMode: profile.preferredCommuteMode,
          );
    await _db
        .into(_db.preferenceProfiles)
        .insertOnConflictUpdate(m.preferenceProfileToCompanion(normalized));
  }
}
