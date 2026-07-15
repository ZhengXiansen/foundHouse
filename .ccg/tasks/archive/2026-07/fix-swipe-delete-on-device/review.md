# Review — fix-swipe-delete-on-device

## Summary

Root cause: the delete `Dismissible` widgets for village/building/house cards only allowed `DismissDirection.startToEnd`. On a left-to-right UI this means only left-to-right swipes opened the delete confirmation. Real-device users commonly swipe right-to-left for destructive list actions, so the feature looked like it was not implemented.

Fix: all village/building/house delete cards now support `DismissDirection.horizontal`, with a mirrored `secondaryBackground` for end-to-start swipes. Existing safety behavior is preserved: `confirmDismiss` performs confirmation/deletion and returns `false`; the row disappears from the Drift watch stream refresh instead of being removed twice by `Dismissible` and the stream.

## Files reviewed

- `found-house-app/lib/features/common/delete_confirmation.dart`
- `found-house-app/lib/features/scan/village_home_page.dart`
- `found-house-app/lib/features/scan/village_detail_page.dart`
- `found-house-app/lib/features/house/house_list_page.dart`
- `found-house-app/test/features/scan_map_page_test.dart`
- `found-house-app/integration_test/swipe_delete_device_test.dart`
- `found-house-app/docs/qa/v1.2-test-cases.md`
- `found-house-app/docs/qa/v1.2-release-manual-checklist.md`
- `.ccg/spec/guides/index.md`

## TDD / regression evidence

| Stage | Command / action | Result |
| --- | --- | --- |
| RED | Temporarily reverted the three app Dismissibles to `DismissDirection.startToEnd` and removed `secondaryBackground`, then ran `flutter test test/features/scan_map_page_test.dart --plain-name "村、楼栋和房源卡片也支持从右向左滑动确认删除" --reporter expanded` | Failed as expected: `Bad state: No element` at `_swipeAndConfirmDelete`, because the right-to-left swipe did not open the delete dialog. Exit code 1. Implementation files restored immediately after the intentional RED check. |
| GREEN | `flutter test test/features/scan_map_page_test.dart --plain-name "村、楼栋和房源卡片也支持从右向左滑动确认删除" --reporter expanded` | Passed: `00:01 +1: All tests passed!` |

## External model review

| Model | Status | Notes |
| --- | --- | --- |
| antigravity analyzer | Failed | `agy command not found in PATH`; see `analysis-antigravity.err`. |
| Claude analyzer | Completed | Identified single-direction `startToEnd` as the most likely true-device gap and recommended horizontal support plus device integration coverage. See `analysis-claude.md`. |
| antigravity reviewer | Failed | `agy command not found in PATH`; see `review-antigravity.err`. |
| Claude reviewer | Completed | No Critical findings. Warning about decorative background semantics was fixed with `ExcludeSemantics`; stale docs headings were reworded from “右划删除” to “滑动删除”. Accessibility fallback for swipe-only delete remains a recommended follow-up, not a blocker for this bugfix. See `review-claude.md`. |

## Fresh verification

| Check | Result |
| --- | --- |
| `flutter devices` | Detected Android device `22081212C` / `e4e6ad3a`, Android 15 API 35. |
| `flutter analyze` | Passed: `No issues found! (ran in 2.8s)`. |
| `flutter test --reporter expanded` | Passed: `00:10 +159: All tests passed!`. |
| `flutter test -d e4e6ad3a integration_test/swipe_delete_device_test.dart --reporter expanded` | First attempt hit expected device install state noise (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`, `INSTALL_FAILED_USER_RESTRICTED`) because a release/debug package transition was present. After manual `adb install -r build\app\outputs\flutter-apk\app-debug.apk`, rerun passed: `00:13 +1: All tests passed!`. |
| `flutter build apk --release` | Passed: built `build\app\outputs\flutter-apk\app-release.apk` (64.6 MB). |
| `adb -s e4e6ad3a install -r build\app\outputs\flutter-apk\app-release.apk` | First retry was canceled by the device (`INSTALL_FAILED_USER_RESTRICTED`); rerun succeeded: `Success`. |
| Release package evidence | `versionCode=1`, `versionName=1.0.0`, `lastUpdateTime=2026-07-07 22:31:44`, `installerPackageName=null`. |
| Release launch smoke | `monkey` launched `com.zheng.foundhouse`; `dumpsys activity` showed `topResumedActivity=... com.zheng.foundhouse/.MainActivity`. |
| UI smoke | `uiautomator dump` on the release app showed homepage semantics including `首页`, `新增村`, empty-state copy, and bottom tabs `首页/房源/对比/我的`. |

## Findings

### Critical

None.

### Warning

- Delete remains swipe-only. This is pre-existing and not caused by the current fix, but TalkBack users may still need a non-gesture delete affordance (for example a menu action). Recommended follow-up ticket.

### Info

- Confirmed-delete rows may briefly snap back before disappearing because `confirmDismiss` returns `false` and the stream refresh removes the item. This is intentional to avoid `Dismissible` double-removal assertions.
- `.ccg/spec/guides/index.md` was updated with a reusable guideline for mobile destructive swipe gestures and true-device testing.

## Decision

Approved. The bug is fixed, regression-covered, verified on the connected Android device, and the release APK was rebuilt/reinstalled after the debug integration run.

## Continuation audit — 2026-07-07 22:45 +08:00

Fresh current-state audit after goal continuation:

| Check | Result |
| --- | --- |
| Implementation grep | Village, building, village-detail house, and house-list cards all use `DismissDirection.horizontal` and `secondaryBackground: swipeDeleteBackground(fromEnd: true)`. |
| `flutter analyze` | PASS: `No issues found! (ran in 2.7s)`. |
| Targeted right-to-left regression | PASS: `flutter test test/features/scan_map_page_test.dart --plain-name "村、楼栋和房源卡片也支持从右向左滑动确认删除" --reporter expanded` -> `00:01 +1: All tests passed!`. |
| Full unit/widget suite | First rerun had one unrelated `export_service_test` timeout; immediate isolated rerun of that test passed, and full rerun passed: `00:13 +159: All tests passed!`. |
| Android true-device integration | PASS on `22081212C / e4e6ad3a`: `flutter test -d e4e6ad3a integration_test/swipe_delete_device_test.dart --reporter expanded` -> `00:13 +1: All tests passed!`. |
| Release build | PASS: `flutter build apk --release` built `build\app\outputs\flutter-apk\app-release.apk` (64.6MB). |
| Post-integration release reinstall | Attempted after the debug integration run, but the phone rejected install with `INSTALL_FAILED_USER_RESTRICTED`. This affects current device release-install state only; the objective's true-device swipe-delete verification already passed via the integration run. |
