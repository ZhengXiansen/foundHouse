# Plan

1. Add regression tests first.
   - Add Drift v1 -> v2 migration test with a physical v1 SQLite database and old `photo_asset.house_id` data.
   - Add QuickRecord go-detail widget regression through `FoundHouseApp`.
   - Strengthen village detail widget test to require “在此楼记录房源” button inside the matching building Card.
2. Run focused tests and confirm new behavioral tests expose current issues where applicable.
3. Implement minimal fixes.
   - Replace QuickRecord pop-then-push with stable route transition to `/houses/<id>`.
   - Move building quick-record action into each building Card.
   - Add current-state banners to outdated docs, pointing to `租房扫楼产品PRDv1.1.md`.
4. Run focused tests, then `flutter analyze` and full `flutter test`.
5. Perform local global review; attempt/record external wrapper status; write `review.md`.
6. Run Android device check and execute available device/integration flow if a device is connected.
7. Archive CCG task under `.ccg/tasks/archive/2026-07/`; root is not a Git repository, so commit may be impossible and must be stated.
