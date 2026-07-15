# Review / Verification

Task: fix `flutter create` generated `test/widget_test.dart` referencing missing `MyApp`, then verify Android build/test path.

## Local verification on 2026-07-04 Asia/Shanghai

Flutter app (`found-house-app/`):

- `flutter pub get` — passed.
- `flutter analyze` — passed: `No issues found!`.
- `flutter test` — passed: `123` tests passed.
- `flutter build apk --debug --dart-define=FOUND_HOUSE_BFF_BASE_URL=http://10.0.2.2:3000` — passed.
  - Artifact: `build/app/outputs/flutter-apk/app-debug.apk`
  - Size: `168,013,470` bytes.
- `flutter build apk --release --dart-define=FOUND_HOUSE_BFF_BASE_URL=http://10.0.2.2:3000` — passed.
  - Artifact: `build/app/outputs/flutter-apk/app-release.apk`
  - Size: `66,574,934` bytes.

BFF (`found-house-bff/`):

- `node --version` — `v24.14.0`.
- `npm --version` — `11.9.0`.
- `npm run build` — passed.
- `npm test` — passed: `3` test files / `23` tests.
- `npm run lint` — passed.

## Notes

- Generated default Flutter `test/widget_test.dart` was removed because the app root widget is `FoundHouseApp`, not `MyApp`, and existing smoke tests cover app startup.
- Android platform files now exist under `found-house-app/android/`.
- Current Android package id / namespace is still placeholder: `com.yourcompany.found_house_app`; replace before any real release.
- Current release build uses the Flutter template debug signing config. Configure a real keystore before distributing outside local/internal smoke testing.
- BFF map APIs require `AMAP_WEBSERVICE_KEY` at runtime. Optional runtime env: `REDIS_URL`, `DATABASE_URL`, `PORT`, `HOST`, `RATE_LIMIT_PER_MINUTE`, `RATE_LIMIT_GLOBAL_PER_MINUTE`, `LOG_LEVEL`.
- Repo-local workarounds currently present: Tencent Gradle distribution mirror and `kotlin.incremental=false` for Windows cross-drive Kotlin cache issue. Prefer documenting or moving machine-specific settings to local/user config later.

## External review

- Antigravity review attempted but failed because `agy` was not available in PATH.
- Claude review returned no Critical findings. Warnings were limited to portability of the Tencent Gradle mirror and repo-wide `kotlin.incremental=false`, plus release metadata/signing still requiring manual configuration.
