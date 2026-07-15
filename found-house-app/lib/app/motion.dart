import 'package:flutter/widgets.dart';

/// Global motion tokens. Keeping them central makes the app feel coherent and
/// allows every animated component to respect the system reduced-motion flag.
abstract final class AppMotion {
  static const Duration tabSwitch = Duration(milliseconds: 180);
  static const Duration pagePush = Duration(milliseconds: 260);
  static const Duration pagePop = Duration(milliseconds: 220);
  static const Duration sheetExpand = Duration(milliseconds: 240);
  static const Duration sheetSettle = Duration(milliseconds: 220);
  static const Duration buttonPress = Duration(milliseconds: 80);
  static const Duration saveSuccess = Duration(milliseconds: 600);
  static const Duration listInsert = Duration(milliseconds: 220);
  static const Duration scoreReveal = Duration(milliseconds: 500);
  static const Duration riskHint = Duration(milliseconds: 160);

  /// Kawaii Minimal buttons and tappable cards lift softly in 200–300 ms.
  static const Duration softFeedback = Duration(milliseconds: 240);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve linear = Curves.linear;

  /// A restrained spring impression that remains comfortable while reading.
  static const Curve softFeedbackCurve = Curves.easeOutBack;

  static const Curve tabSwitchCurve = easeOut;
  static const Curve pagePushCurve = easeOutCubic;
  static const Curve pagePopCurve = easeInOut;
  static const Curve sheetExpandCurve = easeOutCubic;
  static const Curve scoreRevealCurve = easeOutCubic;
  static const Curve listInsertCurve = easeOut;

  static bool animationsDisabled(BuildContext context) =>
      AppMotionHelper.reduceMotion(context);
}

/// Motion accessibility helpers shared by pages and visual primitives.
abstract final class AppMotionHelper {
  static bool reduceMotion(BuildContext context) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  static Duration effectiveDuration(BuildContext context, Duration duration) {
    return reduceMotion(context) ? Duration.zero : duration;
  }
}
