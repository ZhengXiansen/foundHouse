# 安装正式版到 Android 真机 — 结果记录

## 设备

- Device ID：`e4e6ad3a`
- 型号：`22081212C`
- ABI：`android-arm64`
- 系统：Android 15 / API 35

## 构建

执行命令：

```powershell
flutter build apk --release --obfuscate --split-debug-info=build/symbols/android
```

结果：`EXIT_CODE=0`

产物：

```text
found-house-app/build/app/outputs/flutter-apk/app-release.apk
size: 63,207,498 bytes
```

构建输出中有 Flutter/NDK 警告，但 Gradle release 构建成功并产出 APK。

## 安装

执行命令：

```powershell
adb -s e4e6ad3a install -r build/app/outputs/flutter-apk/app-release.apk
```

结果：

```text
Performing Streamed Install
Success
INSTALL_EXIT_CODE=0
```

安装后包信息：

```text
package:com.zheng.foundhouse
versionCode=1
versionName=1.0.0
lastUpdateTime=2026-07-07 03:57:48
firstInstallTime=2026-07-07 03:57:48
```

## 启动烟测

执行命令：

```powershell
adb -s e4e6ad3a shell monkey -p com.zheng.foundhouse -c android.intent.category.LAUNCHER 1
```

结果：

```text
Events injected: 1
LAUNCH_EXIT_CODE=0
mCurrentFocus=... com.zheng.foundhouse/com.zheng.foundhouse.MainActivity
pidof com.zheng.foundhouse => 25017
```

随后执行 force-stop 后重启烟测：

```text
RELAUNCH_EXIT_CODE=0
mCurrentFocus=... com.zheng.foundhouse/com.zheng.foundhouse.MainActivity
pidof com.zheng.foundhouse => 25823
```

## 崩溃 / ANR 扫描

精准扫描应用相关崩溃 / ANR：

```text
No targeted crash/ANR patterns found for com.zheng.foundhouse.
No targeted crash/ANR patterns found after relaunch.
```

## 结论

release APK 已成功构建、安装到真机并可启动。当前验证范围是安装 + 冷启动烟测，不等同于完整人工发布验收；完整发布前人工检查请继续执行：

```text
found-house-app/docs/qa/v1.1-release-manual-checklist.md
```

## Spec evolution

无新增规范沉淀。
