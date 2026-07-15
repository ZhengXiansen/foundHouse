# Requirements — Android device test after authorization

## Goal

Complete the remaining Android real-device verification for the manual village scanning flow.

## Current blocker

`adb devices -l` reports device `e4e6ad3a` as `unauthorized`, and `flutter devices` does not expose it as a supported Android target.

## Required evidence to complete

After the user authorizes USB debugging on the phone:

```powershell
cd D:\dev\code\foundHouse\found-house-app
adb devices -l
flutter devices
flutter test -d e4e6ad3a integration_test/full_device_flow_test.dart
```

Completion requires the integration test to execute on the Android device and pass, or a concrete device/runtime failure to be captured and fixed.
