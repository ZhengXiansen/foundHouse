# 安装正式版到另一台 Android 真机 — 结果记录

## 设备

- Device ID：`f17804b`
- 型号：`24031PN0DC`
- 产品：`aurorapro / aurora`
- ABI：`android-arm64`
- 系统：Android 16 / API 36

## APK 产物

使用已有 release APK：

```text
found-house-app/build/app/outputs/flutter-apk/app-release.apk
size: 63,207,498 bytes
lastWriteTime: 2026-07-07 03:57:02
```

## 安装前包信息

```text
package:com.zheng.foundhouse
versionCode=1
versionName=1.0.0
firstInstallTime=2026-07-04 06:49:35
lastUpdateTime=2026-07-04 07:21:34
```

## 覆盖安装

执行命令：

```powershell
adb -s f17804b install -r build/app/outputs/flutter-apk/app-release.apk
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
firstInstallTime=2026-07-04 06:49:35
lastUpdateTime=2026-07-07 04:10:23
```

## 启动烟测

首次启动：

```powershell
adb -s f17804b shell monkey -p com.zheng.foundhouse -c android.intent.category.LAUNCHER 1
```

结果：

```text
Events injected: 1
LAUNCH_EXIT_CODE=0
mCurrentFocus=Window{... com.zheng.foundhouse/com.zheng.foundhouse.MainActivity}
pidof com.zheng.foundhouse => 1699
```

force-stop 后重启：

```text
RELAUNCH_EXIT_CODE=0
mCurrentFocus=Window{... com.zheng.foundhouse/com.zheng.foundhouse.MainActivity}
pidof com.zheng.foundhouse => 17719
```

## 崩溃 / ANR 扫描

```text
No targeted crash/ANR patterns found for com.zheng.foundhouse.
No targeted crash/ANR patterns found after relaunch.
```

## 结论

release APK 已覆盖安装到 `f17804b / 24031PN0DC`，并完成启动与重启烟测。验证范围为安装 + 启动烟测；完整发布验收仍需执行人工检查清单：

```text
found-house-app/docs/qa/v1.1-release-manual-checklist.md
```

## Spec evolution

无新增规范沉淀。
