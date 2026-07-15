import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_house_app/app/theme.dart';

void main() {
  group('Kawaii Minimal theme', () {
    test('uses a cream canvas with rounded sticker surfaces', () {
      final theme = buildAppTheme();
      final cardShape = theme.cardTheme.shape! as RoundedRectangleBorder;

      expect(AppColors.background, const Color(0xFFFFFAF7));
      expect(theme.scaffoldBackgroundColor, Colors.transparent);
      expect(
        cardShape.borderRadius,
        const BorderRadius.all(Radius.circular(24)),
      );
    });

    test('uses a soft candy-pink primary action with gentle motion', () {
      final theme = buildAppTheme();
      final buttonStyle = theme.filledButtonTheme.style!;

      expect(AppColors.primary, const Color(0xFFFF5C92));
      expect(
        buttonStyle.shape!.resolve(<WidgetState>{}),
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      );
      expect(buttonStyle.animationDuration, const Duration(milliseconds: 240));
    });
  });
}
