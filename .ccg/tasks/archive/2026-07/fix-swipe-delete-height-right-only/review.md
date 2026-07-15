# Review — fix-swipe-delete-height-right-only

## Review mode

- CCG requested dual-model review for M/medium UI behavior changes.
- External wrapper checked at $wrapper: exists = False.
- Because the wrapper is unavailable in this environment and the user did not explicitly request spawning sub-agents, this review is a local/manual review plus fresh automated/device verification.

## Scope reviewed

Relevant current files inspected:

- lib/features/common/delete_confirmation.dart
- lib/features/scan/village_home_page.dart
- lib/features/scan/village_detail_page.dart
- lib/features/house/house_list_page.dart
- 	est/features/scan_map_page_test.dart
- integration_test/swipe_delete_device_test.dart
- .ccg/spec/guides/index.md
- docs/qa/v1.2-test-cases.md
- docs/qa/v1.2-release-manual-checklist.md

## Findings

### Critical

None found after fresh verification.

### Warning

None blocking. Note: repository has no useful committed baseline for git diff review (git status --short reports the app tree as untracked), so review was performed against current source and test evidence rather than a commit-to-commit diff.

### Info

- SwipeDeleteAction._setOffset clamps to [0, actionExtent], so negative/left-swipe movement cannot reveal an end-side action.
- SwipeDeleteAction.build renders only swipe-delete-start-action; swipe-delete-end-action is present only in negative assertions in tests.
- SwipeDeleteAction.actionInsets is used at production call sites to align the red action to visible Card/data-row bounds instead of outer list spacing.
- Widget and integration tests cover left-swipe no-op, right-swipe reveal/delete, and red action height alignment.

## Verification evidence

Fresh logs in this task directory:

- resh-flutter-analyze.txt — No issues found!
- resh-flutter-test-scan-map.txt — +18: All tests passed!
- resh-flutter-test-full.txt — +162: All tests passed!
- resh-integration-swipe-delete-device.txt — real device 4e6ad3a, +1: All tests passed!
- resh-flutter-build-apk-release.txt — release APK built successfully.
- resh-adb-install-release-final.txt — db install -r returned Success.
- resh-release-final-device-smoke.txt — installed package/launch evidence after reinstalling release APK.
