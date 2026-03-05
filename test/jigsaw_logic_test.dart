import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/engine/rng.dart';
import 'package:calm_board_games/lib/games/jigsaw/logic/jigsaw_engine.dart';

class _FakeRng implements Rng {
  final Queue<int> _ints;
  final Queue<double> _doubles;

  _FakeRng({Iterable<int> ints = const [], Iterable<double> doubles = const []})
      : _ints = Queue<int>.of(ints),
        _doubles = Queue<double>.of(doubles);

  @override
  int nextInt(int max) {
    if (_ints.isEmpty) return 0;
    return _ints.removeFirst() % max;
  }

  @override
  double nextDouble() {
    if (_doubles.isEmpty) return 0.5;
    return _doubles.removeFirst();
  }
}

void main() {
  group('JigsawLogic', () {
    test('new game creates correct number of pieces', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      final state = logic.newGame(difficulty: JigsawDifficulty.easy);

      expect(state.pieces.length, 9); // 3x3
      expect(state.difficulty, JigsawDifficulty.easy);
      expect(state.isSolved, isFalse);
    });

    test('medium difficulty creates 16 pieces', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      final state = logic.newGame(difficulty: JigsawDifficulty.medium);

      expect(state.pieces.length, 16); // 4x4
    });

    test('movePiece updates position', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      var state = logic.newGame(difficulty: JigsawDifficulty.easy);

      final pieceId = state.pieces.first.id;
      final result = logic.movePiece(state, pieceId, 100, 200);

      expect(result.state.pieces.firstWhere((p) => p.id == pieceId).currentX, 100);
      expect(result.state.pieces.firstWhere((p) => p.id == pieceId).currentY, 200);
    });

    test('dropPiece snaps when near correct position', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      var state = logic.newGame(difficulty: JigsawDifficulty.easy, boardSize: 300);

      // Find piece that belongs at (0,0)
      final piece = state.pieces.firstWhere((p) => p.correctRow == 0 && p.correctCol == 0);
      
      // Drop it close to its correct position
      final result = logic.dropPiece(state, piece.id, 5, 5);

      expect(result.snapped, isTrue);
      expect(result.state.pieces.firstWhere((p) => p.id == piece.id).isPlaced, isTrue);
    });

    test('dropPiece does not snap when far from correct position', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      var state = logic.newGame(difficulty: JigsawDifficulty.easy, boardSize: 300);

      final piece = state.pieces.firstWhere((p) => p.correctRow == 0 && p.correctCol == 0);
      
      // Drop it far from its correct position
      final result = logic.dropPiece(state, piece.id, 200, 200);

      expect(result.snapped, isFalse);
      expect(result.state.pieces.firstWhere((p) => p.id == piece.id).isPlaced, isFalse);
    });

    test('cannot move already placed piece', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      var state = logic.newGame(difficulty: JigsawDifficulty.easy, boardSize: 300);

      final piece = state.pieces.firstWhere((p) => p.correctRow == 0 && p.correctCol == 0);
      
      // Place the piece
      state = logic.dropPiece(state, piece.id, 5, 5).state;
      expect(state.pieces.firstWhere((p) => p.id == piece.id).isPlaced, isTrue);
      
      // Try to move it
      final result = logic.movePiece(state, piece.id, 100, 100);
      expect(result.state.pieces.firstWhere((p) => p.id == piece.id).currentX, 0);
    });

    test('puzzle is solved when all pieces placed', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      var state = logic.newGame(difficulty: JigsawDifficulty.easy, boardSize: 300);

      // Place all pieces
      for (final piece in state.pieces) {
        final targetX = piece.correctCol * state.pieceSize;
        final targetY = piece.correctRow * state.pieceSize;
        state = logic.dropPiece(state, piece.id, targetX + 5, targetY + 5).state;
      }

      expect(state.isSolved, isTrue);
    });

    test('placedCount tracks placed pieces', () {
      final logic = JigsawLogic(rng: _FakeRng(ints: List.filled(100, 0), doubles: List.filled(100, 0.5)));
      var state = logic.newGame(difficulty: JigsawDifficulty.easy, boardSize: 300);

      expect(state.placedCount, 0);

      final piece = state.pieces.first;
      final targetX = piece.correctCol * state.pieceSize;
      final targetY = piece.correctRow * state.pieceSize;
      state = logic.dropPiece(state, piece.id, targetX + 5, targetY + 5).state;

      expect(state.placedCount, 1);
    });
  });
}
