---
description: Implement pure Dart game logic
---

# /implement-game-logic

**Objective:** Add game rules and state management as pure Dart code.

---

## Prerequisites

- Game module exists (run `/add-game-module` first)
- Game rules are defined
- Test cases identified

---

## Steps

### Step 1: Design state class

In `logic/<game_id>.dart`, define immutable state:

```dart
class <GameName>State {
  final List<List<int>> board;
  final int score;
  final bool won;
  final bool lost;

  const <GameName>State._({
    required this.board,
    required this.score,
    required this.won,
    required this.lost,
  });

  factory <GameName>State.initial() {
    // Create initial game state
  }

  factory <GameName>State.fromBoard({
    required List<List<int>> board,
    required int score,
  }) {
    // Create state from board (for testing)
  }
}
```

### Step 2: Define move/action types

```dart
enum MoveDirection { up, down, left, right }
// or
enum Action { tap, swipe, rotate }
```

### Step 3: Implement logic class

```dart
class <GameName>Logic {
  final Rng rng;  // If randomness needed

  <GameName>Logic({Rng? rng}) : rng = rng ?? RandomRng();

  <GameName>State newGame() {
    return <GameName>State.initial();
  }

  <GameName>MoveResult move(<GameName>State current, MoveDirection dir) {
    // 1. Clone state
    // 2. Apply move
    // 3. Check win/lose
    // 4. Return new immutable state
  }
}
```

### Step 4: Create move result class

```dart
class <GameName>MoveResult {
  final <GameName>State state;
  final int scoreDelta;
  final bool boardChanged;

  const <GameName>MoveResult({
    required this.state,
    required this.scoreDelta,
    required this.boardChanged,
  });
}
```

### Step 5: Add RNG abstraction (if needed)

Create `logic/rng.dart`:

```dart
import 'dart:math';

abstract class Rng {
  int nextInt(int max);
  double nextDouble();
}

class RandomRng implements Rng {
  final Random _random;

  RandomRng([Random? random]) : _random = random ?? Random();

  @override
  int nextInt(int max) => _random.nextInt(max);

  @override
  double nextDouble() => _random.nextDouble();
}
```

### Step 6: Write tests

In `test/<game_id>_logic_test.dart`:

```dart
import 'dart:collection';
import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/games/<game_id>/logic/<game_id>.dart';
import 'package:calm_board_games/lib/games/<game_id>/logic/rng.dart';

class _FakeRng implements Rng {
  final Queue<int> _ints;
  final Queue<double> _doubles;

  _FakeRng({
    Iterable<int> ints = const [],
    Iterable<double> doubles = const [],
  }) : _ints = Queue.of(ints),
       _doubles = Queue.of(doubles);

  @override
  int nextInt(int max) => _ints.removeFirst();

  @override
  double nextDouble() => _doubles.removeFirst();
}

void main() {
  group('<Game> rules', () {
    test('rule 1 works correctly', () {
      final logic = <GameName>Logic(rng: _FakeRng(ints: [0], doubles: [0.5]));
      final state = <GameName>State.fromBoard(
        board: [/* test board */],
        score: 0,
      );

      final result = logic.move(state, MoveDirection.left);

      expect(result.boardChanged, isTrue);
      // More assertions
    });
  });

  group('<Game> win/lose', () {
    test('detects win condition', () {
      // Test win
    });

    test('detects lose condition', () {
      // Test lose
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
flutter test test/<game_id>_logic_test.dart
```

---

## Commit Guidance

```
Implement <game_id> logic

- Add <GameName>State with immutable board state
- Implement move/action processing
- Add win/lose detection
- Unit tests for core rules
```

---

## Checklist

- [ ] No Flutter imports in logic files
- [ ] State class is immutable
- [ ] Logic methods return new state (no mutation)
- [ ] RNG is injectable for testing
- [ ] Tests cover core rules
- [ ] Tests cover win condition
- [ ] Tests cover lose condition
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
