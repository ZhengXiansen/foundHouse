# Requirements — optimize swipe delete and building flow

## User-visible requirements

1. **Partial swipe-delete interaction**
   - Current full-row `Dismissible` behavior must be replaced because dragging the row all the way across looks poor.
   - Swiping horizontally should reveal only a fixed-width delete action area.
   - It must work in both directions, preserve the existing confirmation dialog, and rely on repository/Drift streams to remove deleted rows.
   - Rows covered: village cards, building cards, unassigned house cards in village detail, and house cards in the house list.

2. **Quick record building/entrance placement**
   - When recording directly under a village, the optional building/entrance selector/input must appear above monthly rent and directly below the context explanation about choosing an existing building or entering a new one.
   - When the village has no buildings, the same area remains an optional text field; leaving it empty saves the house as unassigned.
   - When entering from a selected building, the page shows fixed building context and does not render an editable building input.

3. **Building card tap behavior**
   - Tapping a building card opens the house list filtered to that building.
   - Only tapping the explicit `在此楼记录房源` button opens the quick record page with fixed building context.
   - The navigation must support the app's GoRouter flow and the existing single-page widget-test/Navigator fallback.

## Process requirements

- Save a requirements/plan artifact before implementation.
- Follow TDD: add failing widget tests and verify they fail before production edits.
- Run local Flutter verification only; **do not run Android device/integration tests or reinstall/test on a phone** until the user explicitly instructs.
- Run code review after implementation. CCG dual-model analysis/review should be attempted; if antigravity is unavailable, record the failure evidence.

## Research summary

Commands/evidence saved in this task directory:

- `smart-search exa-search "iOS trailing swipe actions partial reveal delete list design" ...` → `web-swipe-design-search.md`
- `smart-search exa-search "Apple Human Interface Guidelines swipe actions list rows delete" ...` → `web-apple-swipe-actions.md`
- `smart-search exa-search "swipe actions list row reveal delete partial iOS Material Design" ...` → `web-swipe-design-additional.md`

Design implication: mainstream swipe actions expose contextual buttons on a partial row reveal. Some libraries support full-swipe triggers, but this task intentionally disables full-row/full-dismiss visuals.
