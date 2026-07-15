# Execution Plan — optimize swipe delete and building flow

## Scope boundaries

### In scope

- Shared partial-reveal swipe delete component in `lib/features/common/delete_confirmation.dart`.
- Replace `Dismissible` rows in:
  - `lib/features/scan/village_home_page.dart`
  - `lib/features/scan/village_detail_page.dart`
  - `lib/features/house/house_list_page.dart`
- Reorder village-level building selector/input in `lib/features/scan/quick_record_page.dart` so it appears above monthly rent.
- Extend `HouseListPage` so it can be opened with fixed village/building filters and show a building-specific house list.
- Add a GoRouter route from village detail to the building-filtered house list, plus Navigator fallback for widget tests.
- Update/add widget tests in `test/features/scan_map_page_test.dart`.

### Out of scope

- Database schema changes.
- Repository cascade-delete semantics beyond existing calls.
- Scoring/sorting algorithm changes.
- Android device/integration/manual testing.
- New third-party swipe packages; use an in-project component to avoid dependency/version churn.

## Implementation steps

1. **TDD RED**
   - Add tests that fail against current code:
     - Village-level quick record shows `quick-building-field` above `① 月租 *`; no-building state still shows optional field/help text; building-context entry hides the field.
     - A partial swipe reveals an actionable delete pane while keeping the row in place; helper then taps the pane and confirms deletion. Cover both swipe directions through existing delete tests.
     - Tapping a building card opens a building-filtered `HouseListPage` and does not show `快速记录`; tapping `在此楼记录房源` still opens quick record.
   - Run targeted tests and record the failing output.

2. **GREEN implementation**
   - Add `SwipeDeleteAction` to `delete_confirmation.dart`:
     - `GestureDetector` controls a clamped horizontal offset.
     - Dragging beyond a threshold snaps to `±actionExtent` instead of dismissing.
     - Exposed delete pane is a real accessible button with stable keys.
     - Button invokes supplied async delete flow, which reuses `confirmDeleteRecord`.
   - Replace each `Dismissible` with `SwipeDeleteAction` and keep existing confirmation/deletion bodies.
   - Move `_BuildingSelector` above rent in `QuickRecordPage` and update intro copy; avoid auto-focusing rent for village-level entry so the building area stays primary.
   - Extend `HouseListPage` constructor with optional fixed `villageId`, `buildingId`, and display names; filter data accordingly; hide village filter when fixed context is active and adjust app bar/empty state text.
   - Add route name `buildingHouseListName` under `/scan/villages/:villageId/buildings/:buildingId/houses`; add `_openBuildingHouseList` helper with GoRouter and Navigator fallback.

3. **Local verification**
   - Run targeted widget tests for modified scan/house flows.
   - Run `flutter analyze`.
   - Run the broader test suite if feasible.
   - Do not run `flutter test -d ...`, `adb`, or release reinstall.

4. **Review**
   - Run CCG review with antigravity + Claude; record antigravity unavailability if `agy` is still missing.
   - Summarize findings in `review.md`; fix Critical/Important issues and rerun relevant verification.

5. **Archive**
   - If verification and review pass, consider spec evolution. Archive the CCG task under `.ccg/tasks/archive/YYYY-MM/`.
   - Git commit may be impossible/undesirable if this checkout has no normal commit history; record actual state instead of fabricating a commit.

## Acceptance evidence

- Tests prove: partial delete reveal, both directions, confirmation deletion, quick-record field order/fixed building context, building card navigation/filtering.
- `flutter analyze` has no issues or any remaining issues are explicitly unrelated and documented.
- `review.md` records review result and fixes.
- Final user message explicitly states no真机测试 was run and waits for instruction.
