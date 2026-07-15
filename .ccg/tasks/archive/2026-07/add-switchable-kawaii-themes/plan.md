# Implementation Plan

1. Add an app-owned theme preference store/controller based on the existing injectable KeyStore abstraction, isolated from business PreferenceProfile and Drift.
2. Define four Kawaii palette presets in the visual system and make `buildAppTheme` plus `KawaiiBackdrop` depend on the selected preset.
3. Have the app root watch the theme controller so all routed screens rebuild immediately when a user changes themes.
4. Turn the settings dashboard into a ConsumerWidget and add a compact, single-select theme card without changing the existing routes or settings entries.
5. Write tests first for store round trips, invalid-value fallback, palette selection, app theme behavior, and settings UI selection.
6. Verify formatter, analyzer, full tests, then run the Android screenshot flow while selecting multiple themes.

## Planned source scope
- `lib/app/theme.dart`
- `lib/app/kawaii_widgets.dart`
- `lib/app/theme_preferences.dart` (new)
- `lib/app/app.dart`
- `lib/features/settings/settings_page.dart`
- `test/app/theme_preference_test.dart` (new)
- `test/app/kawaii_theme_test.dart`
- `test/app_smoke_test.dart`
- `integration_test/screenshot_all_pages_test.dart` (only if screenshot flow needs a dedicated theme capture)

## Non-goals
- No database migration and no change to the business preference profile.
- No route, repository, score, filter, privacy, or OSS behavior changes.
