# Review / Runtime Test Results

Task: android-phone-runtime-test
Date: 2026-07-04 03:16:32 +08:00 (Asia/Shanghai local machine time)

## Scope

Continue Android real-device testing after the phone was connected and USB debugging was enabled. No app source code was changed.

## Device detected

- Flutter device id: `f17804b`
- Model shown by Flutter/ADB: `24031PN0DC`
- Platform: Android 16 / API 36 / android-arm64

## Commands run

| Command | Working directory | Result |
|---|---|---|
| `flutter devices` | `found-house-app/` | Passed; detected Android phone `24031PN0DC (mobile) • f17804b • android-arm64 • Android 16 (API 36)` plus desktop/web devices. |
| `adb devices -l` | `found-house-app/` | Passed; device state is `device`, product `aurorapro`, model `24031PN0DC`, device `aurora`. |
| `flutter build apk --debug` | `found-house-app/` | Passed; built `build\app\outputs\flutter-apk\app-debug.apk`. |
| `adb -s f17804b install -r -d <app-debug.apk>` | `found-house-app/` | Passed; `Performing Streamed Install` then `Success`. |
| `adb -s f17804b shell monkey -p com.yourcompany.found_house_app -c android.intent.category.LAUNCHER 1` | `found-house-app/` | Passed; launch event injected and app process started. |
| `adb -s f17804b shell pidof com.yourcompany.found_house_app` | `found-house-app/` | Passed; app process id observed: `30789`. |
| `adb -s f17804b shell dumpsys activity activities` | `found-house-app/` | Passed; `topResumedActivity` / `ResumedActivity` is `com.yourcompany.found_house_app/.MainActivity`. |
| `adb -s f17804b shell dumpsys window` | `found-house-app/` | Passed; `mCurrentFocus` and `mFocusedApp` are `com.yourcompany.found_house_app/com.yourcompany.found_house_app.MainActivity`. |
| `adb -s f17804b shell uiautomator dump` | `found-house-app/` | Passed; hierarchy contains package `com.yourcompany.found_house_app` and visible semantics such as `扫楼地图`, `本地房源坐标工作台`, `暂无带坐标的房源`, and the 4 bottom tabs. |
| App PID logcat crash scan | project root | Passed; no `FATAL EXCEPTION`, `AndroidRuntime`, `CRASH`, unhandled Dart error, `NoSuchMethodError`, or assertion-failure pattern found in `runtime-logcat-app-pid.txt`. |

## Artifacts saved

- `runtime-logcat-app-pid.txt` — app-process logcat captured from the debug launch.
- `runtime-logcat-filtered.txt` — filtered package/crash logcat snippet.
- `window.xml` — UIAutomator hierarchy dump.
- `found_house_smoke.png` — phone screenshot after launch.

## Notes

- `adb shell input keyevent KEYCODE_WAKEUP` was rejected by the phone OS with an `INJECT_EVENTS` security exception, but this did not block the test. `monkey` successfully launched the app, and Android reported the app Activity as resumed/focused.
- Observed package/application id is still the Flutter template placeholder `com.yourcompany.found_house_app`; replace it before real release/distribution.
- This is a runtime smoke test: build, install, launch, Activity focus, UI hierarchy, and crash-pattern log scan. It does not replace manual feature-by-feature QA on the phone.
