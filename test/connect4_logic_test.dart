import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/games/connect4/logic/connect4_game.dart';

void main() {
  group('Connect4Logic', () {
    test('new game creates empty board', () {
      final logic = Connect4Logic();
      final state = logic.newGame();

      expect(state.board.length, connect4Rows);
      expect(state.board[0].length, connect4Cols);
      expect(state.currentPlayer, Player.red);
      expect(state.result, GameResult.ongoing);
    });

    test('disc drops to bottom of empty column', () {
      final logic = Connect4Logic();
      var state = logic.newGame();

      final result = logic.dropDisc(state, 3);

      expect(result.valid, isTrue);
      expect(result.placedRow, connect4Rows - 1);
      expect(result.state.board[connect4Rows - 1][3], Player.red);
    });

    test('disc stacks on top of previous disc', () {
      final logic = Connect4Logic();
      var state = logic.newGame();

      state = logic.dropDisc(state, 3).state;
      final result = logic.dropDisc(state, 3);

      expect(result.valid, isTrue);
      expect(result.placedRow, connect4Rows - 2);
      expect(result.state.board[connect4Rows - 2][3], Player.yellow);
    });

    test('players alternate turns', () {
      final logic = Connect4Logic();
      var state = logic.newGame();

      expect(state.currentPlayer, Player.red);
      state = logic.dropDisc(state, 0).state;
      expect(state.currentPlayer, Player.yellow);
      state = logic.dropDisc(state, 1).state;
      expect(state.currentPlayer, Player.red);
    });

    test('invalid column returns invalid result', () {
      final logic = Connect4Logic();
      final state = logic.newGame();

      expect(logic.dropDisc(state, -1).valid, isFalse);
      expect(logic.dropDisc(state, connect4Cols).valid, isFalse);
    });

    test('full column returns invalid result', () {
      final logic = Connect4Logic();
      var state = logic.newGame();

      for (var i = 0; i < connect4Rows; i++) {
        final result = logic.dropDisc(state, 0);
        expect(result.valid, isTrue);
        state = result.state;
      }

      final result = logic.dropDisc(state, 0);
      expect(result.valid, isFalse);
    });

    test('horizontal win detected', () {
      final board = List.generate(
        connect4Rows,
        (_) => List.filled(connect4Cols, Player.none),
      );
      board[5][0] = Player.red;
      board[5][1] = Player.red;
      board[5][2] = Player.red;
      board[5][3] = Player.red;

      final state = Connect4State.fromBoard(
        board: board,
        currentPlayer: Player.yellow,
      );

      expect(state.result, GameResult.redWins);
      expect(state.winningCells, isNotNull);
      expect(state.winningCells!.length, 4);
    });

    test('vertical win detected', () {
      final board = List.generate(
        connect4Rows,
        (_) => List.filled(connect4Cols, Player.none),
      );
      board[2][0] = Player.yellow;
      board[3][0] = Player.yellow;
      board[4][0] = Player.yellow;
      board[5][0] = Player.yellow;

      final state = Connect4State.fromBoard(
        board: board,
        currentPlayer: Player.red,
      );

      expect(state.result, GameResult.yellowWins);
    });

    test('diagonal win detected', () {
      final board = List.generate(
        connect4Rows,
        (_) => List.filled(connect4Cols, Player.none),
      );
      board[5][0] = Player.red;
      board[4][1] = Player.red;
      board[3][2] = Player.red;
      board[2][3] = Player.red;

      final state = Connect4State.fromBoard(
        board: board,
        currentPlayer: Player.yellow,
      );

      expect(state.result, GameResult.redWins);
    });

    test('getValidColumns returns columns with space', () {
      final logic = Connect4Logic();
      var state = logic.newGame();

      var valid = logic.getValidColumns(state);
      expect(valid.length, connect4Cols);

      // Fill column 0
      for (var i = 0; i < connect4Rows; i++) {
        state = logic.dropDisc(state, 0).state;
      }

      valid = logic.getValidColumns(state);
      expect(valid.contains(0), isFalse);
      expect(valid.length, connect4Cols - 1);
    });
  });
}
