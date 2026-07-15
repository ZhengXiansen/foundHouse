# 实施计划

## 范围

- Flutter Android 正式构建配置：包名、应用名称、release 签名、release 权限、版本号、MainActivity 包路径、launcher icon、构建验证。
- BFF 地址未知：不伪造生产 BFF；保持构建可用，并在报告中明确联网地图/BFF能力需要后续部署配置。

## 步骤

1. 写 release readiness 检查脚本，先在当前占位配置上跑出 RED。
2. 生成本机 release upload keystore，并创建 `found-house-app/android/key.properties`（本地密钥文件不提交）。
3. 修改 `android/app/build.gradle.kts`：
   - namespace/applicationId = `com.zheng.foundhouse`
   - release signingConfig 改用 `release`
   - 从 `android/key.properties` 读取 keystore
4. 修改 `MainActivity.kt` package 并移动到 `kotlin/com/zheng/foundhouse/`。
5. 修改 main `AndroidManifest.xml`：
   - 增加 release INTERNET 权限
   - label 改为 `扫楼侠`
6. 修改 `pubspec.yaml` version 为 `1.0.0+1`。
7. 生成非默认 launcher icon（简单本地图标）。
8. 跑检查脚本 GREEN、`flutter analyze`、`flutter test`、`flutter build apk --release`，可行则同时 `flutter build appbundle --release`。
9. 如设备在线，安装 release APK 并启动 smoke test，扫 logcat fatal/ANR/Dart error。
10. 审查并归档任务。

## 验收标准

- 检查脚本验证：包名、App 名、release INTERNET、release signing、version、MainActivity package 均符合预期。
- `flutter analyze` exit 0。
- `flutter test` exit 0。
- `flutter build apk --release` exit 0，产物存在。
- 如果执行 AAB：`flutter build appbundle --release` exit 0，产物存在。
- 如真机可用：release APK 可安装并启动，无 fatal crash/ANR/Dart error 关键日志。
