// 加权评分引擎单测（W4 · G3，冻结项 F2/F3/F4/F8）。
//
// 覆盖：加权求和=权重100、cost 封顶 70、全项 clamp、risk 多 warning 不为负、
// 缺失估值兜底（living/commute/nearby 中性默认）、user_correction 优先、规则版本化。

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/features/scoring/score_engine.dart';
import 'package:found_house_app/features/scoring/score_rule.dart';
import 'package:found_house_app/features/scoring/scoring_models.dart';

void main() {
  final engine = ScoreEngine();

  group('权重与规则版本（F4/F8）', () {
    test('内置默认权重之和为 1.0', () {
      expect(defaultScoreRule.weights.sum, closeTo(1.0, 1e-9));
    });

    test('结果携带规则版本 mvp-2026-07-02', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 2000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          livingValues: [ChecklistValue.good],
          nearbyBaseScore: 80,
        ),
      );
      expect(r.ruleVersion, 'mvp-2026-07-02');
    });

    test('全维度满分时总分=100（加权求和=权重100）', () {
      // cost: total=0 → 100；commute: minutes=0,transfer=0 → 100；
      // living: 全 good → 100；nearby: 100；risk: 无扣分 → 100。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 0,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 0,
          livingValues: [ChecklistValue.good, ChecklistValue.good],
          nearbyBaseScore: 100,
        ),
      );
      expect(r.breakdown.cost, 100);
      expect(r.breakdown.commute, 100);
      expect(r.breakdown.living, 100);
      expect(r.breakdown.nearby, 100);
      expect(r.breakdown.risk, 100);
      expect(r.total, closeTo(100, 1e-9));
    });

    test('手工核对加权求和', () {
      // cost: total=1500/max=3000 → 100-0.5*40=80
      // commute: 30/60 → 100-0.5*50-0=75
      // living: good+ok → (100+70)/2=85
      // nearby: 60
      // risk: 1 warning → 100-12=88
      // total = 80*.3 + 75*.2 + 85*.25 + 60*.15 + 88*.1
      //       = 24 + 15 + 21.25 + 9 + 8.8 = 78.05
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1500,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          livingValues: [ChecklistValue.good, ChecklistValue.ok],
          nearbyBaseScore: 60,
          warningCount: 1,
        ),
      );
      expect(r.breakdown.cost, closeTo(80, 1e-9));
      expect(r.breakdown.commute, closeTo(75, 1e-9));
      expect(r.breakdown.living, closeTo(85, 1e-9));
      expect(r.breakdown.nearby, closeTo(60, 1e-9));
      expect(r.breakdown.risk, closeTo(88, 1e-9));
      expect(r.total, closeTo(78.05, 1e-9));
    });
  });

  group('cost 维度（F2）', () {
    test('缺失费用时 cost_score 封顶 70', () {
      // total=0 → raw=100，缺失 → min(100,70)=70。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 0,
          maxRentTotal: 3000,
          hasMissingFee: true,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
        ),
      );
      expect(r.breakdown.cost, 70);
      expect(r.breakdown.costCapped, isTrue);
      expect(
        r.explanations.any((e) => e.code == 'cost_capped'),
        isTrue,
      );
    });

    test('缺失费用但 raw 已低于 70：不抬高，仍标记封顶与文案', () {
      // total=2400/3000 → 100-0.8*40=68 < 70，min 不改变，但仍标记缺失。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 2400,
          maxRentTotal: 3000,
          hasMissingFee: true,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
        ),
      );
      expect(r.breakdown.cost, closeTo(68, 1e-9));
      expect(r.breakdown.costCapped, isTrue);
    });

    test('cost 超支时 clamp 到 0（不为负）', () {
      // total 远超预算 → raw 负 → clamp 0。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 30000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
        ),
      );
      expect(r.breakdown.cost, 0);
    });

    test('maxRentTotal 为 0 时不崩溃（除零保护）', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 0,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
        ),
      );
      expect(r.breakdown.cost, 0);
    });
  });

  group('commute 维度（F5）', () {
    test('换乘扣分：每次扣 5', () {
      // 30/60 → 100-25-2*5=65。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          transferCount: 2,
        ),
      );
      expect(r.breakdown.commute, closeTo(65, 1e-9));
    });

    test('无通勤数据取中性默认 60 并标记缺失', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: null,
        ),
      );
      expect(r.breakdown.commute, 60);
      expect(r.breakdown.commuteMissing, isTrue);
      expect(r.explanations.any((e) => e.code == 'commute_missing'), isTrue);
    });

    test('超长通勤 clamp 到 0', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 300,
        ),
      );
      expect(r.breakdown.commute, 0);
    });
  });

  group('living 维度', () {
    test('not_seen 不计入分母', () {
      // good + notSeen*3 → 只算 good，均值 100。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          livingValues: [
            ChecklistValue.good,
            ChecklistValue.notSeen,
            ChecklistValue.notSeen,
            ChecklistValue.notSeen,
          ],
        ),
      );
      expect(r.breakdown.living, 100);
      expect(r.breakdown.livingMissing, isFalse);
    });

    test('good/ok/bad 均值', () {
      // (100+70+30)/3 = 66.666...
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          livingValues: [
            ChecklistValue.good,
            ChecklistValue.ok,
            ChecklistValue.bad,
          ],
        ),
      );
      expect(r.breakdown.living, closeTo(200 / 3, 1e-9));
    });

    test('无有效项（全 not_seen 或空）取中性默认并标记缺失', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          livingValues: [ChecklistValue.notSeen],
        ),
      );
      expect(r.breakdown.living, 60);
      expect(r.breakdown.livingMissing, isTrue);
      expect(r.explanations.any((e) => e.code == 'living_missing'), isTrue);
    });
  });

  group('nearby 维度', () {
    test('user_correction 优先于 POI 计分', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          nearbyBaseScore: 40,
          nearbyUserCorrection: 90,
          nearbyCorrectionNote: '楼下就是地铁口',
        ),
      );
      expect(r.breakdown.nearby, 90);
      expect(r.explanations.any((e) => e.code == 'user_correction'), isTrue);
    });

    test('仅 POI 计分', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          nearbyBaseScore: 55,
        ),
      );
      expect(r.breakdown.nearby, 55);
    });

    test('无 POI 无修正取中性默认并标记缺失', () {
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
        ),
      );
      expect(r.breakdown.nearby, 60);
      expect(r.breakdown.nearbyMissing, isTrue);
    });
  });

  group('risk 维度（F3）', () {
    test('多 warning 叠加扣分不为负', () {
      // 100 - 12*10 = -20 → clamp 0。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          warningCount: 10,
        ),
      );
      expect(r.breakdown.risk, 0);
    });

    test('warning + 关键缺失叠加', () {
      // 100 - 2*12 - 3*8 = 100-24-24 = 52。
      final r = engine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 1000,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 30,
          warningCount: 2,
          missingCriticalCount: 3,
        ),
      );
      expect(r.breakdown.risk, closeTo(52, 1e-9));
    });
  });

  group('远程规则覆盖（F8）', () {
    test('从 JSON Map 构造规则并生效', () {
      final rule = ScoreRule.fromJson(const {
        'score_rule_version': 'test-v1',
        'weights': {
          'cost': 0.5,
          'commute': 0.5,
          'living': 0.0,
          'nearby': 0.0,
          'risk': 0.0,
        },
        'missing_fee': {
          'default_water_monthly': 60,
          'default_electricity_monthly': 150,
          'cost_score_cap_when_missing': 70,
        },
        'risk_flags': {
          'blocker': [
            {'key': 'risk_non_residential', 'label': '非居住空间'},
          ],
          'warning': [
            {'key': 'risk_second_landlord', 'label': '二房东'},
          ],
        },
        'explanation_templates': {
          'cost_capped': '测试封顶文案',
        },
      });
      final customEngine = ScoreEngine(rule: rule);
      final r = customEngine.evaluate(
        const ScoreInput(
          estimatedTotalMonthly: 0,
          maxRentTotal: 3000,
          hasMissingFee: false,
          maxCommuteMinutes: 60,
          primaryCommuteMinutes: 0,
        ),
      );
      expect(r.ruleVersion, 'test-v1');
      // cost=100, commute=100, 其余权重0 → total=100。
      expect(r.total, closeTo(100, 1e-9));
    });
  });
}
