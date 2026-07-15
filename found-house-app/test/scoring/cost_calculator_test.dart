// 月总成本计算单测（W4 · G1，冻结项 F1/F2）。

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/features/scoring/cost_calculator.dart';
import 'package:found_house_app/features/scoring/scoring_models.dart';

void main() {
  const calc = CostCalculator();

  group('月总成本计算', () {
    test('全费用齐备：月租+各项固定费用+保守水电月估值求和，押金不计入，无缺失标记', () {
      final r = calc.calculate(
        const CostInput(
          rentMonthly: 2000,
          managementFee: 100,
          internetFee: 50,
          gasFee: 30,
          otherFee: 20,
          waterUnitPrice: 5.0,
          electricityUnitPrice: 1.0,
        ),
      );
      // 未记录水电月费用时，即使有单价也要保守计入默认月估值。
      // 2000 + 100 + 50 + 30 + 20 + 60(水) + 150(电) = 2410。
      expect(r.estimatedTotalMonthly, 2410);
      expect(r.hasMissingFee, isFalse);
      expect(r.waterMissing, isFalse);
      expect(r.electricityMissing, isFalse);
    });

    test('缺水电单价：用默认月估值 60/150 保守补偿并置缺失标记（F2）', () {
      final r = calc.calculate(const CostInput(rentMonthly: 2000));
      // 2000 + 60(水) + 150(电) = 2210。
      expect(r.estimatedTotalMonthly, 2210);
      expect(r.hasMissingFee, isTrue);
      expect(r.waterMissing, isTrue);
      expect(r.electricityMissing, isTrue);
    });

    test('仅缺电单价：只补偿电费默认值', () {
      final r = calc.calculate(
        const CostInput(
          rentMonthly: 1500,
          waterUnitPrice: 5.0,
        ),
      );
      // 1500 + 60(水月估值) + 150(电缺失补偿) = 1710。
      expect(r.estimatedTotalMonthly, 1710);
      expect(r.hasMissingFee, isTrue);
      expect(r.waterMissing, isFalse);
      expect(r.electricityMissing, isTrue);
    });

    test('全空输入：仅缺失水电补偿，负值/空值按 0 处理', () {
      final r = calc.calculate(const CostInput(rentMonthly: -100));
      // 负月租按 0 + 60 + 150 = 210。
      expect(r.estimatedTotalMonthly, 210);
      expect(r.hasMissingFee, isTrue);
    });
  });
}
