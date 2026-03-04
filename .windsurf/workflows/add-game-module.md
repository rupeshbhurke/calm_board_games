---
description: Add a new game module to the suite
---

# /add-game-module

**Objective:** Create a new game plugin following the established architecture.

---

## Prerequisites

- Game ID determined (snake_case, e.g., `sudoku`, `minesweeper`)
- Game category known (puzzle, logic, strategy, casual)
- Basic game rules understood

---

## Steps

### Step 1: Create module folder structure

Create the following structure:

```
lib/lib/games/<game_id>/
├── <game_id>_module.dart
├── <game_id>_screen.dart
└── logic/
    └── <game_id>.dart
```

### Step 2: Implement GameModule

Create `<game_id>_module.dart`:

```dart
import 'package:flutter/widgets.dart';

import '../registry/game_module.dart';
import '<game_id>_screen.dart';

class <GameName>Module implements GameModule {
  const <GameName>Module();

  @override
  GameMetadata get metadata => const GameMetadata(
    id: '<game_id>',
    title: '<Game Name>',
    tagline: '<Short description>',
    category: GameCategory.<category>,
  );

  @override
  Widget buildGameScreen() => const <GameName>Screen();
}
```

### Step 3: Create placeholder screen

Create `<game_id>_screen.dart`:

```dart
import 'package:flutter/material.dart';

import '../../design/tokens.dart';

class <GameName>Screen extends StatefulWidget {
  const <GameName>Screen({super.key});

  @override
  State<<GameName>Screen> createState() => _<GameName>ScreenState();
}

class _<GameName>ScreenState extends State<<GameName>Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('<Game Name>')),
      body: const Center(
        child: Text('Coming soon!'),
      ),
    );
  }
}
```

### Step 4: Create placeholder logic

Create `logic/<game_id>.dart`:

```dart
// Pure Dart - NO Flutter imports

class <GameName>State {
  // Game state fields
  
  const <GameName>State._();
  
  factory <GameName>State.initial() {
    return const <GameName>State._();
  }
}

class <GameName>Logic {
  // Game logic methods
}
```

### Step 5: Register in GameRegistry

Edit `lib/lib/games/registry/game_registry.dart`:

1. Add import:
```dart
import '../<game_id>/<game_id>_module.dart';
```

2. Add to modules list:
```dart
modules: const [
  SlidingPuzzleModule(),
  Game2048Module(),
  <GameName>Module(),  // Add here
],
```

### Step 6: Create test file

Create `test/<game_id>_logic_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/games/<game_id>/logic/<game_id>.dart';

void main() {
  group('<Game Name> rules', () {
    test('initial state is valid', () {
      final state = <GameName>State.initial();
      // Add assertions
    });
  });
}
```

---

## Verification

// turbo
```bash
flutter analyze
```

// turbo
```bash
flutter test
```

```bash
flutter run -d chrome
```

Navigate to hub and verify new game appears.

---

## Commit Guidance

```
Add <game_id> module

- Create <GameName>Module implementing GameModule
- Add placeholder screen and logic
- Register in GameRegistry
- Add initial test file
```

---

## Checklist

- [ ] Module folder created at correct location
- [ ] GameModule interface implemented
- [ ] Metadata has correct id, title, tagline, category
- [ ] Screen uses design tokens
- [ ] Logic file has no Flutter imports
- [ ] Module registered in GameRegistry
- [ ] Test file created
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Game appears in hub
