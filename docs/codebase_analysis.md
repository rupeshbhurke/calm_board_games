# Codebase Analysis — Calm Board Suite

**Date:** March 2026  
**Scope:** Full repository analysis

---

## 1. Overall Architecture Pattern

The project follows a **Plugin-Based Module Architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                     App Shell                           │
│  (ProviderScope → MaterialApp → Theme → HomeScreen)     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Game Registry                        │
│  (Central registration of all GameModule instances)     │
└─────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │ Game A   │    │ Game B   │    │ Game N   │
    │ Module   │    │ Module   │    │ Module   │
    └──────────┘    └──────────┘    └──────────┘
```

**Key patterns:**
- **Hub + Plugins**: Central hub shell with pluggable game modules
- **Registry Pattern**: Explicit registration in `GameRegistry`
- **Riverpod State Management**: Providers for theme and registry
- **Pure Logic Separation**: Game logic in `logic/` subdirectories, UI separate

---

## 2. Module Organization

### Directory Structure

```
calm_board_games/
├── lib/
│   ├── main.dart                    # Entry point
│   └── lib/
│       ├── app/
│       │   └── app_shell.dart       # MaterialApp wrapper
│       ├── design/
│       │   └── tokens.dart          # Design token barrel
│       ├── games/
│       │   ├── registry/
│       │   │   ├── game_module.dart # GameModule interface
│       │   │   └── game_registry.dart
│       │   ├── sliding_puzzle/
│       │   │   ├── sliding_puzzle_module.dart
│       │   │   └── ui/
│       │   └── game_2048/
│       │       ├── game_2048_module.dart
│       │       ├── game_2048_screen.dart
│       │       └── logic/
│       │           ├── game_2048.dart
│       │           └── rng.dart
│       ├── hub/
│       │   └── home_screen.dart     # Hub home
│       ├── theme/
│       │   ├── calm_theme.dart
│       │   ├── palette.dart
│       │   └── spacing.dart
│       └── ui/
│           └── cards/
│               └── game_card.dart   # Shared card component
├── test/
│   ├── game_2048_logic_test.dart
│   ├── widget_test.dart
│   └── test/
│       └── smoke_test.dart
└── pubspec.yaml
```

### Module Boundaries

| Layer | Location | Purpose |
|-------|----------|---------|
| **App Shell** | `lib/app/` | MaterialApp, theme, top-level routing |
| **Hub** | `lib/hub/` | Home screen, category sections |
| **Games** | `lib/games/<game_id>/` | Per-game modules |
| **Registry** | `lib/games/registry/` | Module interface, registration |
| **Theme** | `lib/theme/` | Colors, spacing, theme data |
| **Shared UI** | `lib/ui/` | Reusable components (cards, etc.) |
| **Design Tokens** | `lib/design/` | Token barrel exports |

---

## 3. UI vs Logic Separation

### Current State: ✅ Good Separation

**Game 2048 Example:**
- `logic/game_2048.dart` — Pure Dart, no Flutter imports, immutable state
- `logic/rng.dart` — Injectable RNG for deterministic testing
- `game_2048_screen.dart` — Flutter UI, consumes logic

**Pattern:**
```
GameModule
    ├── <game_id>_module.dart      # Metadata + entry point
    ├── <game_id>_screen.dart      # UI (StatefulWidget)
    └── logic/
        ├── <game_id>.dart         # Pure game logic
        └── rng.dart               # Optional: RNG abstraction
```

### Recommendation
- Maintain this pattern for all new games
- Logic files must have **zero Flutter imports**
- UI files import logic but logic never imports UI

---

## 4. Shared Utilities/Components

### Current Shared Components

| Component | Location | Usage |
|-----------|----------|-------|
| `GameCard` | `lib/ui/cards/game_card.dart` | Hub home screen |
| `Spacing` | `lib/theme/spacing.dart` | All UI files |
| `CalmPalette` | `lib/theme/palette.dart` | All UI files |
| `CalmTheme` | `lib/theme/calm_theme.dart` | App shell |
| `tokens.dart` | `lib/design/tokens.dart` | Barrel for spacing/palette |

### Missing/Recommended Shared Components

| Candidate | Current State | Recommendation |
|-----------|---------------|----------------|
| Dialog helpers | Inline in game screens | Extract to `lib/ui/dialogs/` |
| Score display | Per-game implementation | Extract reusable `ScoreChip` |
| Board grid | Per-game implementation | Keep per-game (too specific) |

---

## 5. Dependency Usage

### pubspec.yaml Analysis

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  go_router: ^17.1.0          # Not yet used in code
  flutter_riverpod: ^3.2.1    # Used for state management
  collection: ^1.19.1         # Standard collections

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^6.0.0
```

### Observations

- **go_router** is declared but not actively used (routing is via `Navigator.push`)
- **flutter_riverpod** is used correctly for providers
- **No persistence layer** yet (planned for future milestones)

---

## 6. Routing/Navigation Patterns

### Current Pattern: Simple Navigator Push

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => module.buildGameScreen()),
);
```

### Observations

- No deep linking
- No named routes
- Simple push/pop navigation
- Adequate for current scope

### Recommendation

- Keep simple for now
- If persistence or deep links needed, migrate to `go_router`

---

## 7. Testing Coverage

### Current Tests

| File | Type | Coverage |
|------|------|----------|
| `game_2048_logic_test.dart` | Unit | 2048 merge rules, move outcomes, win/loss |
| `widget_test.dart` | Widget | Empty (placeholder) |
| `smoke_test.dart` | Unit | Trivial (1+1=2) |

### Coverage Assessment

- **2048 Logic**: ✅ Good coverage
- **Sliding Puzzle Logic**: ❌ No tests (stub module)
- **Widget Tests**: ❌ Minimal
- **Integration Tests**: ❌ None

### Recommendations

1. Add logic tests for each new game module
2. Consider widget tests for critical UI flows
3. Add integration tests before release

---

## 8. Potential Concerns

### 8.1 Duplicated Logic Risk

**Current:** No duplication detected  
**Risk:** As games grow, common patterns may be re-implemented

**Mitigation:**
- Create `lib/engine/` for shared game primitives (grid helpers, move validators)
- Document when to extract to shared utilities

### 8.2 Module Boundary Clarity

**Current:** Clear boundaries maintained  
**Risk:** New developers may place files incorrectly

**Mitigation:**
- Document folder structure in README
- Add Windsurf rules to enforce boundaries

### 8.3 UI/Logic Coupling

**Current:** Well separated  
**Risk:** Future developers may add Flutter imports to logic files

**Mitigation:**
- Add lint rules or Windsurf rules to flag Flutter imports in `logic/` dirs

### 8.4 Missing Abstraction Layer

**Current:** No shared engine layer  
**Recommendation:** Create `lib/engine/` when patterns emerge (e.g., grid utilities, tile systems)

### 8.5 Test Coverage Gaps

**Current:** Only 2048 logic tested  
**Recommendation:** Require tests for all game rule logic

---

## 9. Summary

| Aspect | Status | Notes |
|--------|--------|-------|
| Architecture | ✅ Good | Plugin-based, clear boundaries |
| UI/Logic Separation | ✅ Good | Logic is pure Dart |
| Shared Components | ⚠️ Partial | Some candidates for extraction |
| Dependencies | ✅ Minimal | go_router unused but declared |
| Navigation | ✅ Simple | Adequate for scope |
| Testing | ⚠️ Partial | Logic tests exist, widget tests minimal |
| Documentation | ⚠️ Needs work | README exists but needs expansion |

---

## 10. Recommendations Summary

1. **Maintain plugin architecture** — enforce via rules
2. **Keep logic pure** — no Flutter in `logic/` directories
3. **Extract shared UI** — dialogs, score chips when patterns repeat
4. **Create engine layer** — when grid/tile patterns emerge
5. **Require tests** — for all game rule logic
6. **Document thoroughly** — README, Windsurf rules, workflows
