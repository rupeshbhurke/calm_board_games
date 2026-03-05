import '../../../engine/rng.dart';
import 'sudoku_board.dart';
import 'sudoku_solver.dart';

class SudokuGenerator {
  final Rng rng;

  SudokuGenerator({Rng? rng}) : rng = rng ?? RandomRng();

  SudokuState generate({int difficulty = 1}) {
    // Generate a complete valid board
    final solution = _generateSolution();

    // Remove cells based on difficulty
    final cellsToRemove = switch (difficulty) {
      1 => 35, // Easy
      2 => 45, // Medium
      _ => 55, // Hard
    };

    final puzzle = _createPuzzle(solution, cellsToRemove);

    return SudokuState.fromPuzzle(
      puzzle: puzzle,
      solution: solution,
      difficulty: difficulty,
    );
  }

  List<List<int>> _generateSolution() {
    final board = List.generate(sudokuSize, (_) => List.filled(sudokuSize, 0));

    // Fill diagonal boxes first (they don't affect each other)
    for (var box = 0; box < sudokuSize; box += sudokuBoxSize) {
      _fillBox(board, box, box);
    }

    // Solve the rest
    SudokuSolver.solve(board);

    return board;
  }

  void _fillBox(List<List<int>> board, int startRow, int startCol) {
    final numbers = List.generate(sudokuSize, (i) => i + 1);
    _shuffle(numbers);

    var index = 0;
    for (var r = 0; r < sudokuBoxSize; r++) {
      for (var c = 0; c < sudokuBoxSize; c++) {
        board[startRow + r][startCol + c] = numbers[index++];
      }
    }
  }

  List<List<int>> _createPuzzle(List<List<int>> solution, int cellsToRemove) {
    final puzzle = [for (final row in solution) List<int>.from(row)];
    final positions = <(int, int)>[];

    for (var r = 0; r < sudokuSize; r++) {
      for (var c = 0; c < sudokuSize; c++) {
        positions.add((r, c));
      }
    }

    _shuffle(positions);

    var removed = 0;
    for (final (r, c) in positions) {
      if (removed >= cellsToRemove) break;

      final backup = puzzle[r][c];
      puzzle[r][c] = 0;

      // Check if puzzle still has unique solution
      final testBoard = [for (final row in puzzle) List<int>.from(row)];
      if (SudokuSolver.countSolutions(testBoard, limit: 2) == 1) {
        removed++;
      } else {
        puzzle[r][c] = backup;
      }
    }

    return puzzle;
  }

  void _shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }
}
