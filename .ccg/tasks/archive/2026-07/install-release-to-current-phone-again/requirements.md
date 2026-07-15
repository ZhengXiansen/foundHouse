# 再次安装正式版到当前连接的 Android 手机

## 需求

用户更换手机后，要求将当前正式版 APK 再安装一次到当前通过 ADB 连接的手机。

## 策略

- 使用现有 release APK：`found-house-app/build/app/outputs/flutter-apk/app-release.apk`。
- 使用 `adb install -r` 覆盖安装，不主动卸载、不主动清空数据。
- 安装后验证 package metadata、启动 Activity 与首页 UI dump。
