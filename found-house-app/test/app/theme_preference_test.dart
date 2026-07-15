import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_house_app/app/theme.dart';
import 'package:found_house_app/app/theme_preferences.dart';
import 'package:found_house_app/data/crypto/crypto_service.dart';
import 'package:found_house_app/features/settings/settings_page.dart';

class _MemoryKeyStore implements KeyStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class _ThemeSettingsHost extends ConsumerWidget {
  const _ThemeSettingsHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(appThemeControllerProvider);
    return MaterialApp(
      theme: buildAppTheme(preset),
      home: const SettingsPage(),
    );
  }
}

void main() {
  group('ThemePreferenceStore', () {
    test(
        'uses Strawberry Cream on first launch and falls back from invalid data',
        () async {
      final keyStore = _MemoryKeyStore();
      final store = ThemePreferenceStore(keyStore);

      expect(await store.load(), AppThemePreset.strawberryCream);

      await keyStore.write(ThemePreferenceStore.storageKey, 'not-a-theme');
      expect(await store.load(), AppThemePreset.strawberryCream);
    });

    test('round-trips the selected theme without touching the business profile',
        () async {
      final keyStore = _MemoryKeyStore();
      final store = ThemePreferenceStore(keyStore);

      await store.save(AppThemePreset.mintCloud);

      expect(await store.load(), AppThemePreset.mintCloud);
      expect(
        keyStore.values,
        containsPair(ThemePreferenceStore.storageKey, 'mintCloud'),
      );
    });
  });

  test('controller applies the new theme immediately and persists it',
      () async {
    final keyStore = _MemoryKeyStore();
    final store = ThemePreferenceStore(keyStore);
    final controller = AppThemeController(store);

    expect(controller.state, AppThemePreset.strawberryCream);

    await controller.select(AppThemePreset.grapeSoda);

    expect(controller.state, AppThemePreset.grapeSoda);
    expect(await store.load(), AppThemePreset.grapeSoda);
  });

  test(
      'each theme palette changes the global action color but keeps rounded UI',
      () {
    final strawberry = buildAppTheme(AppThemePreset.strawberryCream);
    final mint = buildAppTheme(AppThemePreset.mintCloud);
    final mintCard = mint.cardTheme.shape! as RoundedRectangleBorder;

    expect(strawberry.colorScheme.primary, isNot(mint.colorScheme.primary));
    expect(mint.colorScheme.primary, AppThemePreset.mintCloud.primary);
    expect(
      mintCard.borderRadius,
      const BorderRadius.all(Radius.circular(24)),
    );
  });
  testWidgets('settings selection changes the active palette and persists it',
      (tester) async {
    final store = ThemePreferenceStore(_MemoryKeyStore());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [themePreferenceStoreProvider.overrideWithValue(store)],
        child: const _ThemeSettingsHost(),
      ),
    );
    await tester.pump();

    expect(find.text('界面主题'), findsOneWidget);
    expect(find.text('草莓奶油'), findsOneWidget);
    expect(find.text('薄荷云朵'), findsOneWidget);

    await tester.tap(find.text('薄荷云朵'));
    await tester.pumpAndSettle();

    final settingsContext = tester.element(find.byType(SettingsPage));
    expect(
      Theme.of(settingsContext).colorScheme.primary,
      AppThemePreset.mintCloud.primary,
    );
    expect(await store.load(), AppThemePreset.mintCloud);
  });
}
