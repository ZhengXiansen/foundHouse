# Requirements

User feedback: previous swipe-delete fix is incomplete.

## Functional requirements

1. Right-swipe delete red action must visually attach to the data row/card: the red action area must not be taller than the visible row/card, and must align with the card's visual bounds rather than list/card margins.
2. Swipe delete must be right-swipe only. Left swipe / right-to-left drag must not reveal a delete action and must not delete.
3. Actual deletion must still require tapping the revealed delete button and then confirming in the delete dialog.
4. Default/closed state must not expose the destructive red background or delete semantics.
5. Village, building, village-detail house, and house-list cards must follow the same behavior.

## Verification requirements

- Add regression widget tests that fail on the current implementation before production code changes.
- Update device integration swipe-delete script to cover right-swipe-only behavior.
- Run focused widget tests, full scan map widget tests, flutter analyze, full flutter test, release APK build/install, and device smoke/integration evidence where possible.
