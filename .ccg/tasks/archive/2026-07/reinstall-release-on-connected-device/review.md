# Android 正式版真机安装报告

## Request

构建新鲜的 Android release APK，并安装到已连接真机，不改动产品代码。

## Device

- Serial: `e4e6ad3a`
- Model: `22081212C`
- State: `device`

## Artifact

- Path: `found-house-app/build/app/outputs/flutter-apk/app-release.apk`
- Build command: `flutter build apk --release --obfuscate --split-debug-info=build/symbols/android`
- Build result: succeeded on July 10, 2026.
- Size: `63,799,062` bytes.
- SHA-256: `349B7C32E50C4DBAF709C1C5B754E4D2D5C82CF5BEDCC8740485BF1E761C88E6`.

## Signature verification

`apksigner verify --verbose --print-certs` succeeded:

- APK Signature Scheme v2: verified.
- Signer: `CN=Zheng FoundHouse, OU=Mobile, O=Zheng, L=Unknown, ST=Unknown, C=CN`.
- Signer certificate SHA-256: `1f7fea650ec774ba2f1d482a4fa55c15d323696c9ff276c56662733e70af125a`.

## Install and smoke test

- Safe installation command: `adb -s e4e6ad3a install -r build/app/outputs/flutter-apk/app-release.apk`.
- Result: `Success`; no uninstall or data-removing fallback was necessary.
- Package metadata after installation:
  - package: `com.zheng.foundhouse`
  - versionCode: `1`
  - versionName: `1.0.0`
  - lastUpdateTime: `2026-07-10 05:38:39`
- Launcher smoke test: `adb shell monkey -p com.zheng.foundhouse -c android.intent.category.LAUNCHER 1` successfully started `com.zheng.foundhouse/.MainActivity`.
- UI hierarchy after launch contained the `首页` content description and the four bottom tabs (`首页` / `房源` / `对比` / `我的`).
- App-process logcat scan found no `FATAL EXCEPTION`, `AndroidRuntime`, `ANR`, or `Dart Error` entries.

## Review note

No application code changed; this task only built, verified, installed, and smoke-tested the existing release configuration. The CCG external wrapper is still unavailable at `C:\Users\Mr.Zheng\.claude\bin\codeagent-wrapper`, so no external model review is claimed.

## Version-control limitation

The workspace root is not a Git repository, so an archive commit cannot be made. The task is archived for continuity.
