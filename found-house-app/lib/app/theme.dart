import 'package:flutter/material.dart';

/// Default semantic colors used by existing feature screens.
///
/// The active Kawaii theme supplies the app-wide canvas and action colors via
/// [KawaiiPalette]. These stable names remain for feature-level status colors
/// and for backwards-compatible presentation defaults.
abstract final class AppColors {
  static const Color background = Color(0xFFFFFAF7);
  static const Color backgroundBlush = Color(0xFFFFF1F6);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFFFF7FA);
  static const Color surfaceMint = Color(0xFFF0FBF7);
  static const Color surfaceYellow = Color(0xFFFFF9E8);

  static const Color textPrimary = Color(0xFF33263B);
  static const Color textSecondary = Color(0xFF756A7D);
  static const Color divider = Color(0xFFF0DFE8);

  static const Color primary = Color(0xFFFF5C92);
  static const Color primaryDark = Color(0xFFE9477D);
  static const Color secondary = Color(0xFF8B6CFF);
  static const Color mint = Color(0xFF51C9A6);
  static const Color sunshine = Color(0xFFF5C556);

  static const Color commute = Color(0xFF4C7DFF);
  static const Color warning = Color(0xFFD98937);
  static const Color risk = Color(0xFFDC5A75);
  static const Color offline = Color(0xFF756D7C);
}

/// User-selectable Kawaii Minimal color stories.
///
/// Every option retains the same information hierarchy and soft rounded
/// components; only the restrained canvas and focused candy accents change.
enum AppThemePreset {
  strawberryCream,
  grapeSoda,
  mintCloud,
  lemonCream,
}

extension AppThemePresetDetails on AppThemePreset {
  String get label => switch (this) {
        AppThemePreset.strawberryCream => '草莓奶油',
        AppThemePreset.grapeSoda => '葡萄苏打',
        AppThemePreset.mintCloud => '薄荷云朵',
        AppThemePreset.lemonCream => '奶油柠檬',
      };

  String get description => switch (this) {
        AppThemePreset.strawberryCream => '温柔莓果粉',
        AppThemePreset.grapeSoda => '轻盈葡萄紫',
        AppThemePreset.mintCloud => '清爽薄荷绿',
        AppThemePreset.lemonCream => '明亮奶油黄',
      };

  IconData get icon => switch (this) {
        AppThemePreset.strawberryCream => Icons.favorite_rounded,
        AppThemePreset.grapeSoda => Icons.auto_awesome_rounded,
        AppThemePreset.mintCloud => Icons.cloud_rounded,
        AppThemePreset.lemonCream => Icons.wb_sunny_rounded,
      };

  KawaiiPalette get palette => switch (this) {
        AppThemePreset.strawberryCream => KawaiiPalette.strawberryCream,
        AppThemePreset.grapeSoda => KawaiiPalette.grapeSoda,
        AppThemePreset.mintCloud => KawaiiPalette.mintCloud,
        AppThemePreset.lemonCream => KawaiiPalette.lemonCream,
      };

  Color get primary => palette.primary;
}

/// Theme extension for the non-Material canvas tones that make each palette
/// feel distinct while feature screens retain their own semantic colors.
@immutable
class KawaiiPalette extends ThemeExtension<KawaiiPalette> {
  const KawaiiPalette({
    required this.background,
    required this.backgroundBlush,
    required this.surfaceSoft,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.mint,
    required this.sunshine,
  });

  static const strawberryCream = KawaiiPalette(
    background: AppColors.background,
    backgroundBlush: AppColors.backgroundBlush,
    surfaceSoft: AppColors.surfaceSoft,
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    secondary: AppColors.secondary,
    mint: AppColors.mint,
    sunshine: AppColors.sunshine,
  );

  static const grapeSoda = KawaiiPalette(
    background: Color(0xFFFDFCFF),
    backgroundBlush: Color(0xFFF1ECFF),
    surfaceSoft: Color(0xFFF8F5FF),
    primary: Color(0xFF7B60E9),
    primaryDark: Color(0xFF6249C6),
    secondary: Color(0xFFFF75A8),
    mint: Color(0xFF55C7AC),
    sunshine: Color(0xFFF2C759),
  );

  static const mintCloud = KawaiiPalette(
    background: Color(0xFFF9FFFC),
    backgroundBlush: Color(0xFFEAF9F2),
    surfaceSoft: Color(0xFFF1FCF7),
    primary: Color(0xFF35AF8D),
    primaryDark: Color(0xFF278D70),
    secondary: Color(0xFF6E7CF4),
    mint: Color(0xFF35AF8D),
    sunshine: Color(0xFFF2C759),
  );

  static const lemonCream = KawaiiPalette(
    background: Color(0xFFFFFDF6),
    backgroundBlush: Color(0xFFFFF4D8),
    surfaceSoft: Color(0xFFFFFAE8),
    primary: Color(0xFFD7972F),
    primaryDark: Color(0xFFB57917),
    secondary: Color(0xFF8769E8),
    mint: Color(0xFF4CBD9F),
    sunshine: Color(0xFFD7972F),
  );

  final Color background;
  final Color backgroundBlush;
  final Color surfaceSoft;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color mint;
  final Color sunshine;

  @override
  KawaiiPalette copyWith({
    Color? background,
    Color? backgroundBlush,
    Color? surfaceSoft,
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? mint,
    Color? sunshine,
  }) {
    return KawaiiPalette(
      background: background ?? this.background,
      backgroundBlush: backgroundBlush ?? this.backgroundBlush,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      mint: mint ?? this.mint,
      sunshine: sunshine ?? this.sunshine,
    );
  }

  @override
  KawaiiPalette lerp(covariant KawaiiPalette? other, double t) {
    if (other == null) return this;
    return KawaiiPalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundBlush: Color.lerp(backgroundBlush, other.backgroundBlush, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      sunshine: Color.lerp(sunshine, other.sunshine, t)!,
    );
  }
}

extension KawaiiThemeContext on BuildContext {
  KawaiiPalette get kawaiiPalette {
    return Theme.of(this).extension<KawaiiPalette>() ??
        AppThemePreset.strawberryCream.palette;
  }
}

/// Builds the global Material 3 baseline for the selected Kawaii Minimal
/// palette. Business screens retain their content hierarchy and behavior.
ThemeData buildAppTheme([
  AppThemePreset preset = AppThemePreset.strawberryCream,
]) {
  final palette = preset.palette;
  final onPrimary = preset == AppThemePreset.lemonCream
      ? AppColors.textPrimary
      : Colors.white;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: palette.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: palette.primary,
    onPrimary: onPrimary,
    secondary: palette.secondary,
    onSecondary: Colors.white,
    tertiary: palette.mint,
    onTertiary: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: palette.surfaceSoft,
    outline: AppColors.divider,
    error: AppColors.risk,
    onError: Colors.white,
  );

  final baseTextTheme = ThemeData.light().textTheme;
  const cardRadius = BorderRadius.all(Radius.circular(24));
  const controlRadius = BorderRadius.all(Radius.circular(18));
  const fieldRadius = BorderRadius.all(Radius.circular(16));

  OutlineInputBorder fieldBorder(Color color) => OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: color),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    extensions: [palette],
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    dividerColor: AppColors.divider,
    splashFactory: InkSparkle.splashFactory,
    textTheme: baseTextTheme
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        )
        .copyWith(
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.45,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          titleMedium:
              baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.42),
          labelLarge:
              baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      border: fieldBorder(AppColors.divider),
      enabledBorder: fieldBorder(AppColors.divider),
      focusedBorder: fieldBorder(palette.primary),
      errorBorder: fieldBorder(AppColors.risk),
      focusedErrorBorder: fieldBorder(AppColors.risk),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: palette.primary,
        foregroundColor: onPrimary,
        shape: const RoundedRectangleBorder(borderRadius: controlRadius),
        animationDuration: const Duration(milliseconds: 240),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        foregroundColor: palette.primaryDark,
        side: BorderSide(color: palette.primary, width: 1.2),
        shape: const RoundedRectangleBorder(borderRadius: controlRadius),
        animationDuration: const Duration(milliseconds: 240),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: palette.primaryDark,
        shape: const RoundedRectangleBorder(borderRadius: controlRadius),
        animationDuration: const Duration(milliseconds: 240),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.primary,
      foregroundColor: onPrimary,
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: controlRadius),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.surfaceSoft,
      selectedColor: palette.primary.withValues(alpha: 0.16),
      disabledColor: AppColors.divider,
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      secondaryLabelStyle: TextStyle(
        color: palette.primaryDark,
        fontWeight: FontWeight.w700,
      ),
      side: const BorderSide(color: AppColors.divider),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: const RoundedRectangleBorder(borderRadius: controlRadius),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      iconColor: palette.secondary,
      textColor: AppColors.textPrimary,
      shape: const RoundedRectangleBorder(borderRadius: controlRadius),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: controlRadius),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: Colors.transparent,
      indicatorColor: palette.primary.withValues(alpha: 0.16),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? palette.primaryDark : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? palette.primary : AppColors.textSecondary,
          size: selected ? 25 : 23,
        );
      }),
    ),
  );
}
