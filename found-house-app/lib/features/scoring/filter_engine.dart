// 硬筛选引擎（W4 · G2，技术方案 §6.2，冻结项 F1/F5）。
//
// 职责边界：
//   - 预算硬筛唯一基准为月总成本 estimatedTotalMonthly > maxRentTotal（F1，非月租）；
//   - 主要通勤时间（transit 主口径，可回退 driving，F5）> maxCommuteMinutes；
//   - 缺少必选条件（如必须独卫但无独卫）；
//   - 命中任一 blocker 风险。
//   命中后 outcome=rejected，且每条淘汰必须带可读原因（来自 explanation_templates）。
//
// 关键约束：不依赖 UI/drift，仅依赖 dart:core，便于单元测试。

import 'score_rule.dart';
import 'scoring_models.dart';

/// 硬筛引擎。接收规则对象（默认内置，允许远程覆盖）。
class FilterEngine {
  FilterEngine({ScoreRule? rule}) : _rule = rule ?? defaultScoreRule;

  final ScoreRule _rule;

  /// 执行硬筛。命中任一规则即 rejected；所有命中原因均收集返回（不短路）。
  FilterResult evaluate(FilterInput input) {
    final reasons = <FilterReason>[];

    _checkBudget(input, reasons);
    _checkCommute(input, reasons);
    _checkRequiredFeatures(input, reasons);
    _checkBlockerRisk(input, reasons);

    final outcome =
        reasons.isEmpty ? HardFilterOutcome.pass : HardFilterOutcome.rejected;
    return FilterResult(outcome: outcome, reasons: reasons);
  }

  // 预算：月总成本（含缺失补偿）> 上限（F1）。
  void _checkBudget(FilterInput input, List<FilterReason> reasons) {
    if (input.estimatedTotalMonthly <= input.maxRentTotal) return;

    final missingNote = input.hasMissingFee
        ? (_rule.explanationTemplates['over_budget_missing_note'] ?? '')
        : '';
    final message = _fill(
      _rule.explanationTemplates['over_budget'] ??
          '月总成本 {value} 元超预算上限 {limit} 元{missing_note}',
      {
        'value': '${input.estimatedTotalMonthly}',
        'limit': '${input.maxRentTotal}',
        'missing_note': missingNote,
      },
    );
    reasons.add(FilterReason(ruleId: 'over_budget', message: message));
  }

  // 通勤：主要通勤时间 > 上限（F5）。无数据（null）不淘汰，地图失败不阻断。
  void _checkCommute(FilterInput input, List<FilterReason> reasons) {
    final minutes = input.primaryCommuteMinutes;
    if (minutes == null) return;
    if (minutes <= input.maxCommuteMinutes) return;

    final message = _fill(
      _rule.explanationTemplates['over_commute'] ??
          '主要通勤 {value} 分钟超上限 {limit} 分钟（{mode}）',
      {
        'value': '$minutes',
        'limit': '${input.maxCommuteMinutes}',
        'mode': _modeLabel(input.commuteMode),
      },
    );
    reasons.add(FilterReason(ruleId: 'over_commute', message: message));
  }

  // 必选条件：房源缺少任一必选布尔项即淘汰。false/未记录(null) 均视为不满足。
  void _checkRequiredFeatures(FilterInput input, List<FilterReason> reasons) {
    for (final feature in input.requiredFeatures) {
      final satisfied = input.houseFeatures[feature.key] ?? false;
      if (!satisfied) {
        reasons.add(
          FilterReason(
            ruleId: 'missing_required_feature',
            message: '缺少必选条件：${feature.label}',
          ),
        );
      }
    }
  }

  // blocker 风险：命中任一红线即淘汰，每条独立成因（高分不能抵消）。
  void _checkBlockerRisk(FilterInput input, List<FilterReason> reasons) {
    final blockerKeys = _rule.blockerRiskKeys;
    for (final key in input.hitRiskKeys) {
      if (!blockerKeys.contains(key)) continue;
      final message = _fill(
        _rule.explanationTemplates['risk_blocker'] ??
            '命中红线风险：{label}，已淘汰，高分不能抵消',
        {'label': _rule.blockerLabel(key)},
      );
      reasons.add(FilterReason(ruleId: 'hit_blocker_risk', message: message));
    }
  }

  // 用 {key} 占位替换模板。
  String _fill(String template, Map<String, String> values) {
    var out = template;
    values.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'transit':
        return '公交';
      case 'driving':
        return '驾车';
      case 'walking':
        return '步行';
      case 'bicycling':
        return '骑行';
      default:
        return mode;
    }
  }
}
