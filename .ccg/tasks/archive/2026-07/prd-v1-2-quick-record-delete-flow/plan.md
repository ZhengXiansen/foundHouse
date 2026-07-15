# Implementation Plan

1. Write PRD v1.2 and QA docs.
2. Add/adjust tests first for quick record no auto-create, required save, building select/create, delete cascade, swipe delete.
3. Implement repository cascade delete for village/building and helper APIs.
4. Refactor QuickRecordPage to local form state and explicit validated save; support building select/create and field order.
5. Add swipe delete with confirmation to village home, village detail building/house sections, and house list.
6. Run analyze/tests, run review, install/test on device if available, archive task.

## CCG analysis status
- Claude analyzer completed: `.ccg/tasks/prd-v1-2-quick-record-delete-flow/analysis-claude.md`.
- Antigravity analyzer attempted but backend failed because `agy command not found in PATH`; stderr saved in `analysis-antigravity.err`.
- Implementation will proceed inline because developer tool policy does not allow spawning subagents unless explicitly requested.
