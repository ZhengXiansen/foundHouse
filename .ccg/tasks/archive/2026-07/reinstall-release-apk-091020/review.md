# Verification

- `adb -s e4e6ad3a install -r found-house-app/build/app/outputs/flutter-apk/app-release.apk` exited 0 with `Success`.
- `adb -s e4e6ad3a shell dumpsys package com.zheng.foundhouse` showed `versionCode=1`, `versionName=1.0.0`, `lastUpdateTime=2026-07-08 09:10:44`.
- `adb -s e4e6ad3a shell monkey -p com.zheng.foundhouse -c android.intent.category.LAUNCHER 1` injected 1 launch event.
- `adb -s e4e6ad3a shell dumpsys window` showed current focus `com.zheng.foundhouse/com.zheng.foundhouse.MainActivity`.

No code/spec changes were required.
