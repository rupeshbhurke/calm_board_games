---
description: Implement pure Dart game logic for a board/puzzle game
---

# Skill: Implement Game Logic

**Purpose:** Create testable, pure Dart game logic.

---

## Principles

1. **No Flutter dependencies** — Logic must be pure Dart
2. **Immutable state** — Never mutate, always return new state
3. **Injectable dependencies** — Use interfaces for randomness
4. **Testable design** — All scenarios reproducible

---

## State Class Template

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

  // Factory for new game
  factory <GameName>State.initial(Rng rng) {
    final board = _emptyBoard();
    // Initialize board
    return <GameName>State._(
      board: _freezeBoard(board),
      score: 0,
      won: false,
      lost: false,
    );
  }

  // Factory for testing
  factory <GameName>State.fromBoard({
    required List<List<int>> board,
    required int score,
  }) {
    return <GameName>State._(
      board: _freezeBoard(board),
      score: score,
      won: _checkWin(board),
      lost: _checkLoss(board),
    );
  }
}
```

---

## Logic Class Template

```dart
class <GameName>Logic {
  final Rng rng;

  <GameName>Logic({Rng? rng}) : rng = rng ?? RandomRng();

  <GameName>State newGame() => <GameName>State.initial(rng);

  <GameName>MoveResult move(<GameName>State current, MoveDirection dir) {
    // 1. Clone board for mutation
    final working = _cloneBoard(current.board);
    var scoreDelta = 0;
    var changed = false;

    // 2. Apply move logic
    // ...

    // 3. Check if anything changed
    if (!changed) {
      return <GameName>MoveResult(
        state: current,
        scoreDelta: 0,
        boardChanged: false,
      );
    }

    // 4. Spawn new elements if needed
    // ...

    // 5. Create new immutable state
    final newState = <GameName>State._(
      board: _freezeBoard(working),
      score: current.score + scoreDelta,
      won: _checkWin(working),
      lost: _checkLoss(working),
    );

    return <GameName>MoveResult(
      state: newState,
      scoreDelta: scoreDelta,
      boardChanged: true,
    );
  }
}
```

---

## RNG Interface

```dart
// rng.dart
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

---

## Helper Functions

```dart
List<List<int>> _emptyBoard() =>
    List.generate(4, (_) => List.filled(4, 0));

List<List<int>> _cloneBoard(List<List<int>> board) =>
    [for (final row in board) List<int>.from(row)];

List<List<int>> _freezeBoard(List<List<int>> board) =>
    List<List<int>>.unmodifiable(
      board.map((row) => List<int>.unmodifiable(List<int>.from(row))),
    );

bool _checkWin(List<List<int>> board) {
  // Check win condition
  return false;
}

bool _checkLoss(List<List<int>> board) {
  // Check if no moves available
  return false;
}
```

---

## Test Template

```dart
import 'dart:collection';
import 'package:flutter_test/flutter_test.dart';

class _FakeRng implements Rng {
  final Queue<int> _ints;
  final Queue<double> _doubles;

  _FakeRng({
    Iterable<int> ints = const [],
    Iterable<double> doubles = const [],
  }) : _ints = Queue.of(ints),
       _doubles = Queue.of(doubles);

  @override
  int nextInt(int max) {
    final value = _ints.removeFirst();
    assert(value >= 0 && value < max);
    return value;
  }

  @override
  double nextDouble() {
    final value = _doubles.removeFirst();
    assert(value >= 0 && value < 1);
    return value;
  }
}

void main() {
  group('<Game> rules', () {
    test('specific scenario', () {
      final logic = <GameName>Logic(
        rng: _FakeRng(ints: [0, 1], doubles: [0.5]),
      );
      
      final state = <GameName>State.fromBoard(
        board: [
          <int>[1, 2, 3, 4],
          // ...
        ],
        score: 0,
      );

      final result = logic.move(state, MoveDirection.left);

      expect(result.boardChanged, isTrue);
      expect(result.state.board[0], equals([...]));
    });
  });
}
```

---

## Checklist

- [ ] No Flutter imports
- [ ] State class is immutable
- [ ] All fields are final
- [ ] Factory constructors for creation
- [ ] Logic methods return new state
- [ ] RNG is injectable
- [ ] Helper functions are private
- [ ] Tests use fake RNG
- [ ] Tests cover all rules
