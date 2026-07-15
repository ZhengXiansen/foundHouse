// house_scoring_controller 映射逻辑单测（W4 · 决策 UI 核心）。
//
// 重点覆盖纯逻辑映射：
//   - 成本映射：缺水电单价触发保守补偿 + hasMissingFee 标记（F2）；
//   - 风险拆分：warning 计 warningCount，blocker 命中 → 硬筛淘汰；
//   - 硬筛 rejected 的房源仍产出评分（降权保留，不隐藏，UI §5.7）；
//   - 通勤 JSON 解析 + 主口径选择（F5）；
//   - 用户主观修正覆盖 nearby 维度；
//   - 必选硬性条件缺失淘汰。
//
// 用内存领域对象直接喂 HouseScoringService，不依赖平台通道/数据库。

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/data/models/house_models.dart' as domain;
import 'package:found_house_app/features/scoring/house_scoring_controller.dart';

/// 构造一个最小房源（可覆盖各子对象）。
domain.HouseRecord buildHouse({
  String id = 'h1',
  String title = '测试房源',
  double? latitude,
  double? longitude,
  String? addressText,
  String? buildingName,
  String? roomNo,
  domain.FeeInfo? fee,
  domain.RoomInfo? room,
  domain.ContactInfo? contact,
  domain.MapSnapshot? mapSnapshot,
  List<domain.ChecklistItem> checklistItems = const [],
  List<domain.RiskFlag> riskFlags = const [],
}) {
  return domain.HouseRecord(
    id: id,
    title: title,
    latitude: latitude,
    longitude: longitude,
    addressText: addressText,
    buildingName: buildingName,
    roomNo: roomNo,
    createdAt: 1,
    updatedAt: 1,
    fee: fee,
    room: room,
    contact: contact,
    mapSnapshot: mapSnapshot,
    checklistItems: checklistItems,
    riskFlags: riskFlags,
  );
}

domain.PreferenceProfile buildPref({
  int? maxRentTotal = 5000,
  int? maxCommuteMinutes = 60,
  String? destinationsJson,
  String? requiredFeaturesJson,
  String? preferredCommuteMode,
}) {
  return domain.PreferenceProfile(
    id: 'default',
    maxRentTotal: maxRentTotal,
    maxCommuteMinutes: maxCommuteMinutes,
    destinationsJson: destinationsJson,
    requiredFeaturesJson: requiredFeaturesJson,
    preferredCommuteMode: preferredCommuteMode,
  );
}

void main() {
  final service = HouseScoringService();

  group('成本映射（F1/F2）', () {
    test('齐全费用不触发缺失补偿', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 2000,
          managementFee: 100,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
      );
      final view = service.evaluate(house, buildPref());
      expect(view.cost.hasMissingFee, isFalse);
      // 押金不计入；rent+management+保守水电月估值。
      expect(view.estimatedTotalMonthly, 2310);
    });

    test('缺水电单价触发保守补偿并置 hasMissingFee', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(rentMonthly: 2000),
      );
      final view = service.evaluate(house, buildPref());
      expect(view.cost.hasMissingFee, isTrue);
      // 默认补偿：水 60 + 电 150 = 210。
      expect(view.estimatedTotalMonthly, 2000 + 60 + 150);
      // cost 维度因缺失被封顶（costCapped）。
      expect(view.score.breakdown.costCapped, isTrue);
    });
  });

  group('风险拆分（warning 扣分 / blocker 淘汰）', () {
    test('warning 风险计入 warningCount，不触发硬筛淘汰', () {
      // 补全押付方式与身份核验，隔离 missingCritical 扣分，单测只观察 warning 影响。
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          paymentCycle: '押一付一',
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        contact: const domain.ContactInfo(identityVerified: true),
        riskFlags: const [
          domain.RiskFlag(
            id: 'r1',
            houseId: 'h1',
            key: 'risk_second_landlord',
            severity: 'warning',
          ),
        ],
      );
      final view = service.evaluate(house, buildPref());
      expect(view.rejected, isFalse);
      expect(view.hasBlocker, isFalse);
      // 单个 warning 扣 12 分，无 missingCritical：risk 维度应为 88。
      expect(view.score.breakdown.risk, 88);
    });

    test('blocker 风险命中触发硬筛淘汰，且仍产出评分', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        riskFlags: const [
          domain.RiskFlag(
            id: 'r1',
            houseId: 'h1',
            key: 'risk_non_residential',
            severity: 'blocker',
          ),
        ],
      );
      final view = service.evaluate(house, buildPref());
      expect(view.rejected, isTrue);
      expect(view.hasBlocker, isTrue);
      // 淘汰原因含 hit_blocker_risk。
      expect(
        view.filter.reasons.any((r) => r.ruleId == 'hit_blocker_risk'),
        isTrue,
      );
      // 降权保留：总分仍被计算（>0）。
      expect(view.score.total, greaterThan(0));
    });
  });

  group('硬筛：预算/通勤/必选条件', () {
    test('月总成本超上限触发 over_budget 淘汰', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 6000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
      );
      final view = service.evaluate(house, buildPref(maxRentTotal: 5000));
      expect(view.rejected, isTrue);
      expect(
        view.filter.reasons.any((r) => r.ruleId == 'over_budget'),
        isTrue,
      );
    });

    test('缺必选条件（独卫）触发淘汰', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        room: const domain.RoomInfo(hasPrivateBathroom: false),
      );
      final pref = buildPref(
        requiredFeaturesJson: jsonEncode({'private_bathroom': true}),
      );
      final view = service.evaluate(house, pref);
      expect(view.rejected, isTrue);
      expect(
        view.filter.reasons.any((r) => r.ruleId == 'missing_required_feature'),
        isTrue,
      );
    });

    test('满足必选条件时通过', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        room: const domain.RoomInfo(hasPrivateBathroom: true),
        contact: const domain.ContactInfo(identityVerified: true),
      );
      final pref = buildPref(
        requiredFeaturesJson: jsonEncode({'private_bathroom': true}),
      );
      final view = service.evaluate(house, pref);
      expect(view.rejected, isFalse);
    });
  });

  group('通勤 JSON 解析与主口径（F5）', () {
    test('无地图快照时 primaryCommuteMinutes 为 null，不做通勤硬筛', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
      );
      final view = service.evaluate(house, buildPref());
      expect(view.primaryCommuteMinutes, isNull);
      expect(view.commute.hasResult, isFalse);
      // 通勤维度按中性默认计分并标记缺失。
      expect(view.score.breakdown.commuteMissing, isTrue);
    });

    test('解析 results 数组默认取 transit', () {
      final commuteJson = jsonEncode({
        'results': [
          {'mode': 'driving', 'durationMinutes': 20},
          {
            'mode': 'transit',
            'durationMinutes': 35,
            'transferCount': 1,
            'walkingMeters': 700,
          },
        ],
      });
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        mapSnapshot: domain.MapSnapshot(commuteJson: commuteJson),
      );
      final view = service.evaluate(house, buildPref());
      expect(view.commute.hasResult, isTrue);
      expect(view.commute.mode, 'transit');
      expect(view.primaryCommuteMinutes, 35);
    });

    test('多目的地时取 primary=true 目的地的主要通勤', () {
      final commuteJson = jsonEncode({
        'results': [
          {
            'destinationId': 'gym',
            'mode': 'transit',
            'durationMinutes': 80,
          },
          {
            'destinationId': 'work',
            'mode': 'driving',
            'durationMinutes': 20,
          },
          {
            'destinationId': 'work',
            'mode': 'transit',
            'durationMinutes': 35,
          },
        ],
      });
      final pref = buildPref(
        destinationsJson: jsonEncode([
          {'id': 'gym', 'label': '健身房', 'primary': false},
          {'id': 'work', 'label': '公司', 'primary': true},
        ]),
      );
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        mapSnapshot: domain.MapSnapshot(commuteJson: commuteJson),
      );

      final view = service.evaluate(house, pref);

      expect(view.commute.destinationId, 'work');
      expect(view.commute.mode, 'transit');
      expect(view.primaryCommuteMinutes, 35);
    });

    test('通勤超上限触发 over_commute 淘汰', () {
      final commuteJson = jsonEncode({
        'results': [
          {'mode': 'transit', 'durationMinutes': 90},
        ],
      });
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        mapSnapshot: domain.MapSnapshot(commuteJson: commuteJson),
      );
      final view = service.evaluate(house, buildPref(maxCommuteMinutes: 60));
      expect(view.rejected, isTrue);
      expect(
        view.filter.reasons.any((r) => r.ruleId == 'over_commute'),
        isTrue,
      );
    });

    test('损坏的通勤 JSON 容错为无数据', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        mapSnapshot: const domain.MapSnapshot(commuteJson: '{bad json'),
      );
      final view = service.evaluate(house, buildPref());
      expect(view.primaryCommuteMinutes, isNull);
    });
  });

  group('居住维度与用户主观修正', () {
    test('affects=living 的 checklist 项映射入 living 计分', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        checklistItems: const [
          // room_lighting affects=living（good=100）。
          domain.ChecklistItem(
            id: 'c1',
            houseId: 'h1',
            module: 'room',
            key: 'room_lighting',
            value: 'good',
          ),
          // room_noise affects=living（bad=30）。
          domain.ChecklistItem(
            id: 'c2',
            houseId: 'h1',
            module: 'room',
            key: 'room_noise',
            value: 'bad',
          ),
        ],
      );
      final view = service.evaluate(house, buildPref());
      // (100 + 30) / 2 = 65。
      expect(view.score.breakdown.living, 65);
      expect(view.score.breakdown.livingMissing, isFalse);
    });

    test('无 living 项时按中性默认并标记缺失', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
      );
      final view = service.evaluate(house, buildPref());
      expect(view.score.breakdown.livingMissing, isTrue);
    });

    test('用户主观修正覆盖 nearby 维度', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 1000,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
        mapSnapshot: domain.MapSnapshot(
          userCorrectionJson: jsonEncode({'score': 90, 'note': '路难走但生活方便'}),
        ),
      );
      final view = service.evaluate(house, buildPref());
      expect(view.score.breakdown.nearby, 90);
      // 解释文案含 user_correction。
      expect(
        view.score.explanations.any((e) => e.code == 'user_correction'),
        isTrue,
      );
    });
  });

  group('偏好缺失兜底', () {
    test('无偏好时用不限制哨兵，仍产出评分且不误淘汰预算', () {
      final house = buildHouse(
        fee: const domain.FeeInfo(
          rentMonthly: 99999,
          waterUnitPrice: 5,
          electricityUnitPrice: 1,
        ),
      );
      final view = service.evaluate(house, null);
      // 无预算上限不触发 over_budget。
      expect(
        view.filter.reasons.any((r) => r.ruleId == 'over_budget'),
        isFalse,
      );
      expect(view.score.ruleVersion, service.ruleVersion);
    });
  });
}
