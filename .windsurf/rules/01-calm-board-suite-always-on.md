# Calm Board Suite — Always On (Legacy-safe diffs)

## Non-negotiables
- Single codebase: **Flutter** for Android + Web.
- Architecture: **Hub shell + Game modules (plugins) + Shared UI kit + Shared engine primitives**.
- **No code duplication**: If logic exists, refactor into shared utilities/components.
- Prefer **composition** over inheritance.
- Keep diffs small and incremental. If a change is broad, split into commits.

## Coding standards
- Favor pure Dart for game logic; keep UI separate.
- No side effects in model code; isolate platform concerns.
- Add/extend tests for game rules and move validation.
- Do not invent APIs. Use simple, explicit interfaces.

## Workflow standards
- After each substantial change:
  - `flutter analyze`
  - `flutter test`
- If a command fails, fix before adding features.

## Naming
- game ids are snake_case (e.g., `sliding_puzzle`, `connect4`).
- modules live under `lib/games/<game_id>/`.
