const int connect4Rows = 6;
const int connect4Cols = 7;
const int connect4WinLength = 4;

enum Player { none, red, yellow }

enum GameResult { ongoing, redWins, yellowWins, draw }

class Connect4State {
  final List<List<Player>> board;
  final Player currentPlayer;
  final GameResult result;
  final List<(int, int)>? winningCells;

  const Connect4State._({
    required this.board,
    required this.currentPlayer,
    required this.result,
    this.winningCells,
  });

  factory Connect4State.initial() {
    final board = List.generate(
      connect4Rows,
      (_) => List.filled(connect4Cols, Player.none),
    );
    return Connect4State._(
      board: _freezeBoard(board),
      currentPlayer: Player.red,
      result: GameResult.ongoing,
    );
  }

  factory Connect4State.fromBoard({
    required List<List<Player>> board,
    required Player currentPlayer,
  }) {
    final cloned = _cloneBoard(board);
    final winInfo = _checkWin(cloned);
    final result = winInfo != null
        ? (winInfo.$1 == Player.red ? GameResult.redWins : GameResult.yellowWins)
        : _isBoardFull(cloned)
            ? GameResult.draw
            : GameResult.ongoing;
    return Connect4State._(
      board: _freezeBoard(cloned),
      currentPlayer: currentPlayer,
      result: result,
      winningCells: winInfo?.$2,
    );
  }

  bool get isGameOver => result != GameResult.ongoing;
}

class Connect4MoveResult {
  final Connect4State state;
  final bool valid;
  final int? placedRow;

  const Connect4MoveResult({
    required this.state,
    required this.valid,
    this.placedRow,
  });
}

class Connect4Logic {
  Connect4Logic();

  Connect4State newGame() => Connect4State.initial();

  Connect4MoveResult dropDisc(Connect4State state, int column) {
    if (state.isGameOver) {
      return Connect4MoveResult(state: state, valid: false);
    }

    if (column < 0 || column >= connect4Cols) {
      return Connect4MoveResult(state: state, valid: false);
    }

    final row = _findLowestEmptyRow(state.board, column);
    if (row == null) {
      return Connect4MoveResult(state: state, valid: false);
    }

    final board = _cloneBoard(state.board);
    board[row][column] = state.currentPlayer;

    final winInfo = _checkWin(board);
    final GameResult result;
    if (winInfo != null) {
      result = state.currentPlayer == Player.red
          ? GameResult.redWins
          : GameResult.yellowWins;
    } else if (_isBoardFull(board)) {
      result = GameResult.draw;
    } else {
      result = GameResult.ongoing;
    }

    final nextPlayer = state.currentPlayer == Player.red
        ? Player.yellow
        : Player.red;

    final newState = Connect4State._(
      board: _freezeBoard(board),
      currentPlayer: nextPlayer,
      result: result,
      winningCells: winInfo?.$2,
    );

    return Connect4MoveResult(
      state: newState,
      valid: true,
      placedRow: row,
    );
  }

  List<int> getValidColumns(Connect4State state) {
    final valid = <int>[];
    for (var c = 0; c < connect4Cols; c++) {
      if (state.board[0][c] == Player.none) {
        valid.add(c);
      }
    }
    return valid;
  }
}

int? _findLowestEmptyRow(List<List<Player>> board, int column) {
  for (var r = connect4Rows - 1; r >= 0; r--) {
    if (board[r][column] == Player.none) {
      return r;
    }
  }
  return null;
}

(Player, List<(int, int)>)? _checkWin(List<List<Player>> board) {
  const directions = [
    (0, 1),
    (1, 0),
    (1, 1),
    (1, -1),
  ];

  for (var r = 0; r < connect4Rows; r++) {
    for (var c = 0; c < connect4Cols; c++) {
      final player = board[r][c];
      if (player == Player.none) continue;

      for (final (dr, dc) in directions) {
        final cells = <(int, int)>[(r, c)];
        for (var i = 1; i < connect4WinLength; i++) {
          final nr = r + dr * i;
          final nc = c + dc * i;
          if (nr < 0 || nr >= connect4Rows || nc < 0 || nc >= connect4Cols) {
            break;
          }
          if (board[nr][nc] != player) break;
          cells.add((nr, nc));
        }
        if (cells.length == connect4WinLength) {
          return (player, cells);
        }
      }
    }
  }
  return null;
}

bool _isBoardFull(List<List<Player>> board) {
  for (var c = 0; c < connect4Cols; c++) {
    if (board[0][c] == Player.none) return false;
  }
  return true;
}

List<List<Player>> _cloneBoard(List<List<Player>> board) {
  return [for (final row in board) List<Player>.from(row)];
}

List<List<Player>> _freezeBoard(List<List<Player>> board) {
  return List<List<Player>>.unmodifiable(
    board.map((row) => List<Player>.unmodifiable(row)),
  );
}
