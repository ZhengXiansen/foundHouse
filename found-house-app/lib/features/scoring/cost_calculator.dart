// 月总成本计算（W4 · G1，冻结项 F1/F2）。
//
// 纯函数，仅依赖 dart:core。月租计入月总成本；押金为无关月成本不计入。
// 水电月费用未单独记录时用 default_water_monthly/default_electricity_monthly
// 保守估值计入，避免低估成本（F2）；单价缺失时同时置 hasMissingFee 标记，
// 供 cost_score 封顶（F2）。

import 'score_rule.dart';
import 'scoring_models.dart';

/// 月总成本计算器（无状态，可复用单个实例）。
class CostCalculator {
  const CostCalculator({ScoreRule? rule}) : _rule = rule ?? defaultScoreRule;

  final ScoreRule _rule;

  /// 计算月总成本。水/电月费用无单独字段，按规则默认月估值保守计入（F2）。
  ///
  /// 说明：本引擎不做单价×用量的精细估算（现场难拿到准确用量）。
  /// 由于当前模型只记录水电单价、没有已估算月费字段，月总成本始终
  /// 计入「片区默认月估值」；单价缺失仅影响 hasMissingFee 与 cost cap。
  CostResult calculate(CostInput input) {
    var total = 0;

    total += _nonNegative(input.rentMonthly);
    total += _nonNegative(input.managementFee);
    total += _nonNegative(input.internetFee);
    total += _nonNegative(input.gasFee);
    total += _nonNegative(input.otherFee);

    final waterMissing = input.waterUnitPrice == null;
    final electricityMissing = input.electricityUnitPrice == null;

    // 未记录水电月费用 → 始终用保守月估值计入（F2，不低估）。
    total += _rule.missingFee.defaultWaterMonthly;
    total += _rule.missingFee.defaultElectricityMonthly;

    return CostResult(
      estimatedTotalMonthly: total,
      hasMissingFee: waterMissing || electricityMissing,
      waterMissing: waterMissing,
      electricityMissing: electricityMissing,
    );
  }

  int _nonNegative(int? v) => (v == null || v < 0) ? 0 : v;
}
