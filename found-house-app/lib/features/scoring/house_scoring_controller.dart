// 房源评分映射层与评分服务（W4 · 决策 UI 复用核心）。
//
// 职责边界：把领域对象 [domain.HouseRecord] + [domain.PreferenceProfile] 映射成
// 引擎输入（CostInput/FilterInput/ScoreInput），依次调用
// CostCalculator → CommuteSelector → FilterEngine → ScoreEngine，
// 产出组合结果 [HouseScoreView]，供列表页/详情页/对比页复用。
//
// 关键约束：
// - 本层不查库、不含引擎业务逻辑，只做「领域模型 → 引擎值对象」的纯映射；
//   引擎接口以磁盘为准适配，不改引擎。
// - 硬筛 rejected 的房源仍计算总分并展示（降权保留原因，不隐藏，UI §5.7）。
// - 规则版本冻结统一取 defaultScoreRule.version（F8）。
// - 敏感字段不在本层打印/外泄。

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/house_models.dart' as domain;
import '../../data/providers.dart';
import '../checklist/checklist_template.dart' as tmpl;
import 'commute_selector.dart';
import 'cost_calculator.dart';
import 'filter_engine.dart';
import 'score_engine.dart';
import 'score_rule.dart';
import 'scoring_models.dart';

/// 无预算/无通勤上限时的「不限制」哨兵值。
///
/// 偏好未设预算上限时，用一个足够大的基准，既不会误触发预算硬筛，
/// 也让 cost_score 分母足够大（成本占比趋近 0，得分趋近满分），
/// 语义上等价于「未设预算不惩罚成本」。通勤上限同理。
const int _noLimit = 1000000000;

/// 偏好硬性条件 key → (RoomInfo 布尔取值提取, 可读标签) 的映射表。
///
/// 与 preference_page._RequiredKeys 的 JSON 键对齐（private_bathroom/kitchen/
/// elevator/pet）。min_floor / max_payment_upfront 非布尔项，不参与布尔硬筛。
typedef _RoomBoolPicker = bool? Function(domain.RoomInfo? room);

const Map<String, ({_RoomBoolPicker pick, String label})> _requiredFeatureDefs =
    {
  'private_bathroom': (pick: _pickPrivateBathroom, label: '独卫'),
  'kitchen': (pick: _pickKitchen, label: '厨房'),
  'elevator': (pick: _pickElevator, label: '电梯'),
  'pet': (pick: _pickCanPet, label: '可养宠'),
};

bool? _pickPrivateBathroom(domain.RoomInfo? r) => r?.hasPrivateBathroom;
bool? _pickKitchen(domain.RoomInfo? r) => r?.hasKitchen;
bool? _pickElevator(domain.RoomInfo? r) => r?.hasElevator;
bool? _pickCanPet(domain.RoomInfo? r) => r?.canPet;

/// checklist 模板中 affects=living 的检查项 key 集合（居住维度计分来源）。
final Set<String> _livingChecklistKeys = {
  for (final m in tmpl.kChecklistTemplate)
    for (final i in m.items)
      if (i.affects == 'living') i.key,
};

/// 单套房源的组合评分结果（硬筛 + 评分 + 成本 + 通勤）。
///
/// 即使硬筛 rejected 仍持有 [score]（降权保留分数与原因，不隐藏，UI §5.7）。
class HouseScoreView {
  const HouseScoreView({
    required this.filter,
    required this.score,
    required this.cost,
    required this.commute,
  });

  /// 硬筛结果（pass/rejected + 原因）。
  final FilterResult filter;

  /// 评分结果（含 5 维分项与解释）。
  final ScoreResult score;

  /// 月总成本计算结果（含缺失补偿标记）。
  final CostResult cost;

  /// 主要通勤选择结果（无数据时 hasResult=false）。
  final CommuteSelection commute;

  /// 是否被硬筛淘汰。
  bool get rejected => !filter.passed;

  /// 是否命中 blocker 红线（淘汰原因中含 hit_blocker_risk）。
  bool get hasBlocker =>
      filter.reasons.any((r) => r.ruleId == 'hit_blocker_risk');

  /// 加权总分。
  double get total => score.total;

  /// 预估月总成本（元/月，含缺失补偿）。
  int get estimatedTotalMonthly => cost.estimatedTotalMonthly;

  /// 主要通勤时长（分钟）；无数据返回 null。
  int? get primaryCommuteMinutes => commute.hasResult ? commute.minutes : null;
}

/// 评分服务：领域对象 → 引擎输入 → 组合结果的纯映射与编排。
///
/// 无状态，可复用单实例；规则默认取 [defaultScoreRule]（可注入覆盖，F8）。
class HouseScoringService {
  HouseScoringService({ScoreRule? rule})
      : _rule = rule ?? defaultScoreRule,
        _cost = CostCalculator(rule: rule),
        _filter = FilterEngine(rule: rule),
        _score = ScoreEngine(rule: rule);

  final ScoreRule _rule;
  final CostCalculator _cost;
  final FilterEngine _filter;
  final ScoreEngine _score;
  final CommuteSelector _commuteSelector = const CommuteSelector();

  /// 冻结用规则版本（F8）。
  String get ruleVersion => _rule.version;

  /// 评估单套房源：先算成本与通勤，再硬筛，最后计算总分（rejected 也算分）。
  HouseScoreView evaluate(
    domain.HouseRecord house,
    domain.PreferenceProfile? pref,
  ) {
    final maxRentTotal = pref?.maxRentTotal ?? _noLimit;
    final maxCommute = pref?.maxCommuteMinutes ?? _noLimit;

    // 1) 月总成本（含缺失水电补偿，F2）。
    final cost = _cost.calculate(_toCostInput(house.fee));

    // 2) 主要通勤（F5：偏好首选 → transit → driving）。
    final commute = _selectCommute(
      house.mapSnapshot,
      pref?.preferredCommuteMode,
      _primaryDestinationId(pref?.destinationsJson),
    );
    final commuteMinutes = commute.hasResult ? commute.minutes : null;
    final commuteMode = commute.hasResult
        ? commute.mode
        : (pref?.preferredCommuteMode ?? 'transit');

    // 3) 风险拆分：warning 计数 → 评分扣分；全部命中 key → 硬筛（仅 blocker 生效）。
    final hitRiskKeys = house.riskFlags.map((r) => r.key).toList();
    final warningCount =
        house.riskFlags.where((r) => r.severity == 'warning').length;

    // 4) 硬性条件与房源布尔项。
    final requiredFeatures = _parseRequiredFeatures(pref?.requiredFeaturesJson);
    final houseFeatures = <String, bool?>{
      for (final f in requiredFeatures)
        f.key: _requiredFeatureDefs[f.key]?.pick(house.room),
    };

    // 5) 硬筛。
    final filter = _filter.evaluate(
      FilterInput(
        maxRentTotal: maxRentTotal,
        maxCommuteMinutes: maxCommute,
        estimatedTotalMonthly: cost.estimatedTotalMonthly,
        hasMissingFee: cost.hasMissingFee,
        hitRiskKeys: hitRiskKeys,
        primaryCommuteMinutes: commuteMinutes,
        commuteMode: commuteMode,
        requiredFeatures: requiredFeatures,
        houseFeatures: houseFeatures,
      ),
    );

    // 6) 评分（rejected 也计算，降权保留分数）。
    final nearby = _parseUserCorrection(house.mapSnapshot?.userCorrectionJson);
    final score = _score.evaluate(
      ScoreInput(
        estimatedTotalMonthly: cost.estimatedTotalMonthly,
        maxRentTotal: maxRentTotal,
        hasMissingFee: cost.hasMissingFee,
        maxCommuteMinutes: maxCommute,
        primaryCommuteMinutes: commuteMinutes,
        transferCount: commute.hasResult ? commute.transferCount : 0,
        commuteMode: commuteMode,
        walkingMeters: commute.walkingMeters,
        livingValues: _toLivingValues(house.checklistItems),
        nearbyUserCorrection: nearby?.score,
        nearbyCorrectionNote: nearby?.note,
        warningCount: warningCount,
        missingCriticalCount: _missingCriticalCount(house),
      ),
    );

    return HouseScoreView(
      filter: filter,
      score: score,
      cost: cost,
      commute: commute,
    );
  }

  // ---------------------------------------------------------------------------
  // 映射辅助（纯函数，便于单元测试）
  // ---------------------------------------------------------------------------

  /// FeeInfo → CostInput（押金为无关月成本，不计入）。
  CostInput _toCostInput(domain.FeeInfo? fee) {
    return CostInput(
      rentMonthly: fee?.rentMonthly,
      managementFee: fee?.managementFee,
      internetFee: fee?.internetFee,
      gasFee: fee?.gasFee,
      otherFee: fee?.otherFee,
      waterUnitPrice: fee?.waterUnitPrice,
      electricityUnitPrice: fee?.electricityUnitPrice,
    );
  }

  /// affects=living 的 checklist 项 → ChecklistValue 列表（not_seen 由引擎剔除分母）。
  List<ChecklistValue> _toLivingValues(List<domain.ChecklistItem> items) {
    return items
        .where((i) => _livingChecklistKeys.contains(i.key))
        .map((i) => ChecklistValue.fromRaw(i.value))
        .toList(growable: false);
  }

  /// 非费用类关键缺失计数（费用类缺失已在 cost 封顶，不重复计罚）。
  ///
  /// MVP 统计两项可现场判定的非费用缺失（对齐 missing_critical_keys 口径）：
  /// 押付方式未记录、联系人身份未核验。
  int _missingCriticalCount(domain.HouseRecord house) {
    var count = 0;
    if (house.fee?.paymentCycle == null) count++;
    if (house.contact?.identityVerified != true) count++;
    return count;
  }

  /// 解析偏好硬性条件 JSON，取值为 true 的布尔项转为 RequiredFeature。
  List<RequiredFeature> _parseRequiredFeatures(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return const [];
      final result = <RequiredFeature>[];
      _requiredFeatureDefs.forEach((key, def) {
        if (decoded[key] == true) {
          result.add(RequiredFeature(key: key, label: def.label));
        }
      });
      return result;
    } catch (_) {
      // 容错：解析失败视为无硬性条件，不阻断评分。
      return const [];
    }
  }

  /// 解析 MapSnapshot.commuteJson → CommuteOption 列表 → 主要通勤选择（F5）。
  CommuteSelection _selectCommute(
    domain.MapSnapshot? snapshot,
    String? preferredMode,
    String? primaryDestinationId,
  ) {
    final options = _parseCommuteOptions(snapshot?.commuteJson);
    if (options.isEmpty) return const CommuteSelection.empty();
    return _commuteSelector.select(
      options,
      preferredMode: preferredMode,
      primaryDestinationId: primaryDestinationId,
    );
  }

  /// 兼容解析通勤 JSON：支持 {"results":[...]} 或直接数组两种形态。
  List<CommuteOption> _parseCommuteOptions(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      final List<dynamic> list;
      if (decoded is Map && decoded['results'] is List) {
        list = decoded['results'] as List;
      } else if (decoded is List) {
        list = decoded;
      } else {
        return const [];
      }
      final options = <CommuteOption>[];
      for (final item in list) {
        if (item is! Map) continue;
        final mode = item['mode'] as String?;
        final minutes = _asInt(item['durationMinutes'] ?? item['minutes']);
        if (mode == null || mode.isEmpty || minutes == null) continue;
        options.add(
          CommuteOption(
            destinationId: _asString(item['destinationId']) ??
                _asString(item['destination_id']),
            mode: mode,
            minutes: minutes,
            transferCount: _asInt(item['transferCount']) ?? 0,
            walkingMeters: _asInt(item['walkingMeters']),
          ),
        );
      }
      return options;
    } catch (_) {
      // 容错：解析失败视为无通勤数据（primaryCommuteMinutes=null，不硬筛不阻断）。
      return const [];
    }
  }

  /// 解析偏好目的地，primary=true 优先；未标记 primary 时取第一个目的地。
  String? _primaryDestinationId(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      final List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['destinations'] is List) {
        list = decoded['destinations'] as List;
      } else {
        return null;
      }

      String? firstId;
      for (final item in list) {
        if (item is! Map) continue;
        final id = _asString(item['id']);
        if (id == null || id.isEmpty) continue;
        firstId ??= id;
        if (item['primary'] == true) return id;
      }
      return firstId;
    } catch (_) {
      return null;
    }
  }

  /// 解析用户主观修正 JSON（{"score":0-100,"note":"..."}），供 nearby 维度覆盖。
  ({double? score, String? note})? _parseUserCorrection(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return null;
      final score = _asDouble(decoded['score']);
      if (score == null) return null;
      return (score: score, note: decoded['note'] as String?);
    } catch (_) {
      return null;
    }
  }

  static int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static String? _asString(Object? v) {
    if (v is String) return v;
    return null;
  }

  static double? _asDouble(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Riverpod providers（2.x 经典 API）
// ---------------------------------------------------------------------------

/// 评分服务单例（内置默认规则）。
final houseScoringServiceProvider = Provider<HouseScoringService>((ref) {
  return HouseScoringService();
});

/// 全部房源聚合根流（按 updatedAt 降序，随库变化刷新）。
final housesStreamProvider = StreamProvider<List<domain.HouseRecord>>((ref) {
  return ref.watch(houseRepositoryProvider).watchAll();
});

/// 默认偏好档案流（用于硬筛/评分基准；可能为 null）。
final preferenceProfileProvider =
    StreamProvider<domain.PreferenceProfile?>((ref) {
  return ref.watch(preferenceRepositoryProvider).watch();
});

/// 按 houseId 计算单套房源的组合评分视图（详情页/对比页复用）。
///
/// 房源不存在返回 null；偏好缺失时用「不限制」哨兵，仍产出评分。
final houseScoreViewProvider =
    FutureProvider.family<HouseScoreView?, String>((ref, houseId) async {
  final repo = ref.watch(houseRepositoryProvider);
  final house = await repo.getById(houseId);
  if (house == null) return null;
  final pref = await ref.watch(preferenceProfileProvider.future);
  final service = ref.watch(houseScoringServiceProvider);
  return service.evaluate(house, pref);
});
