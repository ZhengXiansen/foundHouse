// 评分规则对象（W4 · G3，F4/F8）。
//
// 单一事实源：docs/rules/score-rule-v0.json。引擎不硬编码权重/阈值，
// 一律从 ScoreRule 读取。内置一份 defaultRule 常量（与 JSON 同步），
// 便于离线与单元测试；BFF 可下发 JSON Map 覆盖（F8）。
//
// 关键约束：仅依赖 dart:core。

/// 风险项定义（key + label + 严重度）。
class RiskFlagDef {
  const RiskFlagDef({required this.key, required this.label});

  final String key;
  final String label;
}

/// 缺失费用兜底估值配置（F2）。
class MissingFeeConfig {
  const MissingFeeConfig({
    required this.defaultWaterMonthly,
    required this.defaultElectricityMonthly,
    required this.costScoreCapWhenMissing,
  });

  /// 缺水费单价时按此月估值补偿（元/月）。
  final int defaultWaterMonthly;

  /// 缺电费单价时按此月估值补偿（元/月）。
  final int defaultElectricityMonthly;

  /// 缺失费用时 cost_score 封顶值。
  final int costScoreCapWhenMissing;

  factory MissingFeeConfig.fromJson(Map<String, dynamic> json) {
    return MissingFeeConfig(
      defaultWaterMonthly: (json['default_water_monthly'] as num).toInt(),
      defaultElectricityMonthly:
          (json['default_electricity_monthly'] as num).toInt(),
      costScoreCapWhenMissing:
          (json['cost_score_cap_when_missing'] as num).toInt(),
    );
  }
}

/// 5 维权重（F4，和为 1.0）。
class ScoreWeights {
  const ScoreWeights({
    required this.cost,
    required this.commute,
    required this.living,
    required this.nearby,
    required this.risk,
  });

  final double cost;
  final double commute;
  final double living;
  final double nearby;
  final double risk;

  /// 权重之和（正常规则应为 1.0）。
  double get sum => cost + commute + living + nearby + risk;

  factory ScoreWeights.fromJson(Map<String, dynamic> json) {
    return ScoreWeights(
      cost: (json['cost'] as num).toDouble(),
      commute: (json['commute'] as num).toDouble(),
      living: (json['living'] as num).toDouble(),
      nearby: (json['nearby'] as num).toDouble(),
      risk: (json['risk'] as num).toDouble(),
    );
  }
}

/// 完整评分规则对象。
class ScoreRule {
  const ScoreRule({
    required this.version,
    required this.weights,
    required this.missingFee,
    required this.blockerRisks,
    required this.warningRisks,
    required this.explanationTemplates,
    this.costRentFactor = 40,
    this.commuteTimeFactor = 50,
    this.commuteTransferPenalty = 5,
    this.riskWarningPenalty = 12,
    this.riskMissingCriticalPenalty = 8,
    this.neutralDefault = 60,
  });

  /// 规则版本（F8），如 mvp-2026-07-02。
  final String version;

  /// 5 维权重（F4）。
  final ScoreWeights weights;

  /// 缺失费用兜底配置（F2）。
  final MissingFeeConfig missingFee;

  /// blocker 风险清单（命中即硬筛淘汰）。
  final List<RiskFlagDef> blockerRisks;

  /// warning 风险清单（命中扣分）。
  final List<RiskFlagDef> warningRisks;

  /// 解释文案模板（explanation_templates）。
  final Map<String, String> explanationTemplates;

  /// cost_score 公式中月总成本占比系数（默认 40）。
  final int costRentFactor;

  /// commute_score 公式中通勤时间占比系数（默认 50）。
  final int commuteTimeFactor;

  /// commute_score 每次换乘扣分（默认 5）。
  final int commuteTransferPenalty;

  /// risk_score 每个 warning 扣分（默认 12）。
  final int riskWarningPenalty;

  /// risk_score 每个非费用关键缺失扣分（默认 8）。
  final int riskMissingCriticalPenalty;

  /// 无有效数据时的中性默认分（living/nearby 兜底，默认 60）。
  final int neutralDefault;

  /// blocker 风险 key 集合，便于硬筛快速判定。
  Set<String> get blockerRiskKeys => blockerRisks.map((r) => r.key).toSet();

  /// warning 风险 key 集合。
  Set<String> get warningRiskKeys => warningRisks.map((r) => r.key).toSet();

  /// 按 key 查 blocker 标签，未知返回 key 本身。
  String blockerLabel(String key) {
    for (final r in blockerRisks) {
      if (r.key == key) return r.label;
    }
    return key;
  }

  /// 从 JSON Map 构造（BFF 下发或读取内置 JSON）。
  factory ScoreRule.fromJson(Map<String, dynamic> json) {
    final weights =
        ScoreWeights.fromJson(json['weights'] as Map<String, dynamic>);
    final missingFee =
        MissingFeeConfig.fromJson(json['missing_fee'] as Map<String, dynamic>);

    final riskFlags = json['risk_flags'] as Map<String, dynamic>? ?? const {};
    final blocker = _parseRiskList(riskFlags['blocker']);
    final warning = _parseRiskList(riskFlags['warning']);

    final templatesRaw =
        json['explanation_templates'] as Map<String, dynamic>? ?? const {};
    final templates = <String, String>{
      for (final e in templatesRaw.entries) e.key: e.value as String,
    };

    // 公式系数从 JSON 的字符串公式解析成本较高且脆弱，改为固定默认，
    // 与 JSON 描述保持一致（40/50/5/12/8）；如需覆盖可扩展 JSON 结构。
    return ScoreRule(
      version: json['score_rule_version'] as String,
      weights: weights,
      missingFee: missingFee,
      blockerRisks: blocker,
      warningRisks: warning,
      explanationTemplates: templates,
    );
  }

  static List<RiskFlagDef> _parseRiskList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => RiskFlagDef(
            key: m['key'] as String,
            label: m['label'] as String,
          ),
        )
        .toList(growable: false);
  }
}

/// 内置默认规则常量（与 docs/rules/score-rule-v0.json 同步，F8 离线兜底）。
const ScoreRule defaultScoreRule = ScoreRule(
  version: 'mvp-2026-07-02',
  weights: ScoreWeights(
    cost: 0.30,
    commute: 0.20,
    living: 0.25,
    nearby: 0.15,
    risk: 0.10,
  ),
  missingFee: MissingFeeConfig(
    defaultWaterMonthly: 60,
    defaultElectricityMonthly: 150,
    costScoreCapWhenMissing: 70,
  ),
  blockerRisks: [
    RiskFlagDef(key: 'risk_non_residential', label: '非居住空间用于居住'),
    RiskFlagDef(key: 'risk_refuse_identity', label: '拒绝说明房东/授权身份'),
    RiskFlagDef(key: 'risk_deposit_unclear', label: '押金退还规则完全不清'),
    RiskFlagDef(key: 'risk_fire_safety', label: '消防通道严重堵塞或楼栋安全明显异常'),
    RiskFlagDef(key: 'risk_fee_contradiction', label: '费用口径前后矛盾且无法写入合同'),
  ],
  warningRisks: [
    RiskFlagDef(key: 'risk_second_landlord', label: '二房东'),
    RiskFlagDef(key: 'risk_identity_unverified', label: '身份未核验'),
    RiskFlagDef(key: 'risk_no_contract', label: '拒绝写合同/仅口头承诺'),
    RiskFlagDef(key: 'risk_fee_ambiguous', label: '费用口径模糊'),
    RiskFlagDef(key: 'risk_group_rent', label: '群租隔断'),
    RiskFlagDef(key: 'risk_low_price_rush', label: '低价催签'),
  ],
  explanationTemplates: {
    'over_budget': '月总成本 {value} 元超预算上限 {limit} 元{missing_note}',
    'over_budget_missing_note': '（含缺失费用的保守估算，补录真实费用后可重算）',
    'over_commute': '主要通勤 {value} 分钟超上限 {limit} 分钟（{mode}）',
    'cost_capped': '费用信息不完整，成本维度最高 70 分，建议补问水电单价',
    'commute_source': '通勤估算：步行 {walking_meters}m，换乘 {transfer_count} 次',
    'risk_blocker': '命中红线风险：{label}，已淘汰，高分不能抵消',
    'user_correction': '你已修正：{note}',
  },
);
