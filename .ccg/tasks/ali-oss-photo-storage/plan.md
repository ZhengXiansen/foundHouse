# Plan — Ali OSS photo upload/display

## Phase 1 — Tests first (RED)
1. Add Flutter uploader contract tests:
   - Offline uploader throws `OSS_PHOTO_UPLOAD_NOT_CONFIGURED`.
   - `OssPhotoUploader` requests signer intent, submits multipart form to returned upload URL, and returns `storageProvider=oss`, `remoteUrl`, `objectKey`.
2. Extend Flutter repository/migration tests:
   - `HouseRepository.addPhotoAsset(... storageProvider: oss, remoteUrl, objectKey ...)` persists and reads metadata.
   - Existing v2 DB upgrades to v3 with `storage_provider='local'` and nullable remote fields.
3. Add QuickRecord/photo preview widget test for immediate rendering of remote and local thumbnails under the buttons.
4. Add BFF tests for `POST /api/photos/upload-intent`:
   - missing OSS env => `OSS_NOT_CONFIGURED`;
   - invalid body => `VALIDATION_FAILED`;
   - configured env => returns constrained form fields, publicUrl/objectKey, and never returns secret.
5. Run targeted Flutter/BFF tests and save RED logs in task dir.

## Phase 2 — Flutter data/integration implementation
1. Add photo storage provider constants and remote fields to domain model:
   - `PhotoStorageProvider.local`, `PhotoStorageProvider.oss`.
   - `PhotoAsset.storageProvider`, `remoteUrl`, `objectKey`.
2. Add Drift columns to `PhotoAssets`:
   - `storage_provider TEXT NOT NULL DEFAULT 'local'`
   - `remote_url TEXT NULL`
   - `object_key TEXT NULL`
3. Bump `AppDatabase.schemaVersion` to 3 and implement `_migrateToV3` with `m.addColumn` for the three fields.
4. Regenerate Drift code.
5. Update mappers, `HouseRepository.addPhotoAsset`, and `VillageRepository.addPhotoAsset` to persist optional remote metadata.
6. Add `lib/integrations/oss/oss_photo_uploader.dart` using `dart:io HttpClient`.
7. Add `photoUploaderProvider` in `data/providers.dart` using `FOUND_HOUSE_OSS_SIGNER_URL`; no localhost default.

## Phase 3 — Flutter UI implementation
1. Refactor QuickRecord photo picker behind `quickPhotoPickerProvider` so widget tests can inject fake camera/gallery results.
2. Add UI photo preview state with local pending previews and uploaded remote previews.
3. Change `_savePhotoForHouse` to:
   - save local cache with `PhotoStore`;
   - upload local file via `PhotoUploader` using ownerType `house`, ownerId houseId, tag `room`;
   - create DB row with localPath + OSS metadata only after upload succeeds;
   - return a preview model for immediate display.
4. Disable photo buttons while upload is in progress; show friendly not-configured/upload failure messages.
5. Preserve unsaved-house behavior: pending local previews shown immediately, then uploaded/displayed as remote after record save.

## Phase 4 — BFF implementation
1. Add `src/modules/photos/photo.schema.ts`, `photo.service.ts`, `photo.routes.ts`.
2. Implement PostObject policy generation with Node `crypto.createHmac('sha1', secret).update(policyBase64).digest('base64')`.
3. Validate owner/tag/contentType/contentLength/fileName; generate safe objectKey server-side.
4. Add `OSS_NOT_CONFIGURED` / `OSS_SIGNING_FAILED` errors.
5. Register routes in `buildApp()`.

## Phase 5 — Docs, verification, review, archive
1. Update README / field dictionary / privacy page to reflect optional OSS photo upload.
2. Run build_runner, format, analyze, Flutter tests, BFF tests/build/lint.
3. Build release APK and reinstall on available device per spec.
4. Write review.md with CCG wrapper limitation and local security checklist.
5. If fully verified, mark task completed and archive. Root is not a git repo; record skipped archive commit.

## Parallelization note
CCG L+ normally requires sub-agent parallel implementation. The Codex runtime developer instruction forbids spawning sub-agents unless the user explicitly asks for sub-agents/parallel agent work, and the local external model wrapper is missing. Therefore implementation will be inline in this session while preserving disjoint phases and verification gates.
