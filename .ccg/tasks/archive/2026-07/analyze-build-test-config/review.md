# Review / Verification Notes

## Codebase context tools

- `mcp__augment_context_engine.codebase_retrieval`: failed with 502 Bad Gateway.
- `mcp__ace_tool.search_context`: failed due SSL certificate verification.
- `mcp__contextweaver.codebase_retrieval`: succeeded; identified Flutter app, BFF package scripts, CLAUDE.md environment constraints.

## External model analysis

- antigravity via `codeagent-wrapper`: attempted, failed because `agy command not found in PATH`.
- Claude via `codeagent-wrapper`: succeeded; output saved in `analysis-claude.out.txt` before archive.

## Local verification commands

### Environment

- `node --version`: v24.14.0
- `npm --version`: 11.9.0
- `flutter --version`: Flutter 3.44.4 / Dart 3.12.2

### Flutter app (`found-house-app`)

- `flutter pub get`: passed.
- `dart run build_runner build --delete-conflicting-outputs`: passed; build_runner warns this option is removed/ignored in current version.
- `flutter analyze`: passed, no issues.
- `flutter test`: passed, 123 tests.
- `flutter build apk --debug`: failed because `android/app/build.gradle` is missing; platform dirs have not been generated.

### BFF (`found-house-bff`)

- `npm ci`: passed.
- `npm run build`: passed.
- `npm test`: passed, 3 files / 23 tests.
- `npm run lint`: passed.

## Main findings

- BFF can build/test/run after environment variables are provided.
- Flutter app can analyze/test but cannot package until platform project files are generated with `flutter create`.
- Manual decisions/configuration required: Flutter `--org`/package id, BFF `AMAP_WEBSERVICE_KEY`, app `FOUND_HOUSE_BFF_BASE_URL` for emulator/real device, optional Redis/Postgres/rate limit/log env vars, platform permissions/signing.
- Root directory is not a Git repository, so CCG archive commit cannot be performed from root.
