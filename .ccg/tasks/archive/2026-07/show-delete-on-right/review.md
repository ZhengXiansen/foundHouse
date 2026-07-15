# Review — show delete action on the right

## Scope reviewed

Requirement: the destructive delete action for village/building/house rows must display on the right/trailing side, be revealed by a physical left swipe, remain hidden/no-op on right swipe, keep explicit confirmation, and align the red action height with the visible card/data row.

## External review status

CCG required dual-model review for M complexity. I attempted the configured CCG wrapper availability check in `review-external-wrapper-current.txt`:

- `C:\Users\Mr.Zheng\.claude\bin\codeagent-wrapper` exists: `False`
- antigravity/claude reviewer role files exist, but the executable wrapper is unavailable.

Because the wrapper is missing, dual external review could not be executed in this environment. The review below is a local/manual review backed by fresh tests and device evidence.

## Manual review findings

### Critical

None found.

### Warning / Important

None found for the requested behavior.

### Info

- The app Git repository has no tracked baseline (`git status --short` shows the app tree as untracked and `git diff` is empty), so review used direct file inspection and verification logs instead of commit-to-commit diff. Evidence: `git-status-and-diff-current.txt`.
- `flutter test -d e4e6ad3a integration_test/swipe_delete_device_test.dart` installed a debug APK after uninstalling the existing release due signature mismatch; this is expected for Flutter integration tests. Release was rebuilt and reinstalled afterwards. Evidence: `integration-swipe-delete-device-current.txt`, `flutter-build-apk-release-final.txt`, `adb-install-release-final.txt`, `release-final-device-smoke-current.txt`.

## Implementation alignment reviewed

- `lib/features/common/delete_confirmation.dart` clamps swipe offset to `[-actionExtent, 0]`, so left swipe can reveal trailing action and right swipe from closed state cannot reveal a left/start action.
- The delete action is rendered with `Positioned(right: actionInsets.right, top: ..., bottom: ..., width: ...)` and keys `swipe-delete-end-semantics` / `swipe-delete-end-action`, so the actionable area is on the right/trailing side.
- Foreground content uses `Transform.translate(offset: Offset(_offset, 0))`; negative offset moves the card left and reveals the right-side action.
- Existing confirmation remains centralized through `confirmDeleteRecord`; the swipe itself does not delete immediately.
- Call sites pass `actionInsets` matching card/list spacing so the red action aligns with visible rows/cards rather than filling outer margins.
- Widget and integration tests cover component behavior, visual/right-side alignment, app-level village/building/house deletion, and right-swipe no-op.
- QA docs and `.ccg/spec/guides/index.md` encode the product convention: delete button on the right, left swipe reveals, right swipe no-op.

## Verification summary

Fresh verification logs:

- `dart-format-check-current.txt`: `Formatted 3 files (0 changed)`, exit 0.
- `flutter-analyze-current.txt`: `No issues found!`, exit 0.
- `flutter-test-full-current.txt`: `+162: All tests passed!`, exit 0.
- `integration-swipe-delete-device-current.txt`: Android device integration `+1: All tests passed!`, exit 0.
- `flutter-build-apk-release-final.txt`: release APK built, exit 0.
- `adb-install-release-final.txt`: release APK install `Success`, exit 0.
- `release-final-device-smoke-current.txt`: package installed, app launched, `topResumedActivity=com.zheng.foundhouse/.MainActivity`, screenshot captured.

## Assessment

Ready for handoff. The requested right-side delete behavior is implemented, covered by widget tests and Android device integration, documented in QA/spec files, and the final device state has the release APK reinstalled after integration testing.
