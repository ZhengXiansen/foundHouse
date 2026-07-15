// 主要通勤选择单测（F5：transit 主口径，首选优先，回退 driving）。

import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/features/scoring/commute_selector.dart';
import 'package:found_house_app/features/scoring/scoring_models.dart';

void main() {
  const selector = CommuteSelector();

  group('主要通勤选择（F5）', () {
    test('默认取 transit', () {
      final r = selector.select(const [
        CommuteOption(mode: 'driving', minutes: 20),
        CommuteOption(mode: 'transit', minutes: 35, transferCount: 1),
      ]);
      expect(r.hasResult, isTrue);
      expect(r.mode, 'transit');
      expect(r.minutes, 35);
      expect(r.transferCount, 1);
    });

    test('用户首选优先于 transit', () {
      final r = selector.select(
        const [
          CommuteOption(mode: 'transit', minutes: 35),
          CommuteOption(mode: 'driving', minutes: 20),
        ],
        preferredMode: 'driving',
      );
      expect(r.mode, 'driving');
      expect(r.minutes, 20);
    });

    test('无 transit 结果回退 driving', () {
      final r = selector.select(const [
        CommuteOption(mode: 'driving', minutes: 25),
        CommuteOption(mode: 'walking', minutes: 60),
      ]);
      expect(r.mode, 'driving');
      expect(r.minutes, 25);
    });

    test('首选方式无对应结果时回退 transit', () {
      final r = selector.select(
        const [
          CommuteOption(mode: 'transit', minutes: 40),
          CommuteOption(mode: 'driving', minutes: 22),
        ],
        preferredMode: 'walking', // 无 walking 结果
      );
      expect(r.mode, 'transit');
    });

    test('既无 transit 也无 driving：兜底取第一条', () {
      final r = selector.select(const [
        CommuteOption(mode: 'walking', minutes: 55),
        CommuteOption(mode: 'bicycling', minutes: 30),
      ]);
      expect(r.hasResult, isTrue);
      expect(r.mode, 'walking');
    });

    test('空列表返回 empty，不参与通勤硬筛', () {
      final r = selector.select(const []);
      expect(r.hasResult, isFalse);
      expect(r.minutes, 0);
    });

    test('先按 primary destination 过滤，再按 mode 选择', () {
      final r = selector.select(
        const [
          CommuteOption(
            destinationId: 'gym',
            mode: 'transit',
            minutes: 80,
          ),
          CommuteOption(
            destinationId: 'work',
            mode: 'driving',
            minutes: 20,
          ),
          CommuteOption(
            destinationId: 'work',
            mode: 'transit',
            minutes: 35,
          ),
        ],
        primaryDestinationId: 'work',
      );

      expect(r.destinationId, 'work');
      expect(r.mode, 'transit');
      expect(r.minutes, 35);
    });
  });
}
