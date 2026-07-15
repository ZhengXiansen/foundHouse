# 覆盖重新安装正式版到当前 Android 真机 — 结果记录

## 处理方式

按安全默认方式执行：`adb install -r` 覆盖重新安装，不主动卸载、不主动清空 App 数据。

## 设备

- Device ID：`f17804b`
- 型号：`24031PN0DC`
- ABI：`android-arm64`
- 系统：Android 16 / API 36

## APK 产物

```text
found-house-app/build/app/outputs/flutter-apk/app-release.apk
size: 63,207,498 bytes
lastWriteTime: 2026-07-07 03:57:02
```

## 重新安装

执行命令：

```powershell
adb -s f17804b install -r build/app/outputs/flutter-apk/app-release.apk
```

结果：

```text
Performing Streamed Install
Success
REINSTALL_EXIT_CODE=0
```

安装后包信息：

```text
package:com.zheng.foundhouse
versionCode=1
versionName=1.0.0
firstInstallTime=2026-07-07 04:16:34
lastUpdateTime=2026-07-07 04:16:34
```

## 启动烟测

首次启动：

```text
LAUNCH_EXIT_CODE=0
mCurrentFocus=Window{... com.zheng.foundhouse/com.zheng.foundhouse.MainActivity}
pidof com.zheng.foundhouse => 28503
```

force-stop 后重启：

```text
RELAUNCH_EXIT_CODE=0
mCurrentFocus=Window{... com.zheng.foundhouse/com.zheng.foundhouse.MainActivity}
pidof com.zheng.foundhouse => 21812
```

## 崩溃 / ANR 扫描

```text
No targeted crash/ANR patterns found for com.zheng.foundhouse.
No targeted crash/ANR patterns found after relaunch.
```

## 结论

正式版 APK 已覆盖重新安装到当前连接手机 `f17804b / 24031PN0DC`，并完成启动与重启烟测。验证范围为覆盖重新安装 + 启动烟测；如需“清数据全新安装”，需要另行执行卸载后安装。

## Spec evolution

无新增规范沉淀。
