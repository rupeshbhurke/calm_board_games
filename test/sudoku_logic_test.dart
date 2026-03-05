import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/games/sudoku/logic/sudoku_board.dart';
import 'package:calm_board_games/lib/games/sudoku/logic/sudoku_solver.dart';

void main() {
  group('SudokuSolver', () {
    test('solves empty board', () {
      final board = List.generate(sudokuSize, (_) => List.filled(sudokuSize, 0));
      final result = SudokuSolver.solve(board);

      expect(result, isTrue);
      
      // Verify solution is valid
      for (var r = 0; r < sudokuSize; r++) {
        for (var c = 0; c < sudokuSize; c++) {
          expect(board[r][c], inInclusiveRange(1, 9));
        }
      }
    });

    test('solves partially filled board', () {
      final board = List.generate(sudokuSize, (_) => List.filled(sudokuSize, 0));
      board[0][0] = 5;
      board[0][1] = 3;
      board[1][0] = 6;

      final result = SudokuSolver.solve(board);

      expect(result, isTrue);
      expect(board[0][0], 5);
      expect(board[0][1], 3);
      expect(board[1][0], 6);
    });

    test('counts solutions correctly', () {
      final board = List.generate(sudokuSize, (_) => List.filled(sudokuSize, 0));
      
      // Empty board has multiple solutions
      final count = SudokuSolver.countSolutions(board, limit: 2);
      expect(count, 2);
    });
  });

  group('SudokuLogic', () {
    test('setCell updates player cell', () {
      final logic = SudokuLogic();
      final puzzle = List.generate(sudokuSize, (_) => List.filled(sudokuSize, 0));
      final solution = List.generate(sudokuSize, (r) => List.generate(sudokuSize, (c) => ((r * 3 + r ~/ 3 + c) % 9) + 1));
      
      final state = SudokuState.fromPuzzle(
        puzzle: puzzle,
        solution: solution,
        difficulty: 1,
      );

      final result = logic.setCell(state, 0, 0, 5);

      expect(result.valid, isTrue);
      expect(result.state.board[0][0].value, 5);
    });

    test('cannot modify given cell', () {
      final logic = SudokuLogic();
      final puzzle = List.generate(sudokuSize, (_) => List.filled(sudokuSize, 0));
      puzzle[0][0] = 5; // Given cell
      final solution = List.generate(sudokuSize, (r) => List.generate(sudokuSize, (c) => ((r * 3 + r ~/ 3 + c) % 9) + 1));
      
      final state = SudokuState.fromPuzzle(
        puzzle: puzzle,
        solution: solution,
        difficulty: 1,
      );

      final result = logic.setCell(state, 0, 0, 7);

      expect(result.valid, isFalse);
      expect(result.state.board[0][0].value, 5);
    });

    test('validates board finds errors', () {
      final logic = SudokuLogic();
      final puzzle = List.generate(sudokuSize, (_) => List.filled(sudokuSize, 0));
      final solution = List.generate(sudokuSize, (r) => List.generate(sudokuSize, (c) => ((r * 3 + r ~/ 3 + c) % 9) + 1));
      
      var state = SudokuState.fromPuzzle(
        puzzle: puzzle,
        solution: solution,
        difficulty: 1,
      );

      // Set same number in same row
      state = logic.setCell(state, 0, 0, 5).state;
      state = logic.setCell(state, 0, 1, 5).state;

      state = logic.validateBoard(state);

      expect(state.board[0][0].hasError, isTrue);
      expect(state.board[0][1].hasError, isTrue);
    });

    test('detects solved state', () {
      final logic = SudokuLogic();
      
      // Create a valid solution
      final solution = <List<int>>[];
      for (var r = 0; r < sudokuSize; r++) {
        solution.add(List.generate(sudokuSize, (c) {
          return ((r * 3 + r ~/ 3 + c) % 9) + 1;
        }));
      }

      // Create puzzle with one cell empty
      final puzzle = [for (final row in solution) List<int>.from(row)];
      puzzle[0][0] = 0;

      var state = SudokuState.fromPuzzle(
        puzzle: puzzle,
        solution: solution,
        difficulty: 1,
      );

      // Fill in the missing cell
      final result = logic.setCell(state, 0, 0, solution[0][0]);

      expect(result.state.isSolved, isTrue);
    });

    test('isInSameBox works correctly', () {
      final logic = SudokuLogic();

      expect(logic.isInSameBox(0, 0, 2, 2), isTrue);
      expect(logic.isInSameBox(0, 0, 3, 0), isFalse);
      expect(logic.isInSameBox(3, 3, 5, 5), isTrue);
    });
  });
}
