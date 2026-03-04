# Windsurf Agent Guide — Calm Board Suite

This document explains how Windsurf agents should work in this repository.

---

## 1. Active Windsurf Rules

Rules are located in `.windsurf/rules/` and are **always active**.

| Rule File | Purpose |
|-----------|---------|
| `01-calm-board-suite-always-on.md` | Core architecture and coding standards |
| `architecture_rules.md` | Plugin-based game architecture |
| `ui_design_rules.md` | Design tokens and UI patterns |
| `code_safety_rules.md` | Safe development practices |
| `flutter_project_rules.md` | Flutter-specific conventions |

**Rules are enforced automatically** — agents must follow them without user prompting.

---

## 2. Available Workflows

Workflows are located in `.windsurf/workflows/` and are invoked via slash commands.

| Workflow | Command | Purpose |
|----------|---------|---------|
| Add Game Module | `/add-game-module` | Create a new game plugin |
| Implement Game Logic | `/implement-game-logic` | Add pure Dart game logic |
| Implement Game UI | `/implement-game-ui` | Build Flutter UI for a game |
| Review Pull Request | `/review-pr` | Code review checklist |
| Refactor Shared Code | `/refactor-shared` | Extract to shared utilities |

---

## 3. When Rules Apply

### Always-On Rules

These rules apply to **every** agent action:
- Architecture boundaries (UI vs logic separation)
- No code duplication
- Use design tokens for spacing/colors
- Small incremental diffs
- Tests for game logic

### Workflow-Specific Rules

Additional rules activate when running workflows:
- `/add-game-module` — Module structure, registration
- `/implement-game-logic` — Pure Dart, no Flutter imports
- `/implement-game-ui` — Design tokens, accessibility

---

## 4. What Happens Automatically vs Requires Approval

### Automatic (Agent Does)

- Read files and analyze code
- Create new files in appropriate locations
- Edit existing code following rules
- Run safe commands (`flutter analyze`, `flutter test`)
- Generate documentation

### Requires Human Approval

- Running potentially destructive commands
- Installing new dependencies (`flutter pub add`)
- Deleting files
- Major architectural changes
- Publishing or deploying

---

## 5. Recommended Agent Workflow

### Before Making Changes

1. **Read relevant files** — Understand existing patterns
2. **Check rules** — Review applicable rules in `.windsurf/rules/`
3. **Plan the change** — Small, incremental steps

### During Changes

1. **Follow patterns** — Match existing code style
2. **Use design tokens** — Never hardcode spacing/colors
3. **Separate concerns** — Logic in `logic/`, UI in screen files
4. **Minimal diffs** — Touch as few files as possible

### After Changes

1. **Run verification**
   ```bash
   flutter analyze
   flutter test
   ```
2. **Fix any issues** — Before adding more features
3. **Summarize changes** — List files modified

---

## 6. Safe Development Practices

### DO

- ✅ Read files before editing
- ✅ Use existing patterns and utilities
- ✅ Add tests for new game logic
- ✅ Use design tokens from `lib/design/tokens.dart`
- ✅ Register new games in `GameRegistry`
- ✅ Run `flutter analyze` after changes
- ✅ Run `flutter test` after changes

### DO NOT

- ❌ Add Flutter imports to `logic/` directories
- ❌ Duplicate existing functionality
- ❌ Hardcode colors or spacing values
- ❌ Skip verification steps
- ❌ Make broad formatting changes
- ❌ Delete tests without explicit approval

---

## 7. Verification Steps

After every significant change, run:

### Step 1: Static Analysis

```bash
flutter analyze
```

**Expected:** No issues found

### Step 2: Unit Tests

```bash
flutter test
```

**Expected:** All tests pass

### Step 3: Manual Check (if UI changed)

```bash
flutter run -d chrome
```

**Expected:** App runs without errors

---

## 8. File Location Guidelines

| File Type | Location |
|-----------|----------|
| Game module | `lib/lib/games/<game_id>/` |
| Game logic | `lib/lib/games/<game_id>/logic/` |
| Game UI | `lib/lib/games/<game_id>/<game_id>_screen.dart` |
| Shared UI | `lib/lib/ui/` |
| Design tokens | `lib/lib/design/tokens.dart` |
| Theme | `lib/lib/theme/` |
| Tests | `test/` |

---

## 9. Common Tasks Reference

### Add a new game

1. Create folder: `lib/lib/games/<game_id>/`
2. Implement `GameModule` interface
3. Add logic in `logic/` subdirectory
4. Create screen widget
5. Register in `lib/lib/games/registry/game_registry.dart`
6. Add tests in `test/<game_id>_logic_test.dart`
7. Verify with `flutter analyze` and `flutter test`

### Fix a bug in game logic

1. Read the relevant logic file
2. Read existing tests
3. Add a failing test for the bug
4. Fix the logic
5. Verify all tests pass

### Add a shared UI component

1. Check if similar component exists in `lib/lib/ui/`
2. Create component using design tokens
3. Update imports in files that need it
4. Verify with `flutter analyze`

---

## 10. Error Recovery

### Analysis fails

1. Read the error messages
2. Fix each issue one at a time
3. Re-run `flutter analyze`

### Tests fail

1. Read the test failure output
2. Identify if it's a test issue or logic issue
3. Fix the root cause
4. Re-run `flutter test`

### App won't run

1. Run `flutter clean`
2. Run `flutter pub get`
3. Try running again
4. Check for missing imports or typos

---

## 11. Contact Points

- **Architecture questions** — See `docs/codebase_analysis.md`
- **Design system** — See `lib/lib/theme/` files
- **Adding games** — See workflow `/add-game-module`
- **Project overview** — See `README.md`
