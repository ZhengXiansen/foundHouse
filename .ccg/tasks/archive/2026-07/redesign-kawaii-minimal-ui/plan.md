# Implementation Plan

## Design system
1. Replace the neutral green-led global baseline with a semantic Kawaii Minimal palette: cream/pink low-contrast backdrop, ink text, candy pink/purple/mint/yellow accents, and gentle danger/warning treatments.
2. Expand the Material 3 theme so cards, inputs, chips, dialogs, snackbars, buttons, tabs, and navigation use rounded sticker/soft-plastic forms while preserving semantic state colors.
3. Add reusable presentation-only widgets for the app-wide gradient backdrop, animated pressable surfaces, compact icon bubbles, and a friendly page heading. These widgets must not own application state or navigation.

## Apply presentation without touching logic
4. Wrap the routed app in the app-wide backdrop; retain the existing `MaterialApp.router`, provider access, and router configuration.
5. Update the root navigation shell into a floating, rounded navigation surface while preserving the same four destinations and `goBranch` behavior.
6. Apply the new visual primitives to the home and settings dashboard pages—the highest-frequency entry pages—while keeping their providers, callbacks, dialogs, and route calls unchanged.
7. Rely on the revised global component theme for existing data-driven forms, lists, detail pages, checklists, scoring, compare, and settings sub-pages. Avoid changes to repositories, controllers, model classes, or route identifiers.

## Quality and verification
8. Add a failing theme/widget test that codifies the rounded, candy-accent visual-system contract, then implement it and confirm it turns green.
9. Run formatter, affected widget tests, full analyzer, and full test suite.
10. Launch a connected Android device, capture fresh screenshots for the redesigned app flows, and inspect generated artifacts/command outputs.
11. Record review results, archive the CCG task, and commit task archival only if a repository exists at the task root.

## Planned source scope
- `found-house-app/lib/app/theme.dart`
- `found-house-app/lib/app/motion.dart`
- `found-house-app/lib/app/app.dart`
- `found-house-app/lib/app/router.dart`
- `found-house-app/lib/app/kawaii_widgets.dart` (new)
- `found-house-app/lib/features/scan/village_home_page.dart`
- `found-house-app/lib/features/settings/settings_page.dart`
- `found-house-app/test/app/kawaii_theme_test.dart` (new)

## Non-goals
- No business/repository/database/model/score-rule changes.
- No route path/name changes.
- No new external asset dependency; the visual language is implemented with Flutter vector/material primitives for predictable offline builds.
