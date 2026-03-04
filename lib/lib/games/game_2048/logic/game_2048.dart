import 'rng.dart';

const int _boardSize = 4;
const int _targetValue = 2048;

enum MoveDirection { up, down, left, right }

class Game2048State {
  final List<List<int>> board;
  final int score;
  final bool won;
  final bool lost;

  const Game2048State._({
    required this.board,
    required this.score,
    required this.won,
    required this.lost,
  });

  factory Game2048State.initial(Rng rng) {
    final board = _emptyBoard();
    _spawnTile(board, rng);
    _spawnTile(board, rng);
    return Game2048State._(
      board: _freezeBoard(board),
      score: 0,
      won: _hasWon(board),
      lost: _hasLost(board),
    );
  }

  factory Game2048State.fromBoard({
    required List<List<int>> board,
    required int score,
  }) {
    final cloned = _cloneBoard(board);
    return Game2048State._(
      board: _freezeBoard(cloned),
      score: score,
      won: _hasWon(cloned),
      lost: _hasLost(cloned),
    );
  }
}

class Game2048MoveResult {
  final Game2048State state;
  final int scoreDelta;
  final bool boardChanged;

  const Game2048MoveResult({
    required this.state,
    required this.scoreDelta,
    required this.boardChanged,
  });
}

class Game2048Logic {
  final Rng rng;

  Game2048Logic({Rng? rng}) : rng = rng ?? RandomRng();

  Game2048State newGame() => Game2048State.initial(rng);

  Game2048MoveResult move(Game2048State current, MoveDirection direction) {
    final working = _cloneBoard(current.board);
    var scoreDelta = 0;
    var changed = false;

    void processRow(int rowIndex, bool reverse) {
      final original = List<int>.from(working[rowIndex]);
      final result = _processLine(original, reverse: reverse);
      working[rowIndex] = result.line;
      scoreDelta += result.scoreDelta;
      changed = changed || result.changed;
    }

    void processColumn(int columnIndex, bool reverse) {
      final column = List<int>.generate(_boardSize, (i) => working[i][columnIndex]);
      final result = _processLine(column, reverse: reverse);
      for (var i = 0; i < _boardSize; i++) {
        working[i][columnIndex] = result.line[i];
      }
      scoreDelta += result.scoreDelta;
      changed = changed || result.changed;
    }

    switch (direction) {
      case MoveDirection.left:
        for (var r = 0; r < _boardSize; r++) {
          processRow(r, false);
        }
        break;
      case MoveDirection.right:
        for (var r = 0; r < _boardSize; r++) {
          processRow(r, true);
        }
        break;
      case MoveDirection.up:
        for (var c = 0; c < _boardSize; c++) {
          processColumn(c, false);
        }
        break;
      case MoveDirection.down:
        for (var c = 0; c < _boardSize; c++) {
          processColumn(c, true);
        }
        break;
    }

    final preSpawnWon = current.won || _hasWon(working);
    final preSpawnLost = _hasLost(working);

    if (!changed) {
      final sameState = Game2048State._(
        board: _freezeBoard(working),
        score: current.score,
        won: preSpawnWon,
        lost: preSpawnLost,
      );
      return Game2048MoveResult(
        state: sameState,
        scoreDelta: 0,
        boardChanged: false,
      );
    }

    if (_hasEmptyCell(working)) {
      _spawnTile(working, rng);
    }

    final updatedScore = current.score + scoreDelta;
    final won = preSpawnWon || _hasWon(working);
    final lost = _hasLost(working);

    final nextState = Game2048State._(
      board: _freezeBoard(working),
      score: updatedScore,
      won: won,
      lost: lost,
    );

    return Game2048MoveResult(
      state: nextState,
      scoreDelta: scoreDelta,
      boardChanged: true,
    );
  }
}

class _LineProcessResult {
  final List<int> line;
  final int scoreDelta;
  final bool changed;

  _LineProcessResult({
    required this.line,
    required this.scoreDelta,
    required this.changed,
  });
}

_LineProcessResult _processLine(List<int> line, {required bool reverse}) {
  final original = List<int>.from(line);
  var working = List<int>.from(line);
  if (reverse) {
    working = working.reversed.toList();
  }
  final compacted = working.where((value) => value != 0).toList();
  final output = <int>[];
  var delta = 0;
  var i = 0;
  while (i < compacted.length) {
    final current = compacted[i];
    if (i + 1 < compacted.length && compacted[i + 1] == current) {
      final merged = current * 2;
      output.add(merged);
      delta += merged;
      i += 2;
    } else {
      output.add(current);
      i += 1;
    }
  }
  while (output.length < _boardSize) {
    output.add(0);
  }
  final finalLine = reverse ? output.reversed.toList() : output;
  final changed = !_listsEqual(original, finalLine);
  return _LineProcessResult(line: finalLine, scoreDelta: delta, changed: changed);
}

bool _hasWon(List<List<int>> board) {
  for (var row in board) {
    for (var value in row) {
      if (value >= _targetValue) return true;
    }
  }
  return false;
}

bool _hasLost(List<List<int>> board) {
  if (_hasEmptyCell(board)) {
    return false;
  }
  for (var r = 0; r < _boardSize; r++) {
    for (var c = 0; c < _boardSize; c++) {
      final value = board[r][c];
      if ((r + 1 < _boardSize && board[r + 1][c] == value) ||
          (c + 1 < _boardSize && board[r][c + 1] == value)) {
        return false;
      }
    }
  }
  return true;
}

bool _hasEmptyCell(List<List<int>> board) {
  for (var row in board) {
    for (var value in row) {
      if (value == 0) return true;
    }
  }
  return false;
}

void _spawnTile(List<List<int>> board, Rng rng) {
  final empty = <({int row, int col})>[];
  for (var r = 0; r < _boardSize; r++) {
    for (var c = 0; c < _boardSize; c++) {
      if (board[r][c] == 0) {
        empty.add((row: r, col: c));
      }
    }
  }
  if (empty.isEmpty) return;
  final chosen = empty[rng.nextInt(empty.length)];
  board[chosen.row][chosen.col] = rng.nextDouble() < 0.9 ? 2 : 4;
}

List<List<int>> _emptyBoard() =>
    List.generate(_boardSize, (_) => List.filled(_boardSize, 0));

List<List<int>> _cloneBoard(List<List<int>> board) =>
    [for (final row in board) List<int>.from(row)];

List<List<int>> _freezeBoard(List<List<int>> board) =>
    List<List<int>>.unmodifiable(
      board.map(
        (row) => List<int>.unmodifiable(List<int>.from(row)),
      ),
    );

bool _listsEqual(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
