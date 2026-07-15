# Global Review — PRD v1.1 and manual village flow

Date: 2026-07-05 (Asia/Shanghai)

## Scope

This review covers the current repository state after the v1.1 product pivot from map-first scanning to manual village/building scanning.

Reviewed deliverables and code areas:

- Root product document: `租房扫楼产品PRDv1.1.md`
- Flutter app routing and IA: `found-house-app/lib/app/router.dart`
- Manual scan flow UI: `VillageHomePage`, `VillageDetailPage`, `QuickRecordPage`, `ScanMapPage` compatibility alias
- House list village filter: `found-house-app/lib/features/house/house_list_page.dart`
- Drift schema and migration: `tables.dart`, `app_database.dart`, generated Drift output
- Repositories/providers: `HouseRepository`, `VillageRepository`, `providers.dart`
- Photo ownership model: `PhotoAssets`, `PhotoStore`, owner-aware repository APIs
- Regression tests under `found-house-app/test/`

Primary review questions:

1. Does the app implement the confirmed product direction: village -> building -> house, no user-facing map dependency?
2. Are there gaps between PRD v1.1 and current implementation?
3. Are there code quality, migration, testing, or documentation risks that should be handled before/after the next iteration?

## External / delegated review status

CCG asks M+ tasks to use dual external review through `~/.claude/bin/codeagent-wrapper`.
The wrapper was checked earlier in this task and is not installed at either expected path:

- `C:\Users\Mr.Zheng\.claude\bin\codeagent-wrapper` => missing
- `C:/Users/Mr.Zheng/.claude/bin/codeagent-wrapper` => missing

The `requesting-code-review` skill normally dispatches an isolated reviewer subagent. In this session, subagent spawning is not used because the active tool policy only allows subagents when the user explicitly requests delegation/parallel agents, and the CCG wrapper fallback is unavailable.

Therefore this is a local evidence-based global review, using source inspection, archived iteration requirements/review, string scans, and fresh verification commands recorded in the final section.

## Feature completeness

### Implemented / aligned with PRD v1.1

- **Top-level IA updated**: bottom tabs are `首页 / 房源 / 对比 / 我的`; `/scan` still exists as the stable route but now renders `VillageHomePage` instead of the old map workspace.
- **Map-first user flow is downlined**:
  - `ScanMapPage` is only a compatibility alias extending `VillageHomePage`.
  - Active scan/home UI does not show `扫楼地图`.
  - Default map BFF provider returns `OfflineMapApiClient` when `FOUND_HOUSE_BFF_BASE_URL` is not configured, avoiding accidental localhost access in release builds.
- **Village-first home flow exists**:
  - Home page supports creating a village.
  - Shows continue-scanning card and village list statistics.
  - Village cards provide entry to village detail and quick house recording.
- **Village detail / building workflow exists**:
  - Village detail shows village stats, quick actions, building list, and unassigned-house section.
  - New buildings can be created with name + initial fixed status.
  - Building status can be updated through the menu.
  - From a village or a specific building, the user can enter quick house recording.
- **Quick house recording is village-scoped**:
  - `QuickRecordPage` requires `villageId`.
  - Missing village context shows a clear page: “请先在首页选择一个村再记录房源”.
  - Draft creation writes `villageId`, optional `buildingId`, optional `buildingName`, rent, room number, layout, and house photos.
- **House list has village-level review filter**:
  - `HouseListPage` watches villages and houses and filters by selected village with chips.
- **Data model supports the new hierarchy**:
  - `Villages` and `Buildings` tables exist.
  - `HouseRecords` contains `villageId` and `buildingId`.
  - `PhotoAssets` is generalized with `ownerType + ownerId`, while keeping nullable `houseId` for compatibility.
- **Migration strategy is present**:
  - `schemaVersion` is 2.
  - v2 migration creates `village` and `building`, adds `house_record.village_id/building_id`, creates `system-unassigned-village`, backfills old houses, and rebuilds `photo_asset` so old house photos become `owner_type='house' / owner_id=house_id`.
- **Regression coverage exists for the new direction**:
  - Tests cover village repository stats, owner-aware photo APIs, provider defaults, scan/home page behavior, app smoke/navigation, and “old map copy not visible” assertions.

### Partial / product gaps

- **Village/building photo UI is not user-complete yet**.
  - Data layer supports owner-aware photos for `village/building/house`.
  - `PhotoStore.savePhotoForOwner` and `VillageRepository.addPhotoAsset/getPhotosForOwner/deletePhotoAsset` exist.
  - Current visible UI only exposes house-level photo capture in `QuickRecordPage`; village/building photo upload/browse/delete UI is still pending.
- **Village and building edit/archive/delete strategy is not surfaced**.
  - Current UI supports creation and building status updates.
  - It does not yet provide village editing, building detailed editing, village archive, building archive/delete, or danger-confirmed deletion flows for objects with child data.
- **Manual village defaults for commute/surrounding/environment are not fully surfaced**.
  - v1.1 says map-derived commute/POI should become manual village-level defaults with house-level override where needed.
  - Existing preference/scoring/map-snapshot legacy still exists, but a first-class village-level manual commute/surrounding form is not yet visible in the reviewed scan flow.
- **Moving unassigned houses into a concrete building is not user-facing yet**.
  - Unassigned houses are listed in village detail.
  - There is no direct action from that list to assign/move a house into an existing building.

## Code quality review

### Critical

No Critical finding from local source review.

The main candidate risk from the handoff was `PhotoAssets` v1->v2 migration. Current `app_database.dart` does include a table rebuild path for `photo_asset`: it renames the v1 table, creates the v2 table with `owner_type` and non-null `owner_id`, backfills `owner_id` from `house_id`, then drops the v1 table. That removes the previously suspected migration blocker.

### Warning

1. **No explicit v1 -> v2 migration regression test**
   - The migration code is present and looks intentional, but tests do not currently create a schema-v1 database and upgrade it to schema-v2.
   - Risk: future schema edits could silently break existing users with old local data.
   - Recommendation: add a Drift migration test that creates v1 `house_record/photo_asset` rows, opens with current DB, and verifies:
     - old houses are attached to `system-unassigned-village`;
     - `photo_asset.owner_type == 'house'`;
     - `photo_asset.owner_id == old house_id`;
     - `house_id` compatibility remains usable.

2. **Documentation drift can mislead future development**
   - Root `CLAUDE.md`, `found-house-app/CLAUDE.md`, `found-house-app/README.md`, and old PRD/technical/UI docs still describe the app as planning-stage or map-first.
   - This does not break runtime behavior, but it conflicts with `租房扫楼产品PRDv1.1.md` and current code.
   - Recommendation: either update these docs or add a prominent top note: “historical document; PRD v1.1 is the source of truth for the current iteration.”

3. **Village/building photos are only data-layer complete**
   - Owner-aware photo APIs are a good foundation, but users cannot yet attach/view village entrance, building facade, access-control, stairwell, or rental-sign photos from the village/building UI.
   - Recommendation: implement a reusable `OwnerPhotoSection(ownerType, ownerId)` component in a follow-up iteration.

4. **Archive/delete/edit lifecycle is not yet implemented**
   - The data model has village statuses including `archived`, and building statuses including `abandoned`, but UI currently exposes only creation and building status changes.
   - Recommendation: add explicit lifecycle actions with safe defaults: archive/abandon first, hard delete only with child-count warning and confirmation.

5. **Building card action layout is functional but rough**
   - `VillageDetailPage._BuildingList` renders all building cards first, then renders a second loop of “在此楼记录房源” buttons outside the cards.
   - This is usable but visually disconnects actions from their building cards and may become confusing when the list grows.
   - Recommendation: move the action button into each building card/ListTile trailing or a card footer.

6. **QuickRecord detail navigation uses pop-then-push on the current page context**
   - `_openDetail()` pops the quick-record route when possible and then pushes `/houses/$id` using the same `BuildContext`.
   - This may work synchronously, but it is fragile because the context belongs to the route being popped.
   - Recommendation: use `pushReplacement`, `context.go('/houses/$id')`, or push from a parent/root navigator context.

7. **Legacy map code remains by design, but boundaries must stay explicit**
   - `MapRepository`, `integrations/amap`, `MapSnapshot`, POI/commute models, and related tests still exist.
   - This matches the agreed phased-downline strategy, but future contributors need clear docs/tests that these are not part of the active scan/home user flow.

8. **Git state limits diff-based review**
   - Root `D:\dev\code\foundHouse` is not a Git repository.
   - `found-house-app` is a Git repository, but its app files are currently untracked, so `git diff` cannot isolate this task’s changes.
   - Review therefore uses file-level inspection and tests instead of a clean base/head diff.

### Info / positive observations

- The current route design preserves stable `/scan` URLs while changing the page semantics to “首页”, reducing migration/navigation churn.
- `OfflineMapApiClient` default is consistent with the spec: no accidental production `localhost` dependency.
- `HouseRepository.create/updateMain` validates building-village consistency and touches village/building timestamps to keep aggregate streams fresh.
- `VillageRepository.watchVillageWithStats` explicitly watches `village/building/house_record`, aligning with the `.ccg/spec/guides` guidance on Drift streams and child-table updates.
- Room number is passed through field encryption before persistence.
- The “missing village context” page is a good guardrail against orphan house records in the new flow.
- Existing widget tests already include the extra unmount pump pattern needed for Riverpod + Drift stream cleanup.

## Verification commands

Fresh verification for this task was run from `found-house-app/` after this review document was written:

- `flutter analyze` → exit 0; output: `No issues found! (ran in 3.2s)`
- `flutter test` → exit 0; output ended with `+142: All tests passed!`

## Recommended next iteration backlog

P0 / next before wider use:

1. Add schema v1 -> v2 migration regression test.
2. Update or clearly supersede stale README/CLAUDE/old PRD docs.
3. Fix `QuickRecordPage._openDetail()` navigation to avoid using a popped route context.

P1:

1. Implement village/building photo UI using existing owner-aware data APIs.
2. Add edit/archive/delete lifecycle actions with child-count safeguards.
3. Add “move unassigned house to building” action in village detail.
4. Add village-level manual commute/surrounding/environment defaults and clarify how scoring consumes them.
5. Refactor building card action layout.

P2:

1. Physically remove legacy map/BFF/AMap surfaces after the manual flow is stable and migration/export/scoring dependencies are fully separated.
2. Add release/manual test cases for the new village-first field workflow on Android device.
## Spec feedback recorded

Added a guide section to `.ccg/spec/guides/index.md`: `Drift schema 升级与迁移回归测试`, capturing the review lesson that schema-version upgrades with table rebuilds or non-null backfills need explicit old-schema migration tests, not only fresh database tests.

