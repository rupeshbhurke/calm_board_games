import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/games/game_2048/logic/game_2048.dart';
import 'package:calm_board_games/lib/games/game_2048/logic/rng.dart';

class _FakeRng implements Rng {
  final Queue<int> _ints;
  final Queue<double> _doubles;

  _FakeRng({Iterable<int> ints = const [], Iterable<double> doubles = const []})
      : _ints = Queue<int>.of(ints),
        _doubles = Queue<double>.of(doubles);

  @override
  int nextInt(int max) {
    expect(_ints, isNotEmpty,
        reason: 'nextInt called without prepared values (max: $max)');
    final value = _ints.removeFirst();
    expect(value >= 0 && value < max, isTrue,
        reason: 'nextInt out of range (value: $value, max: $max)');
    return value;
  }

  @override
  double nextDouble() {
    expect(_doubles, isNotEmpty, reason: 'nextDouble called without values');
    final value = _doubles.removeFirst();
    expect(value >= 0 && value < 1, isTrue,
        reason: 'nextDouble out of [0, 1) (value: $value)');
    return value;
  }
}

void main() {
  group('2048 merge rules', () {
    test('row [2,2,2,0] moving left becomes [4,2,0,0] with single merge', () {
      final logic = Game2048Logic(rng: _FakeRng(ints: [2], doubles: [0.1]));
      final initial = Game2048State.fromBoard(
        board: [
          <int>[2, 2, 2, 0],
          <int>[0, 0, 0, 0],
          <int>[0, 0, 0, 0],
          <int>[0, 0, 0, 0],
        ],
        score: 0,
      );

      final result = logic.move(initial, MoveDirection.left);

      expect(result.boardChanged, isTrue);
      expect(result.scoreDelta, 4);
      expect(result.state.score, 4);
      expect(result.state.board[0], equals([4, 2, 0, 0]));
    });

    test('row [2,2,4,4] moving left becomes [4,8,0,0]', () {
      final logic = Game2048Logic(rng: _FakeRng(ints: [1], doubles: [0.2]));
      final initial = Game2048State.fromBoard(
        board: [
          <int>[2, 2, 4, 4],
          <int>[8, 16, 32, 64],
          <int>[128, 256, 512, 1024],
          <int>[4, 8, 16, 32],
        ],
        score: 10,
      );

      final result = logic.move(initial, MoveDirection.left);

      expect(result.boardChanged, isTrue);
      expect(result.scoreDelta, 12);
      expect(result.state.score, 22);
      expect(result.state.board[0], equals([4, 8, 0, 2]));
    });
  });

  group('Move outcomes', () {
    test('no movement keeps board and score unchanged', () {
      final logic = Game2048Logic();
      final initial = Game2048State.fromBoard(
        board: [
          <int>[2, 4, 8, 16],
          <int>[32, 64, 128, 256],
          <int>[512, 1024, 2, 4],
          <int>[8, 16, 32, 64],
        ],
        score: 500,
      );

      final result = logic.move(initial, MoveDirection.left);

      expect(result.boardChanged, isFalse);
      expect(result.scoreDelta, 0);
      expect(result.state.score, 500);
      for (var i = 0; i < 4; i++) {
        expect(result.state.board[i], equals(initial.board[i]));
      }
    });

    test('spawns tile with value 4 when rng >= 0.9 and detects win', () {
      final logic = Game2048Logic(rng: _FakeRng(ints: [1], doubles: [0.95]));
      final initial = Game2048State.fromBoard(
        board: [
          <int>[1024, 1024, 4, 0],
          <int>[8, 16, 32, 64],
          <int>[128, 256, 512, 1024],
          <int>[4, 8, 16, 32],
        ],
        score: 1000,
      );

      final result = logic.move(initial, MoveDirection.left);

      expect(result.state.won, isTrue);
      expect(result.state.score, 1000 + 2048);
      expect(result.state.board[0][0], 2048);
      // Newly spawned tile becomes 4 because rng double is 0.95.
      expect(result.state.board[0][3], 4);
    });

    test('detects loss when board has no moves', () {
      final logic = Game2048Logic();
      final initial = Game2048State.fromBoard(
        board: [
          <int>[2, 4, 2, 4],
          <int>[4, 2, 4, 2],
          <int>[2, 4, 2, 4],
          <int>[4, 2, 4, 2],
        ],
        score: 300,
      );

      final result = logic.move(initial, MoveDirection.left);

      expect(result.boardChanged, isFalse);
      expect(result.state.lost, isTrue);
    });
  });
}
