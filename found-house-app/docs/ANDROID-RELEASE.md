# Android Release Build

当前正式包配置：

- Application ID / namespace：`com.zheng.foundhouse`
- App 名称：`扫楼侠`
- 版本：`1.0.0+1`
- Release 签名：读取 `android/key.properties`

## 本机签名文件

`android/key.properties` 是本机密钥配置文件，已被 `.gitignore` 忽略，不要提交到仓库。
当前 keystore 生成在用户目录：

```text
C:/Users/Mr.Zheng/.android/found_house_upload_keystore.jks
```

请务必离线备份 keystore 和 `android/key.properties`。如果后续用同一个 applicationId 发布更新包，签名丢失会导致无法平滑升级。

## 无 BFF 地址时

如果没有地图 BFF 地址，可以直接构建离线可用 release 包；App 不会默认访问 `127.0.0.1`。地图刷新/POI/通勤会返回“地图服务未配置”的业务错误，本地记录、列表、对比等功能仍可使用。

后续部署 BFF 后，用构建参数注入：

```powershell
flutter build apk --release `
  --dart-define=FOUND_HOUSE_BFF_BASE_URL=https://your-bff.example.com `
  --obfuscate `
  --split-debug-info=build/symbols/android
```

## 构建 APK

```powershell
flutter build apk --release `
  --obfuscate `
  --split-debug-info=build/symbols/android
```

产物：

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 构建 AAB

```powershell
flutter build appbundle --release `
  --obfuscate `
  --split-debug-info=build/symbols/android
```

产物：

```text
build/app/outputs/bundle/release/app-release.aab
```

## 发布前检查

```powershell
flutter analyze
flutter test
flutter build apk --release --obfuscate --split-debug-info=build/symbols/android
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
```

如果有真机在线，再安装 APK 做 release 烟测：

```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell monkey -p com.zheng.foundhouse -c android.intent.category.LAUNCHER 1
adb logcat -d | Select-String -Pattern "FATAL EXCEPTION|AndroidRuntime|ANR|Dart Error"
```
