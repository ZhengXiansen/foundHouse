import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kawaii_widgets.dart';
import 'router.dart';
import 'theme.dart';
import 'theme_preferences.dart';

/// Root application composition. Routing and feature providers remain
/// unchanged; only the presentation palette follows the saved user preference.
class FoundHouseApp extends ConsumerWidget {
  const FoundHouseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themePreset = ref.watch(appThemeControllerProvider);

    return MaterialApp.router(
      title: '扫楼助手',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(themePreset),
      themeMode: ThemeMode.light,
      builder: (context, child) => KawaiiBackdrop(
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: router,
    );
  }
}
