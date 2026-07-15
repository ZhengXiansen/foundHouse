# Requirements

Source review: `.ccg/tasks/archive/2026-07/review-dev-execution-plan/review.md`

## Must Fix

- C1/F7: production repository path must store sensitive fields encrypted, not via default `NoopFieldCipher`.
- C2/W3/F6: client map path must stop being a placeholder and connect to house location, POI/commute summaries, and local `MapSnapshot` persistence.
- W1/F1/F2: monthly total cost must include water/electric monthly estimates even when unit prices are present but no monthly fee is recorded.
- W2/F5: primary commute selection must prefer the destination marked `primary=true`, falling back to the first destination only when none is marked primary.
- W3: BFF rate limiting must return `MAP_RATE_LIMITED` for map quota throttling and use Redis/shared state when available.
- W4: quality gates must pass or any remaining blocker must be documented with exact evidence.

## Should Fix

- I1: PDF export should use a Chinese-capable font or otherwise stop emitting unreadable Chinese PDF output.

## Verification

- `flutter analyze` in `found-house-app`
- `flutter test` in `found-house-app`
- `npm test` in `found-house-bff`
- `npm run build` in `found-house-bff`
- `npm run lint` in `found-house-bff`

## External Analysis Attempts

- `codeagent-wrapper --backend antigravity`: failed because `agy command not found in PATH`.
- `codeagent-wrapper --backend claude`: timed out after 5 minutes; leftover wrapper/claude processes from that attempt were stopped.
- `ccg-research` app slice: spawned for read-only findings.
- `ccg-research` BFF/map slice: failed with `429 Too Many Requests`.
