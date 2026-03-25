# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run -d chrome    # Run on web (primary target)
flutter run -d android   # Run on Android
flutter analyze          # Static analysis (run after every change)
flutter test             # Run all tests
flutter test test/sudoku_logic_test.dart  # Run a single test file
flutter test --coverage  # Generate coverage report
```

Always run `flutter analyze` and `flutter test` after making changes.

## Architecture

**Hub + Plugin model:** `AppShell` wraps a `ProviderScope` and `MaterialApp`. The `GameRegistry` provider holds an explicit list of `GameModule` implementations. `HomeScreen` reads the registry to render game cards. Navigating to a game calls `module.buildScreen()`.

**Adding a new game:** Create a directory under `lib/lib/games/<game_id>/` with:
- `<game_id>_module.dart` — implements `GameModule` (metadata + `buildScreen`)
- `<game_id>_screen.dart` — `StatefulWidget` for the full game UI
- `logic/<game_id>.dart` — pure Dart logic (zero Flutter imports)

Then register the module in `lib/lib/games/registry/game_registry.dart`.

**Pure logic boundary:** All game rules live in `logic/` subdirectories and must not import Flutter. Game state moves return immutable new state. This enables deterministic unit testing without a widget harness.

**State management:** Riverpod for theme and registry providers. Individual game state lives in local `StatefulWidget`.

**Design tokens:** All spacing, colors, radii, and durations come from `lib/lib/design/tokens.dart` (re-exported from `lib/lib/theme/`). Never use hardcoded hex colors or magic numbers in UI code.
- Spacing: `Spacing.s8`, `s13`, `s21`, `s34`
- Radii: `Spacing.r12`, `r16`, `r24`
- Colors: `CalmPalette.bg`, `surface`, `text`, `subtext`, `primary`, `secondary`, `accent`, `stroke`
- Durations: `Spacing.ms180`, `ms220`, `ms260`

**Shared UI components:** `GameHeader` and `GameDialogs` in `lib/lib/shared/` are reusable across games. Extract to shared when 2+ games need the same pattern.

**Engine primitives:** `lib/lib/engine/grid_utils.dart` (generic grid ops) and `lib/lib/engine/rng.dart` (seedable RNG for deterministic tests).

**Note on directory layout:** Source files live under `lib/lib/` (nested lib), not directly under `lib/`. `lib/main.dart` is the entry point.

## Testing

Unit tests cover game logic per game (e.g., `test/game_2048_logic_test.dart`). Every game rule change requires unit test coverage. Widget tests are minimal; integration tests do not exist yet.

---

## Guardrails

### File System
- Source lives under `lib/lib/` (nested lib) — never place game files directly under `lib/`.
- Before creating a new file, Grep the codebase to confirm it doesn't already exist.
- After renaming or moving a file, Grep for all import references and update them.
- Use absolute paths in all file operations — the shell cwd can reset between tool calls.

### Design Tokens — NEVER hardcode values
- Colors: only `CalmPalette.*` constants — never `Color(0xFF...)` or `Colors.*`.
- Spacing/radii: only `Spacing.*` constants — never `EdgeInsets.all(24)` or bare `double` literals.
- Durations: only `Spacing.ms180 / ms220 / ms260` — never `Duration(milliseconds: 300)`.
- If a value is needed in 2+ places, add it to `lib/lib/design/tokens.dart` first.

### Pure Logic Boundary
- Files under any `logic/` subdirectory must have **zero Flutter imports**.
- Game state mutations must return new immutable state — never mutate in place.
- Violations of this rule break deterministic unit testing.

### Adding a Game — Checklist
1. Create `lib/lib/games/<game_id>/` with `_module.dart`, `_screen.dart`, and `logic/<game_id>.dart`.
2. Register the module in `lib/lib/games/registry/game_registry.dart` — omitting this means the game never appears.
3. Write `test/<game_id>_logic_test.dart` covering all game rules before considering the task done.
4. Use `lib/lib/engine/rng.dart` for any randomness so tests are deterministic.

### Verify After Every Change
```bash
flutter analyze   # zero issues required before moving on
flutter test      # all tests must pass
```
Never skip these steps to "move faster" — failures caught early are cheap; failures caught late are not.

### Agentic Loop — Stop Conditions
- If the same `flutter analyze` error appears after two distinct fixes, stop and diagnose the root cause rather than trying a third patch.
- If you make the same file change twice in a session, your context is likely stale — re-read the relevant files before continuing.
- Do not retry a failing shell command unchanged. Understand why it failed first.

### State and Riverpod
- Game-specific state belongs in local `StatefulWidget` state — not in global providers.
- Only `GameRegistry` (metadata) and theme live in global `ProviderScope`.
- Prefer `StateNotifierProvider` over `ChangeNotifierProvider` for any new providers.

### Shared vs. Game-Local Code
- Cross-game UI reuse goes into `lib/lib/shared/` only once 2+ games need it.
- Cross-game imports between `games/<a>/` and `games/<b>/` are forbidden.
- Always check `lib/lib/shared/` and `lib/lib/engine/` before writing new utilities.

### Pre-commit Checklist
- [ ] `flutter analyze` — zero errors/warnings
- [ ] `flutter test` — all tests pass
- [ ] No hardcoded colors, spacing, radii, or durations
- [ ] No Flutter imports inside `logic/` files
- [ ] New game module registered in `game_registry.dart`
- [ ] No unused imports
