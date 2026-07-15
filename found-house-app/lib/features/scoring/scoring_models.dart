// 评分与硬筛引擎的纯数据值对象（W4 · G1/G2/G3）。
//
// 关键约束：仅依赖 dart:core，不引入 Flutter/drift/UI。
// 所有对象为不可变值对象，便于单元测试与快照冻结（F8）。

/// checklist 单项取值（对应 checklist-template.json 的 value_options.default）。
/// risk 模块的 hit/not_hit 不走 living 计分，不在此枚举内。
enum ChecklistValue {
  good,
  ok,
  bad,
  notSeen;

  /// 从存储层字符串解析（good/ok/bad/not_seen）。未知值按 not_seen 处理，避免抛出。
  static ChecklistValue fromRaw(String? raw) {
    switch (raw) {
      case 'good':
        return ChecklistValue.good;
      case 'ok':
        return ChecklistValue.ok;
      case 'bad':
        return ChecklistValue.bad;
      default:
        return ChecklistValue.notSeen;
    }
  }
}

/// 硬筛总体结论。
enum HardFilterOutcome { pass, rejected }

// ---------------------------------------------------------------------------
// G1 月总成本
// ---------------------------------------------------------------------------

/// 月总成本计算输入（费用字段，均可空）。押金为无关月成本，不计入。
class CostInput {
  const CostInput({
    this.rentMonthly,
    this.managementFee,
    this.internetFee,
    this.gasFee,
    this.otherFee,
    this.waterUnitPrice,
    this.electricityUnitPrice,
  });

  /// 月租（元/月），计入月总成本。
  final int? rentMonthly;

  /// 管理费（元/月）。
  final int? managementFee;

  /// 网费（元/月）。
  final int? internetFee;

  /// 燃气费（元/月）。
  final int? gasFee;

  /// 其他固定费用（元/月）。
  final int? otherFee;

  /// 水费单价（元/吨）。缺失触发保守月估值补偿（F2）。
  final double? waterUnitPrice;

  /// 电费单价（元/度）。缺失触发保守月估值补偿（F2）。
  final double? electricityUnitPrice;
}

/// 月总成本计算结果。
class CostResult {
  const CostResult({
    required this.estimatedTotalMonthly,
    required this.hasMissingFee,
    required this.waterMissing,
    required this.electricityMissing,
  });

  /// 预估月总成本（元/月），含缺失水电的保守补偿（F2）。
  final int estimatedTotalMonthly;

  /// 是否存在缺失水电单价（任一缺失即 true），用于 cost_score 封顶（F2）。
  final bool hasMissingFee;

  /// 水费单价是否缺失。
  final bool waterMissing;

  /// 电费单价是否缺失。
  final bool electricityMissing;
}

// ---------------------------------------------------------------------------
// 通勤主口径选择（F5）
// ---------------------------------------------------------------------------

/// 单一出行方式的通勤结果。
class CommuteOption {
  const CommuteOption({
    required this.mode,
    required this.minutes,
    this.destinationId,
    this.transferCount = 0,
    this.walkingMeters,
  });

  /// 目的地 id。多目的地通勤时用于先按 primary destination 过滤（F5）。
  final String? destinationId;

  /// 出行方式：walking/bicycling/transit/driving。
  final String mode;

  /// 通勤时长（分钟）。
  final int minutes;

  /// 换乘次数（仅 transit 有意义，其他方式为 0）。
  final int transferCount;

  /// 步行距离（米），用于解释文案（可空）。
  final int? walkingMeters;
}

/// 主要通勤选择结果（F5）。
class CommuteSelection {
  const CommuteSelection({
    required this.hasResult,
    this.destinationId,
    this.mode = '',
    this.minutes = 0,
    this.transferCount = 0,
    this.walkingMeters,
  });

  /// 无任何可用路线时的空结果。
  const CommuteSelection.empty() : this(hasResult: false);

  /// 是否存在可用通勤结果。false 表示地图无数据，不参与硬筛通勤淘汰。
  final bool hasResult;

  /// 采用的目的地 id；旧快照无 destinationId 时为空。
  final String? destinationId;

  /// 最终采用的出行方式。
  final String mode;

  /// 通勤时长（分钟）。
  final int minutes;

  /// 换乘次数。
  final int transferCount;

  /// 步行距离（米）。
  final int? walkingMeters;
}

// ---------------------------------------------------------------------------
// G2 硬筛
// ---------------------------------------------------------------------------

/// 必选硬性条件（如「必须独卫」）。key 与字段字典 RoomInfo 布尔项对齐。
class RequiredFeature {
  const RequiredFeature({required this.key, required this.label});

  /// 特征 key，如 has_private_bathroom/has_kitchen/has_elevator/can_cook/can_pet。
  final String key;

  /// 可读标签，用于淘汰原因文案，如「独卫」。
  final String label;
}

/// 硬筛输入。偏好 + 房源派生数据（月总成本、主要通勤、房型布尔项、命中风险 key）。
class FilterInput {
  const FilterInput({
    required this.maxRentTotal,
    required this.maxCommuteMinutes,
    required this.estimatedTotalMonthly,
    required this.hasMissingFee,
    required this.hitRiskKeys,
    this.primaryCommuteMinutes,
    this.commuteMode = 'transit',
    this.requiredFeatures = const [],
    this.houseFeatures = const {},
  });

  /// 月总成本上限（预算硬筛唯一基准，F1）。
  final int maxRentTotal;

  /// 最大通勤时间（分钟）。
  final int maxCommuteMinutes;

  /// 预估月总成本（含缺失补偿，F1/F2）。
  final int estimatedTotalMonthly;

  /// 是否含缺失费用估算（决定淘汰原因是否附「保守估算」说明）。
  final bool hasMissingFee;

  /// 主要通勤时间（分钟）。null 表示无地图数据，不做通勤硬筛（地图失败不阻断）。
  final int? primaryCommuteMinutes;

  /// 主要通勤出行方式，仅用于文案（F5）。
  final String commuteMode;

  /// 必选硬性条件清单。
  final List<RequiredFeature> requiredFeatures;

  /// 房源房型布尔项。true 满足；false/null（未记录）视为不满足。
  final Map<String, bool?> houseFeatures;

  /// 命中的风险 key 列表（用户或系统标记）。
  final List<String> hitRiskKeys;
}

/// 单条淘汰原因。
class FilterReason {
  const FilterReason({required this.ruleId, required this.message});

  /// 规则 id：over_budget/over_commute/missing_required_feature/hit_blocker_risk。
  final String ruleId;

  /// 可读原因文案（来自 explanation_templates）。
  final String message;
}

/// 硬筛结果。
class FilterResult {
  const FilterResult({required this.outcome, required this.reasons});

  /// 总体结论 pass/rejected。
  final HardFilterOutcome outcome;

  /// 淘汰原因清单（pass 时为空）。
  final List<FilterReason> reasons;

  /// 是否通过硬筛。
  bool get passed => outcome == HardFilterOutcome.pass;
}

// ---------------------------------------------------------------------------
// G3 评分
// ---------------------------------------------------------------------------

/// 评分输入。所有数据由仓库/地图快照/checklist 派生后传入，引擎不查库、不依赖 UI。
class ScoreInput {
  const ScoreInput({
    required this.estimatedTotalMonthly,
    required this.maxRentTotal,
    required this.hasMissingFee,
    required this.maxCommuteMinutes,
    this.primaryCommuteMinutes,
    this.transferCount = 0,
    this.commuteMode = 'transit',
    this.walkingMeters,
    this.livingValues = const [],
    this.nearbyBaseScore,
    this.nearbyUserCorrection,
    this.nearbyCorrectionNote,
    this.warningCount = 0,
    this.missingCriticalCount = 0,
  });

  /// 月总成本（含缺失补偿）。
  final int estimatedTotalMonthly;

  /// 月总成本上限（cost_score 基准）。
  final int maxRentTotal;

  /// 是否缺失水电单价（触发 cost_score 封顶 70，F2）。
  final bool hasMissingFee;

  /// 最大通勤时间（分钟）。
  final int maxCommuteMinutes;

  /// 主要通勤时间（分钟）。null 表示无数据，给中性默认并标记缺失。
  final int? primaryCommuteMinutes;

  /// 换乘次数（commute_score 每次扣 5 分）。
  final int transferCount;

  /// 主要通勤出行方式，用于解释文案。
  final String commuteMode;

  /// 步行距离（米），用于解释文案（可空）。
  final int? walkingMeters;

  /// affects=living 的 checklist 取值列表。not_seen 不计入分母。
  final List<ChecklistValue> livingValues;

  /// 系统周边计分（0-100），可空。
  final double? nearbyBaseScore;

  /// 用户主观修正分（0-100），优先于系统周边计分（user_correction 优先）。
  final double? nearbyUserCorrection;

  /// 用户修正说明，用于解释文案。
  final String? nearbyCorrectionNote;

  /// 命中的 warning 级风险数量（每个扣 12 分）。
  final int warningCount;

  /// 非费用类关键缺失数量（每个扣 8 分；费用类缺失已在 cost 封顶，不重复计罚）。
  final int missingCriticalCount;
}

/// 5 维分项与缺失标记。
class ScoreBreakdown {
  const ScoreBreakdown({
    required this.cost,
    required this.commute,
    required this.living,
    required this.nearby,
    required this.risk,
    this.costCapped = false,
    this.commuteMissing = false,
    this.livingMissing = false,
    this.nearbyMissing = false,
  });

  /// 总成本维度分（0-100）。
  final double cost;

  /// 通勤维度分（0-100）。
  final double commute;

  /// 居住维度分（0-100）。
  final double living;

  /// 周边便利维度分（0-100）。
  final double nearby;

  /// 安全/交易风险维度分（0-100，不为负，F3）。
  final double risk;

  /// cost 是否因缺失费用被封顶到 70（F2）。
  final bool costCapped;

  /// 通勤是否因无数据取中性默认。
  final bool commuteMissing;

  /// 居住是否因无有效 checklist 项取中性默认。
  final bool livingMissing;

  /// 周边是否因无系统/修正计分取中性默认。
  final bool nearbyMissing;
}

/// 可解释文案条目。
class ScoreExplanation {
  const ScoreExplanation({required this.code, required this.message});

  /// 文案编码，如 cost_capped/commute_source/user_correction/*_missing。
  final String code;

  /// 可读文案。
  final String message;
}

/// 评分结果。冻结时连同 ruleVersion 一起写入 ScoreSnapshot（F8）。
class ScoreResult {
  const ScoreResult({
    required this.total,
    required this.breakdown,
    required this.explanations,
    required this.ruleVersion,
  });

  /// 加权总分（0-100）。
  final double total;

  /// 5 维分项。
  final ScoreBreakdown breakdown;

  /// 解释文案清单。
  final List<ScoreExplanation> explanations;

  /// 计算所用规则版本（F8）。
  final String ruleVersion;
}
