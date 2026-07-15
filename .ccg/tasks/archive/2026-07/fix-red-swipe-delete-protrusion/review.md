# Review

## Review mode

- CCG requires dual-model review for M complexity.
- Attempted wrapper check: `C:\Users\Mr.Zheng\.claude\bin\codeagent-wrapper` => `EXISTS=False` (`review-external-wrapper-check.txt`).
- Subagent review from the local code-review skill was not spawned because the current developer instruction forbids spawning subagents unless explicitly requested by the user.
- Fallback: local manual review using the requested Critical / Warning / Info categories.

## Scope reviewed

- `found-house-app/lib/features/common/delete_confirmation.dart`
- `found-house-app/test/features/scan_map_page_test.dart`
- `.ccg/spec/guides/index.md`
- Shared usages:
  - `found-house-app/lib/features/scan/village_home_page.dart:168`
  - `found-house-app/lib/features/scan/village_detail_page.dart:308`
  - `found-house-app/lib/features/scan/village_detail_page.dart:412`
  - `found-house-app/lib/features/house/house_list_page.dart:132`

## Strengths

- Root cause fixed in the shared `SwipeDeleteAction`, so village, building, and house rows inherit the same visual behavior.
- Hidden delete actions now also ignore pointer input and are excluded from semantics, matching existing accessibility requirements.
- Regression test checks rendered pixels rather than only widget state, so it catches the original card-margin/rounded-corner visual leak.
- Existing tests still verify fixed-width reveal, small-swipe rollback, bidirectional swipes, and confirmation-before-delete behavior.

## Critical

None found.

## Warning

None found.

## Info

- Release-device navigation by raw `adb shell input tap/keyevent` is blocked on this device by `INJECT_EVENTS` restrictions. For release page verification, direct FlutterActivity route extras were used instead (`--es route /houses` and `/scan/villages/5`).
- App repository appears to have no tracked baseline (`git status` shows the project files as untracked), so review could not rely on a normal `git diff` range.

## Verification reviewed

- TDD RED evidence: `red-test-before-fix-output.txt` shows the new visual regression failed before the fix with `Actual: <5036>` risk-red pixels at rest.
- Focused GREEN: `green-focused-test-output.txt`, exit code 0.
- Relevant widget file: `scan-map-page-test-output.txt`, exit code 0, 18 tests passed.
- Static analysis: `flutter-analyze-output.txt`, exit code 0, `No issues found!`.
- Full tests: `flutter-test-output.txt`, exit code 0, `All tests passed!` (162 tests).
- Release build/install: `flutter-build-release-output.txt`, `adb-install-release-after-fix-output.txt`, both exit code 0.
- Pixel verification: `red-pixel-analysis-release-pages.txt` shows:
  - before homepage: 29,202 risk-red pixels, side components in village card areas;
  - after homepage: 0 risk-red pixels;
  - after village detail route `/scan/villages/5`: 0 risk-red pixels;
  - after house list route `/houses`: 0 risk-red pixels.

## Assessment

Ready to hand off. The implementation satisfies the requested UI fix and preserves the existing swipe-delete interaction according to tests and release-device screenshots.
