const int sudokuSize = 9;
const int sudokuBoxSize = 3;

enum CellType { given, player }

class SudokuCell {
  final int value; // 0 = empty, 1-9 = filled
  final CellType type;
  final bool hasError;

  const SudokuCell({
    required this.value,
    required this.type,
    this.hasError = false,
  });

  SudokuCell copyWith({int? value, bool? hasError}) {
    return SudokuCell(
      value: value ?? this.value,
      type: type,
      hasError: hasError ?? this.hasError,
    );
  }

  bool get isEmpty => value == 0;
  bool get isGiven => type == CellType.given;
}

class SudokuState {
  final List<List<SudokuCell>> board;
  final List<List<int>> solution;
  final int difficulty; // 1-3
  final bool isSolved;

  const SudokuState._({
    required this.board,
    required this.solution,
    required this.difficulty,
    required this.isSolved,
  });

  factory SudokuState.fromPuzzle({
    required List<List<int>> puzzle,
    required List<List<int>> solution,
    required int difficulty,
  }) {
    final board = List.generate(sudokuSize, (r) {
      return List.generate(sudokuSize, (c) {
        final value = puzzle[r][c];
        return SudokuCell(
          value: value,
          type: value != 0 ? CellType.given : CellType.player,
        );
      });
    });
    return SudokuState._(
      board: _freezeBoard(board),
      solution: _freezeSolution(solution),
      difficulty: difficulty,
      isSolved: false,
    );
  }

  int get filledCount {
    var count = 0;
    for (final row in board) {
      for (final cell in row) {
        if (!cell.isEmpty) count++;
      }
    }
    return count;
  }

  int get totalCells => sudokuSize * sudokuSize;
}

class SudokuMoveResult {
  final SudokuState state;
  final bool valid;

  const SudokuMoveResult({required this.state, required this.valid});
}

class SudokuLogic {
  SudokuLogic();

  SudokuMoveResult setCell(SudokuState state, int row, int col, int value) {
    if (row < 0 || row >= sudokuSize || col < 0 || col >= sudokuSize) {
      return SudokuMoveResult(state: state, valid: false);
    }

    final cell = state.board[row][col];
    if (cell.isGiven) {
      return SudokuMoveResult(state: state, valid: false);
    }

    if (value < 0 || value > 9) {
      return SudokuMoveResult(state: state, valid: false);
    }

    final board = _cloneBoard(state.board);
    board[row][col] = SudokuCell(
      value: value,
      type: CellType.player,
      hasError: false,
    );

    final isSolved = _checkSolved(board, state.solution);

    return SudokuMoveResult(
      state: SudokuState._(
        board: _freezeBoard(board),
        solution: state.solution,
        difficulty: state.difficulty,
        isSolved: isSolved,
      ),
      valid: true,
    );
  }

  SudokuState validateBoard(SudokuState state) {
    final board = _cloneBoard(state.board);

    for (var r = 0; r < sudokuSize; r++) {
      for (var c = 0; c < sudokuSize; c++) {
        final cell = board[r][c];
        if (cell.isEmpty || cell.isGiven) continue;

        final hasError = !_isValidPlacement(board, r, c, cell.value);
        board[r][c] = cell.copyWith(hasError: hasError);
      }
    }

    return SudokuState._(
      board: _freezeBoard(board),
      solution: state.solution,
      difficulty: state.difficulty,
      isSolved: state.isSolved,
    );
  }

  (int, int, int)? getHint(SudokuState state) {
    for (var r = 0; r < sudokuSize; r++) {
      for (var c = 0; c < sudokuSize; c++) {
        if (state.board[r][c].isEmpty) {
          return (r, c, state.solution[r][c]);
        }
      }
    }
    return null;
  }

  bool isInSameBox(int r1, int c1, int r2, int c2) {
    return (r1 ~/ sudokuBoxSize == r2 ~/ sudokuBoxSize) &&
        (c1 ~/ sudokuBoxSize == c2 ~/ sudokuBoxSize);
  }
}

bool _checkSolved(List<List<SudokuCell>> board, List<List<int>> solution) {
  for (var r = 0; r < sudokuSize; r++) {
    for (var c = 0; c < sudokuSize; c++) {
      if (board[r][c].value != solution[r][c]) return false;
    }
  }
  return true;
}

bool _isValidPlacement(List<List<SudokuCell>> board, int row, int col, int value) {
  // Check row
  for (var c = 0; c < sudokuSize; c++) {
    if (c != col && board[row][c].value == value) return false;
  }

  // Check column
  for (var r = 0; r < sudokuSize; r++) {
    if (r != row && board[r][col].value == value) return false;
  }

  // Check box
  final boxRow = (row ~/ sudokuBoxSize) * sudokuBoxSize;
  final boxCol = (col ~/ sudokuBoxSize) * sudokuBoxSize;
  for (var r = boxRow; r < boxRow + sudokuBoxSize; r++) {
    for (var c = boxCol; c < boxCol + sudokuBoxSize; c++) {
      if (r != row && c != col && board[r][c].value == value) return false;
    }
  }

  return true;
}

List<List<SudokuCell>> _cloneBoard(List<List<SudokuCell>> board) {
  return [for (final row in board) List<SudokuCell>.from(row)];
}

List<List<SudokuCell>> _freezeBoard(List<List<SudokuCell>> board) {
  return List<List<SudokuCell>>.unmodifiable(
    board.map((row) => List<SudokuCell>.unmodifiable(row)),
  );
}

List<List<int>> _freezeSolution(List<List<int>> solution) {
  return List<List<int>>.unmodifiable(
    solution.map((row) => List<int>.unmodifiable(row)),
  );
}
