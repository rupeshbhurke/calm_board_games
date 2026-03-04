# Calm Board Suite

An **offline single-player board/puzzle game suite** built with Flutter, targeting Android and Web.

---

## 1. Project Overview

Calm Board Suite is a collection of classic board and puzzle games with a calm, minimal aesthetic. The project uses a **plugin-based architecture** where each game is a self-contained module registered in a central hub.

**Current games:**
- **Sliding Puzzle** — Slide tiles into place
- **2048** — Merge tiles to reach 2048

**Design philosophy:**
- Pastel colors, rounded corners, minimal UI
- Golden-ratio spacing tokens (8/13/21/34)
- Offline-first, no accounts required

---

## 2. High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     App Shell                           │
│         (ProviderScope → MaterialApp → Theme)           │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Game Registry                        │
│        (Central registration of GameModule instances)   │
└─────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │ Sliding  │    │  2048    │    │ Future   │
    │ Puzzle   │    │  Game    │    │ Games    │
    └──────────┘    └──────────┘    └──────────┘
```

**Key patterns:**
- **Hub + Plugins**: Central hub shell with pluggable game modules
- **Registry Pattern**: Explicit registration in `GameRegistry`
- **Riverpod**: State management via providers
- **Pure Logic Separation**: Game logic has no Flutter dependencies

---

## 3. Folder Structure

```
lib/
├── main.dart                    # Entry point
└── lib/
    ├── app/
    │   └── app_shell.dart       # MaterialApp wrapper
    ├── design/
    │   └── tokens.dart          # Design token barrel (exports spacing/palette)
    ├── games/
    │   ├── registry/
    │   │   ├── game_module.dart # GameModule interface
    │   │   └── game_registry.dart
    │   ├── sliding_puzzle/      # Sliding puzzle game
    │   │   ├── sliding_puzzle_module.dart
    │   │   └── ui/
    │   └── game_2048/           # 2048 game
    │       ├── game_2048_module.dart
    │       ├── game_2048_screen.dart
    │       └── logic/
    │           ├── game_2048.dart
    │           └── rng.dart
    ├── hub/
    │   └── home_screen.dart     # Hub home with game categories
    ├── theme/
    │   ├── calm_theme.dart      # Light/dark theme definitions
    │   ├── palette.dart         # Color constants
    │   └── spacing.dart         # Spacing/radius/motion constants
    └── ui/
        └── cards/
            └── game_card.dart   # Shared game card component
```

---

## 4. Game Plugin System

### GameModule Interface

Every game implements the `GameModule` interface:

```dart
abstract class GameModule {
  GameMetadata get metadata;
  Widget buildGameScreen();
}

class GameMetadata {
  final String id;        // snake_case identifier
  final String title;     // Display name
  final String tagline;   // Short description
  final GameCategory category;  // puzzle, logic, strategy, casual
}
```

### GameRegistry

Games are registered explicitly in `lib/games/registry/game_registry.dart`:

```dart
final gameRegistryProvider = Provider<GameRegistry>((ref) {
  return GameRegistry(
    modules: const [
      SlidingPuzzleModule(),
      Game2048Module(),
    ],
  );
});
```

---

## 5. How to Add a New Game Module

### Step 1: Create the module folder

```
lib/games/<game_id>/
├── <game_id>_module.dart
├── <game_id>_screen.dart
└── logic/
    └── <game_id>.dart
```

### Step 2: Implement GameModule

```dart
class MyGameModule implements GameModule {
  const MyGameModule();

  @override
  GameMetadata get metadata => const GameMetadata(
    id: 'my_game',
    title: 'My Game',
    tagline: 'A fun game.',
    category: GameCategory.puzzle,
  );

  @override
  Widget buildGameScreen() => const MyGameScreen();
}
```

### Step 3: Implement game logic (pure Dart)

```dart
// lib/games/my_game/logic/my_game.dart
// NO Flutter imports here!

class MyGameState {
  // Immutable game state
}

class MyGameLogic {
  MyGameState move(MyGameState state, Direction dir) {
    // Pure logic
  }
}
```

### Step 4: Implement UI screen

```dart
// lib/games/my_game/my_game_screen.dart
import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import 'logic/my_game.dart';

class MyGameScreen extends StatefulWidget {
  // UI implementation using design tokens
}
```

### Step 5: Register in GameRegistry

```dart
// lib/games/registry/game_registry.dart
import '../my_game/my_game_module.dart';

modules: const [
  SlidingPuzzleModule(),
  Game2048Module(),
  MyGameModule(),  // Add here
],
```

### Step 6: Add tests

```dart
// test/my_game_logic_test.dart
void main() {
  group('My Game rules', () {
    test('move works correctly', () {
      // Test pure logic
    });
  });
}
```

### Step 7: Verify

```bash
flutter analyze
flutter test
flutter run -d chrome
```

---

## 6. Development Prerequisites

- **Flutter SDK** (stable channel, 3.10+)
- **Dart SDK** (included with Flutter)
- **Android Studio** (for Android development)
- **Chrome** (for web development)
- **VS Code or Windsurf IDE** (recommended)

### Install Flutter

```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Windows (PowerShell)
git clone https://github.com/flutter/flutter.git
$env:PATH += ";$(pwd)\flutter\bin"

# Verify
flutter doctor
```

---

## 7. Running the Project

### Get dependencies

```bash
cd calm_board_games
flutter pub get
```

### Run on Web (Chrome)

```bash
flutter run -d chrome
```

### Run on Android

```bash
# Start emulator or connect device
flutter run -d android
```

### Run analysis

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

---

## 8. Running Tests

### All tests

```bash
flutter test
```

### Specific test file

```bash
flutter test test/game_2048_logic_test.dart
```

### With coverage

```bash
flutter test --coverage
```

---

## 9. Design System Overview

### Spacing Tokens

From `lib/theme/spacing.dart`:

```dart
class Spacing {
  // Golden-ratio-ish spacing scale
  static const double s8 = 8;
  static const double s13 = 13;
  static const double s21 = 21;
  static const double s34 = 34;

  // Radii
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r24 = 24;

  // Motion (milliseconds)
  static const int ms180 = 180;
  static const int ms220 = 220;
  static const int ms260 = 260;
}
```

### Color Palette

From `lib/theme/palette.dart`:

```dart
class CalmPalette {
  static const Color bg = Color(0xFFF7F7F9);      // Background
  static const Color surface = Color(0xFFFFFFFF); // Cards
  static const Color text = Color(0xFF2E2E33);    // Primary text
  static const Color subtext = Color(0xFF5C5C66); // Secondary text
  static const Color primary = Color(0xFFA8DADC); // Soft teal
  static const Color secondary = Color(0xFFB8E0D2); // Mint
  static const Color accent = Color(0xFFFFD6A5);  // Peach
  static const Color stroke = Color(0xFFE8E8EE);  // Borders
}
```

### Using Tokens

Import the barrel file:

```dart
import '../../design/tokens.dart';

// Then use:
padding: EdgeInsets.all(Spacing.s21),
color: CalmPalette.primary,
borderRadius: BorderRadius.circular(Spacing.r16),
```

---

## 10. Key Engineering Principles

### No Duplication

- If logic exists in one place, do not reimplement it
- Extract shared patterns to `lib/ui/` or `lib/engine/`
- Use design tokens instead of magic numbers

### Plugin Modules

- Each game is a self-contained module
- Games implement `GameModule` interface
- Registration is explicit in `GameRegistry`

### Separation of Concerns

- **Logic**: Pure Dart, no Flutter imports, testable
- **UI**: Flutter widgets, uses logic classes
- **Theme**: Centralized tokens and styles

### Immutable State

- Game state classes should be immutable
- Use factory constructors and `copyWith` patterns
- Return new state from logic operations

### Testability

- Logic must be testable without Flutter
- Use injectable dependencies (e.g., RNG)
- Write tests for all game rules

---

## 11. Future Milestones

- **Persistence**: Save/restore game state (Hive/SharedPreferences)
- **More games**: Sudoku, Minesweeper, Chess puzzles
- **Settings**: Theme toggle, accessibility options
- **Achievements**: Track progress across games

---

## 12. Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the architecture patterns
4. Add tests for new logic
5. Run `flutter analyze` and `flutter test`
6. Submit a pull request

---

## 13. License

MIT License — see LICENSE file for details.
