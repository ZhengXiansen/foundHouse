// 硬筛引擎单测（W4 · G2，冻结项 F1/F5）。
// 覆盖四类规则：over_budget / over_commute / missing_required_feature / hit_blocker_risk。

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/features/scoring/filter_engine.dart';
import 'package:found_house_app/features/scoring/scoring_models.dart';

void main() {
  final engine = FilterEngine();

  // 构造一条默认通过的输入，单测按需覆盖字段。
  FilterInput base({
    int maxRentTotal = 3000,
    int maxCommuteMinutes = 60,
    int estimatedTotalMonthly = 2000,
    bool hasMissingFee = false,
    int? primaryCommuteMinutes = 30,
    String commuteMode = 'transit',
    List<RequiredFeature> requiredFeatures = const [],
    Map<String, bool?> houseFeatures = const {},
    List<String> hitRiskKeys = const [],
  }) {
    return FilterInput(
      maxRentTotal: maxRentTotal,
      maxCommuteMinutes: maxCommuteMinutes,
      estimatedTotalMonthly: estimatedTotalMonthly,
      hasMissingFee: hasMissingFee,
      primaryCommuteMinutes: primaryCommuteMinutes,
      commuteMode: commuteMode,
      requiredFeatures: requiredFeatures,
      houseFeatures: houseFeatures,
      hitRiskKeys: hitRiskKeys,
    );
  }

  group('硬筛通过', () {
    test('全部条件满足 → pass，无原因', () {
      final r = engine.evaluate(base());
      expect(r.passed, isTrue);
      expect(r.outcome, HardFilterOutcome.pass);
      expect(r.reasons, isEmpty);
    });

    test('月总成本等于上限 → 不淘汰（严格大于才淘汰，F1）', () {
      final r = engine.evaluate(
        base(
          maxRentTotal: 2000,
          estimatedTotalMonthly: 2000,
        ),
      );
      expect(r.passed, isTrue);
    });

    test('通勤时间等于上限 → 不淘汰', () {
      final r = engine.evaluate(
        base(
          maxCommuteMinutes: 30,
          primaryCommuteMinutes: 30,
        ),
      );
      expect(r.passed, isTrue);
    });
  });

  group('over_budget（F1：月总成本，非月租）', () {
    test('月总成本超上限 → rejected 且原因含金额', () {
      final r = engine.evaluate(
        base(
          maxRentTotal: 2000,
          estimatedTotalMonthly: 2500,
        ),
      );
      expect(r.passed, isFalse);
      final reason = r.reasons.singleWhere((e) => e.ruleId == 'over_budget');
      expect(reason.message, contains('2500'));
      expect(reason.message, contains('2000'));
    });

    test('含缺失费用时淘汰原因附保守估算说明（F2）', () {
      final r = engine.evaluate(
        base(
          maxRentTotal: 2000,
          estimatedTotalMonthly: 2500,
          hasMissingFee: true,
        ),
      );
      final reason = r.reasons.singleWhere((e) => e.ruleId == 'over_budget');
      expect(reason.message, contains('保守估算'));
    });
  });

  group('over_commute（F5）', () {
    test('主要通勤超上限 → rejected 且原因含分钟与方式', () {
      final r = engine.evaluate(
        base(
          maxCommuteMinutes: 30,
          primaryCommuteMinutes: 50,
          commuteMode: 'transit',
        ),
      );
      expect(r.passed, isFalse);
      final reason = r.reasons.singleWhere((e) => e.ruleId == 'over_commute');
      expect(reason.message, contains('50'));
      expect(reason.message, contains('公交'));
    });

    test('无通勤数据（null）→ 不做通勤淘汰（地图失败不阻断）', () {
      final r = engine.evaluate(base(primaryCommuteMinutes: null));
      expect(r.passed, isTrue);
    });
  });

  group('missing_required_feature', () {
    test('必须独卫但房源无独卫 → rejected', () {
      final r = engine.evaluate(
        base(
          requiredFeatures: const [
            RequiredFeature(key: 'has_private_bathroom', label: '独卫'),
          ],
          houseFeatures: const {'has_private_bathroom': false},
        ),
      );
      expect(r.passed, isFalse);
      final reason =
          r.reasons.singleWhere((e) => e.ruleId == 'missing_required_feature');
      expect(reason.message, contains('独卫'));
    });

    test('必选项未记录（null）→ 视为不满足淘汰', () {
      final r = engine.evaluate(
        base(
          requiredFeatures: const [
            RequiredFeature(key: 'has_elevator', label: '电梯'),
          ],
          houseFeatures: const {},
        ),
      );
      expect(r.passed, isFalse);
    });

    test('必选项满足 → 不淘汰', () {
      final r = engine.evaluate(
        base(
          requiredFeatures: const [
            RequiredFeature(key: 'has_private_bathroom', label: '独卫'),
          ],
          houseFeatures: const {'has_private_bathroom': true},
        ),
      );
      expect(r.passed, isTrue);
    });

    test('多个必选项各自缺失 → 各成一条原因', () {
      final r = engine.evaluate(
        base(
          requiredFeatures: const [
            RequiredFeature(key: 'has_private_bathroom', label: '独卫'),
            RequiredFeature(key: 'has_kitchen', label: '厨房'),
          ],
          houseFeatures: const {
            'has_private_bathroom': false,
            'has_kitchen': false,
          },
        ),
      );
      expect(
        r.reasons.where((e) => e.ruleId == 'missing_required_feature').length,
        2,
      );
    });
  });

  group('hit_blocker_risk', () {
    test('命中 blocker → rejected 且原因含红线标签', () {
      final r = engine.evaluate(
        base(
          hitRiskKeys: const ['risk_non_residential'],
        ),
      );
      expect(r.passed, isFalse);
      final reason =
          r.reasons.singleWhere((e) => e.ruleId == 'hit_blocker_risk');
      expect(reason.message, contains('非居住空间'));
    });

    test('命中 warning（非 blocker）→ 不硬筛淘汰', () {
      final r = engine.evaluate(
        base(
          hitRiskKeys: const ['risk_second_landlord'],
        ),
      );
      expect(r.passed, isTrue);
    });
  });

  group('多规则同时命中', () {
    test('超预算+超通勤+缺必选+命中红线 → 四条原因齐全', () {
      final r = engine.evaluate(
        base(
          maxRentTotal: 2000,
          estimatedTotalMonthly: 2500,
          maxCommuteMinutes: 30,
          primaryCommuteMinutes: 50,
          requiredFeatures: const [
            RequiredFeature(key: 'has_private_bathroom', label: '独卫'),
          ],
          houseFeatures: const {'has_private_bathroom': false},
          hitRiskKeys: const ['risk_fire_safety'],
        ),
      );
      expect(r.passed, isFalse);
      final ids = r.reasons.map((e) => e.ruleId).toSet();
      expect(
        ids,
        containsAll(<String>[
          'over_budget',
          'over_commute',
          'missing_required_feature',
          'hit_blocker_risk',
        ]),
      );
    });
  });
}
