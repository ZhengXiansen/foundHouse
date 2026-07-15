# Review

## Scope

Review Android release configuration and release artifact generation for the Flutter app.

## External model review status

- Required CCG wrapper was not available: `C:/Users/Mr.Zheng/.claude/bin/codeagent-wrapper` missing.
- `agy` / antigravity command was not available in PATH.
- Direct `claude -p` read-only analysis attempt timed out before producing output.

Because the mandated external reviewers were unavailable, this review is a local self-review backed by concrete build/test/signing evidence.

## Strengths

- Release no longer uses placeholder `com.yourcompany.found_house_app`.
- Release no longer uses debug signing; APK is verified with `apksigner` and signed by the generated upload key.
- No-BFF case is handled explicitly via `OfflineMapApiClient`; release packages no longer default to localhost.
- TDD evidence exists for the no-BFF provider behavior and the release config readiness check.
- APK and AAB were both generated with obfuscation and split debug info.
- Build artifacts were inspected with `aapt`, confirming package id, label, version, permission, and launchable activity.

## Issues

### Critical

None found in local review.

### Important

1. Release APK was not installed on a physical Android device in this pass because no Android device was visible to ADB.
   - Evidence: `adb-devices.txt`, `flutter-devices.txt`.
   - Impact: Build/signing is verified, but release runtime smoke test remains pending.
   - Fix: Reconnect phone and run the commands listed in `release-report.md`.

2. BFF is still not deployed/configured.
   - Impact: Local-first functionality works, but map/POI/commute refresh will report `MAP_BFF_NOT_CONFIGURED` until a BFF URL is supplied.
   - Fix: Deploy BFF, then rebuild with `--dart-define=FOUND_HOUSE_BFF_BASE_URL=https://...` and rerun map tests.

3. Release key backup is now operationally critical.
   - Impact: Losing `C:/Users/Mr.Zheng/.android/found_house_upload_keystore.jks` and `android/key.properties` can block future upgrades for the same package id.
   - Fix: Store both in a secure backup/password manager; do not commit them.

### Minor

1. Build output includes dependency update notices and an ELF DWARF warning from Flutter/Gradle output, but release builds exited 0.
2. Launcher icon is a simple generated placeholder branded icon, not a designer-provided production icon.

## Assessment

Ready for local/internal release package use with caveats: APK/AAB build, signing, package metadata, tests, and release config checks pass. Store publication or production map functionality still needs release-device smoke testing, BFF deployment/configuration, and final visual/icon polish.
