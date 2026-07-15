# Plan

## Layer 1: Deterministic Logic and Gates

1. Add red tests for `CostCalculator`: unit prices without explicit monthly fee must still include conservative monthly estimates.
2. Add red tests for `CommuteSelector` and `HouseScoringService`: primary destination is selected before mode preference.
3. Add red tests for BFF rate limit response: throttled requests return `MAP_RATE_LIMITED`; Redis option is wired when available.
4. Add ESLint 9 flat config for the BFF.
5. Add explicit Flutter dependencies for direct imports causing analyzer failures.

## Layer 2: Encryption

1. Add an async `FieldCipher` backed by `CryptoService`.
2. Update repository/mappers to await encryption/decryption at repository boundaries.
3. Make production provider use AES-GCM-backed cipher.
4. Preserve `NoopFieldCipher` only for tests/explicit overrides.
5. Add repository tests proving DB ciphertext differs from plaintext while domain reads return plaintext.

## Layer 3: Client Map

1. Replace placeholder scan map with a usable Flutter page showing located houses, current selected house, POI summary, and commute summary state.
2. Implement app-side AMap/BFF client abstractions enough for BFF POI/commute calls and local `MapSnapshot` write-back.
3. Add widget/unit tests around non-placeholder rendering and snapshot persistence behavior.

## Layer 4: PDF

1. Configure a Chinese-capable font path or bundled fallback for PDF export if available in the project.
2. Add/adjust tests to verify export does not emit font warnings where testable.

## Final

1. Run full quality gates.
2. Attempt CCG dual-model review again; record failures if infrastructure still unavailable.
3. Write `.ccg/tasks/fix-review-dev-execution-plan/review.md`.
4. Archive the task under `.ccg/tasks/archive/2026-07/`.
