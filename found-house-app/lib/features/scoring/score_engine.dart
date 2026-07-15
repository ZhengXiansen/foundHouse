// 加权评分引擎（W4 · G3，技术方案 §6.3，冻结项 F2/F3/F4/F8）。
//
// 5 维加权求和：cost*0.30 + commute*0.20 + living*0.25 + nearby*0.15 + risk*0.10。
// 所有分项 clamp(0,100)（F3，含 risk 不为负）；缺失费用时 cost 封顶 70（F2）；
// 权重与系数一律取自 ScoreRule（内置默认可远程覆盖，F8），不硬编码；
// 结果连同 ruleVersion 输出，供 ScoreSnapshot 冻结（F8）。
//
// 关键约束：不依赖 UI/drift，仅依赖 dart:core，便于单元测试。

import 'score_rule.dart';
import 'scoring_models.dart';

/// 加权评分引擎。接收规则对象（默认内置，允许远程覆盖）。
class ScoreEngine {
  ScoreEngine({ScoreRule? rule}) : _rule = rule ?? defaultScoreRule;

  final ScoreRule _rule;

  /// 计算 5 维分与加权总分，收集解释文案。
  ScoreResult evaluate(ScoreInput input) {
    final explanations = <ScoreExplanation>[];

    final cost = _costScore(input, explanations);
    final commute = _commuteScore(input, explanations);
    final living = _livingScore(input, explanations);
    final nearby = _nearbyScore(input, explanations);
    final risk = _riskScore(input);

    final w = _rule.weights;
    final total = cost.value * w.cost +
        commute.value * w.commute +
        living.value * w.living +
        nearby.value * w.nearby +
        risk * w.risk;

    final breakdown = ScoreBreakdown(
      cost: cost.value,
      commute: commute.value,
      living: living.value,
      nearby: nearby.value,
      risk: risk,
      costCapped: cost.capped,
      commuteMissing: commute.missing,
      livingMissing: living.missing,
      nearbyMissing: nearby.missing,
    );

    return ScoreResult(
      total: _clamp(total),
      breakdown: breakdown,
      explanations: explanations,
      ruleVersion: _rule.version,
    );
  }

  // cost_score = clamp(100 - (total/max)*factor, 0, 100)，缺失费用再 min(raw,70)（F2）。
  _DimResult _costScore(ScoreInput input, List<ScoreExplanation> exp) {
    final max = input.maxRentTotal <= 0 ? 1 : input.maxRentTotal;
    final raw =
        100 - (input.estimatedTotalMonthly / max) * _rule.costRentFactor;
    var score = _clamp(raw);

    var capped = false;
    if (input.hasMissingFee) {
      final cap = _rule.missingFee.costScoreCapWhenMissing.toDouble();
      if (score > cap) {
        score = cap;
        capped = true;
      } else {
        // 未触及封顶阈值，但仍标记缺失并给出建议补录文案。
        capped = true;
      }
      exp.add(
        ScoreExplanation(
          code: 'cost_capped',
          message: _rule.explanationTemplates['cost_capped'] ??
              '费用信息不完整，成本维度最高 70 分，建议补问水电单价',
        ),
      );
    }
    return _DimResult(score, capped: capped);
  }

  // commute_score = clamp(100 - (minutes/max)*factor - transfer*penalty, 0, 100)。
  // 无通勤数据时取中性默认并标记缺失。
  _DimResult _commuteScore(ScoreInput input, List<ScoreExplanation> exp) {
    final minutes = input.primaryCommuteMinutes;
    if (minutes == null) {
      exp.add(
        const ScoreExplanation(
          code: 'commute_missing',
          message: '暂无通勤数据，通勤维度按中性默认计分',
        ),
      );
      return _DimResult(_rule.neutralDefault.toDouble(), missing: true);
    }

    final max = input.maxCommuteMinutes <= 0 ? 1 : input.maxCommuteMinutes;
    final raw = 100 -
        (minutes / max) * _rule.commuteTimeFactor -
        input.transferCount * _rule.commuteTransferPenalty;

    exp.add(
      ScoreExplanation(
        code: 'commute_source',
        message: _fill(
          _rule.explanationTemplates['commute_source'] ??
              '通勤估算：步行 {walking_meters}m，换乘 {transfer_count} 次',
          {
            'walking_meters': '${input.walkingMeters ?? 0}',
            'transfer_count': '${input.transferCount}',
          },
        ),
      ),
    );
    return _DimResult(_clamp(raw));
  }

  // living_score = affects=living 项均值（good=100/ok=70/bad=30，not_seen 不计入分母）。
  // 无有效项 → 中性默认并标记缺失。
  _DimResult _livingScore(ScoreInput input, List<ScoreExplanation> exp) {
    var sum = 0.0;
    var count = 0;
    for (final v in input.livingValues) {
      switch (v) {
        case ChecklistValue.good:
          sum += 100;
          count++;
        case ChecklistValue.ok:
          sum += 70;
          count++;
        case ChecklistValue.bad:
          sum += 30;
          count++;
        case ChecklistValue.notSeen:
          // 不计入分母（F：not_seen 不计分）。
          break;
      }
    }

    if (count == 0) {
      exp.add(
        const ScoreExplanation(
          code: 'living_missing',
          message: '暂无有效居住检查项，居住维度按中性默认计分',
        ),
      );
      return _DimResult(_rule.neutralDefault.toDouble(), missing: true);
    }
    return _DimResult(_clamp(sum / count));
  }

  // nearby_score：user_correction 优先于系统周边计分；两者皆无 → 中性默认并标记缺失。
  _DimResult _nearbyScore(ScoreInput input, List<ScoreExplanation> exp) {
    if (input.nearbyUserCorrection != null) {
      exp.add(
        ScoreExplanation(
          code: 'user_correction',
          message: _fill(
            _rule.explanationTemplates['user_correction'] ?? '你已修正：{note}',
            {'note': input.nearbyCorrectionNote ?? '周边便利度'},
          ),
        ),
      );
      return _DimResult(_clamp(input.nearbyUserCorrection!));
    }
    if (input.nearbyBaseScore != null) {
      return _DimResult(_clamp(input.nearbyBaseScore!));
    }
    exp.add(
      const ScoreExplanation(
        code: 'nearby_missing',
        message: '暂无周边数据，周边维度按中性默认计分',
      ),
    );
    return _DimResult(_rule.neutralDefault.toDouble(), missing: true);
  }

  // risk_score = clamp(100 - warning*12 - missingCritical*8, 0, 100)（F3 不为负）。
  double _riskScore(ScoreInput input) {
    final raw = 100 -
        input.warningCount * _rule.riskWarningPenalty -
        input.missingCriticalCount * _rule.riskMissingCriticalPenalty;
    return _clamp(raw.toDouble());
  }

  double _clamp(double v) => v.clamp(0, 100).toDouble();

  String _fill(String template, Map<String, String> values) {
    var out = template;
    values.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }
}

/// 单维计分中间结果（分值 + 缺失/封顶标记）。
class _DimResult {
  const _DimResult(this.value, {this.capped = false, this.missing = false});

  final double value;
  final bool capped;
  final bool missing;
}
