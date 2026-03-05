import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/engine/rng.dart';
import 'package:calm_board_games/lib/games/block_puzzle/logic/block_board.dart';
import 'package:calm_board_games/lib/games/block_puzzle/logic/block_shapes.dart';

class _FakeRng implements Rng {
  final Queue<int> _ints;

  _FakeRng({Iterable<int> ints = const []}) : _ints = Queue<int>.of(ints);

  @override
  int nextInt(int max) {
    if (_ints.isEmpty) return 0;
    return _ints.removeFirst() % max;
  }

  @override
  double nextDouble() => 0.5;
}

void main() {
  group('BlockBoardLogic', () {
    test('new game creates empty board with shapes', () {
      final logic = BlockBoardLogic(rng: _FakeRng(ints: List.filled(10, 0)));
      final state = logic.newGame();

      expect(state.board.length, blockBoardSize);
      expect(state.board[0].length, blockBoardSize);
      expect(state.availableShapes.length, shapesPerRound);
      expect(state.score, 0);
      expect(state.gameOver, isFalse);
    });

    test('can place shape on empty board', () {
      final logic = BlockBoardLogic(rng: _FakeRng(ints: List.filled(10, 0)));
      final state = logic.newGame();
      final shape = state.availableShapes[0]!;

      expect(logic.canPlaceShape(state, shape, 0, 0), isTrue);
    });

    test('cannot place shape out of bounds', () {
      final logic = BlockBoardLogic(rng: _FakeRng(ints: List.filled(10, 0)));
      final state = logic.newGame();
      final shape = BlockShapes.all.firstWhere((s) => s.id == 'line3h');

      expect(logic.canPlaceShape(state, shape, 0, blockBoardSize - 1), isFalse);
    });

    test('placing shape updates board', () {
      final logic = BlockBoardLogic(rng: _FakeRng(ints: List.filled(20, 0)));
      var state = logic.newGame();

      final result = logic.placeShape(state, 0, 0, 0);

      expect(result.placed, isTrue);
      expect(result.state.board[0][0], isNot(0));
    });

    test('placing shape removes it from available', () {
      final logic = BlockBoardLogic(rng: _FakeRng(ints: List.filled(20, 0)));
      var state = logic.newGame();

      final result = logic.placeShape(state, 0, 0, 0);

      expect(result.state.availableShapes[0], isNull);
    });

    test('clearing a row gives score', () {
      final logic = BlockBoardLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      
      // Create a board with almost full row
      final board = List.generate(
        blockBoardSize,
        (_) => List.filled(blockBoardSize, 0),
      );
      for (var c = 0; c < blockBoardSize - 1; c++) {
        board[0][c] = 1;
      }

      final state = BlockBoardState.fromBoard(
        board: board,
        shapes: [BlockShapes.all[0], null, null], // single block
        score: 0,
      );

      final result = logic.placeShape(state, 0, 0, blockBoardSize - 1);

      expect(result.placed, isTrue);
      expect(result.linesCleared, 1);
      expect(result.scoreGained, greaterThan(1));
    });

    test('game over when no shapes fit', () {
      final logic = BlockBoardLogic(rng: _FakeRng(ints: List.filled(100, 2))); // line3h
      
      // Create an almost full board
      final board = List.generate(
        blockBoardSize,
        (r) => List.generate(blockBoardSize, (c) {
          // Leave only corners empty
          if (r == 0 && c == 0) return 0;
          return 1;
        }),
      );

      final shapes = [
        BlockShapes.all.firstWhere((s) => s.id == 'line3h'),
        BlockShapes.all.firstWhere((s) => s.id == 'line3h'),
        BlockShapes.all.firstWhere((s) => s.id == 'line3h'),
      ];

      final state = BlockBoardState.fromBoard(
        board: board,
        shapes: shapes,
        score: 0,
      );

      expect(logic.canPlaceAnyShape(state), isFalse);
    });
  });
}
