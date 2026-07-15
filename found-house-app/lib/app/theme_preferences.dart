import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/crypto/crypto_service.dart';
import 'theme.dart';

/// Isolated persistence for presentation-only preferences. This deliberately
/// does not reuse the business PreferenceProfile or its Drift table.
class ThemePreferenceStore {
  ThemePreferenceStore(this._keyStore);

  static const storageKey = 'found_house_kawaii_theme_v1';

  final KeyStore _keyStore;

  Future<AppThemePreset> load() async {
    final rawValue = await _keyStore.read(storageKey);
    for (final preset in AppThemePreset.values) {
      if (preset.name == rawValue) return preset;
    }
    return AppThemePreset.strawberryCream;
  }

  Future<void> save(AppThemePreset preset) {
    return _keyStore.write(storageKey, preset.name);
  }
}

final themePreferenceStoreProvider = Provider<ThemePreferenceStore>((ref) {
  return ThemePreferenceStore(SecureStorageKeyStore());
});

/// Applies a choice immediately, then saves it for the next application run.
class AppThemeController extends StateNotifier<AppThemePreset> {
  AppThemeController(this._store) : super(AppThemePreset.strawberryCream);

  final ThemePreferenceStore _store;

  Future<void> restore() async {
    final restoredPreset = await _store.load();
    if (mounted) state = restoredPreset;
  }

  Future<void> select(AppThemePreset preset) async {
    if (state != preset) state = preset;
    await _store.save(preset);
  }
}

final appThemeControllerProvider =
    StateNotifierProvider<AppThemeController, AppThemePreset>((ref) {
  final controller =
      AppThemeController(ref.watch(themePreferenceStoreProvider));
  controller.restore();
  return controller;
});
