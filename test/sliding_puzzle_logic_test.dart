import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/engine/rng.dart';
import 'package:calm_board_games/lib/games/sliding_puzzle/logic/sliding_puzzle.dart';

class _FakeRng implements Rng {
  final Queue<int> _ints;
  final Queue<double> _doubles;

  _FakeRng({Iterable<int> ints = const [], Iterable<double> doubles = const []})
      : _ints = Queue<int>.of(ints),
        _doubles = Queue<double>.of(doubles);

  @override
  int nextInt(int max) {
    if (_ints.isEmpty) return 0;
    final value = _ints.removeFirst();
    return value % max;
  }

  @override
  double nextDouble() {
    if (_doubles.isEmpty) return 0.0;
    final value = _doubles.removeFirst();
    if (value >= 0 && value < 1) return value;
    return value % 1;
  }
}

void main() {
  group('SlidingPuzzleLogic', () {
    test('new game creates solvable board with empty tile', () {
      final logic = SlidingPuzzleLogic(rng: _FakeRng(ints: List.filled(400, 0)));
      final state = logic.newGame();

      expect(state.tiles.length, SlidingPuzzleState.tileCount);
      expect(state.tiles.contains(0), isTrue);
      expect(state.moveCount, 0);
      expect(state.solved, isFalse);
    });

    test('moving adjacent tile swaps with empty slot', () {
      final logic = SlidingPuzzleLogic(rng: _FakeRng());
      final state = SlidingPuzzleState.fromTiles(const [
        1, 2, 3, 4,
        5, 6, 7, 8,
        9, 10, 11, 12,
        13, 0, 14, 15,
      ]);

      final result = logic.moveTile(state, 14);

      expect(result.moved, isTrue);
      expect(result.state.tiles.sublist(12), equals(const [13, 14, 0, 15]));
      expect(result.state.moveCount, 1);
    });

    test('non-adjacent tile does not move', () {
      final logic = SlidingPuzzleLogic(rng: _FakeRng());
      final state = SlidingPuzzleState.fromTiles(const [
        1, 2, 3, 4,
        5, 6, 7, 8,
        9, 10, 11, 12,
        0, 13, 14, 15,
      ]);

      final result = logic.moveTile(state, 15);

      expect(result.moved, isFalse);
      expect(result.state.tiles, same(state.tiles));
      expect(result.state.moveCount, state.moveCount);
    });

    test('moveTile updates solved flag when puzzle complete', () {
      final logic = SlidingPuzzleLogic(rng: _FakeRng());
      final state = SlidingPuzzleState.fromTiles(const [
        1, 2, 3, 4,
        5, 6, 7, 8,
        9, 10, 11, 12,
        13, 14, 0, 15,
      ], moveCount: 10);

      final result = logic.moveTile(state, 15);

      expect(result.moved, isTrue);
      expect(result.state.solved, isTrue);
      expect(result.state.moveCount, 11);
      expect(result.state.tiles.last, 0);
    });
  });
}
