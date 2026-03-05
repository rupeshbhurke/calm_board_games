import 'sudoku_board.dart';

class SudokuSolver {
  SudokuSolver._();

  static bool solve(List<List<int>> board) {
    final empty = _findEmpty(board);
    if (empty == null) return true;

    final (row, col) = empty;

    for (var num = 1; num <= sudokuSize; num++) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        if (solve(board)) return true;
        board[row][col] = 0;
      }
    }

    return false;
  }

  static int countSolutions(List<List<int>> board, {int limit = 2}) {
    return _countSolutionsHelper(board, 0, limit);
  }

  static int _countSolutionsHelper(List<List<int>> board, int count, int limit) {
    if (count >= limit) return count;

    final empty = _findEmpty(board);
    if (empty == null) return count + 1;

    final (row, col) = empty;

    for (var num = 1; num <= sudokuSize; num++) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        count = _countSolutionsHelper(board, count, limit);
        board[row][col] = 0;
        if (count >= limit) return count;
      }
    }

    return count;
  }

  static (int, int)? _findEmpty(List<List<int>> board) {
    for (var r = 0; r < sudokuSize; r++) {
      for (var c = 0; c < sudokuSize; c++) {
        if (board[r][c] == 0) return (r, c);
      }
    }
    return null;
  }

  static bool _isValid(List<List<int>> board, int row, int col, int num) {
    // Check row
    for (var c = 0; c < sudokuSize; c++) {
      if (board[row][c] == num) return false;
    }

    // Check column
    for (var r = 0; r < sudokuSize; r++) {
      if (board[r][col] == num) return false;
    }

    // Check box
    final boxRow = (row ~/ sudokuBoxSize) * sudokuBoxSize;
    final boxCol = (col ~/ sudokuBoxSize) * sudokuBoxSize;
    for (var r = boxRow; r < boxRow + sudokuBoxSize; r++) {
      for (var c = boxCol; c < boxCol + sudokuBoxSize; c++) {
        if (board[r][c] == num) return false;
      }
    }

    return true;
  }
}
