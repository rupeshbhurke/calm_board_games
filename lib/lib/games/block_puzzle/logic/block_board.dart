import '../../../engine/rng.dart';
import 'block_shapes.dart';

const int blockBoardSize = 10;
const int shapesPerRound = 3;

class BlockBoardState {
  final List<List<int>> board; // 0 = empty, >0 = color index + 1
  final List<BlockShape?> availableShapes;
  final int score;
  final bool gameOver;

  const BlockBoardState._({
    required this.board,
    required this.availableShapes,
    required this.score,
    required this.gameOver,
  });

  factory BlockBoardState.initial(Rng rng) {
    final board = List.generate(
      blockBoardSize,
      (_) => List.filled(blockBoardSize, 0),
    );
    final shapes = _generateShapes(rng);
    return BlockBoardState._(
      board: _freezeBoard(board),
      availableShapes: List.unmodifiable(shapes),
      score: 0,
      gameOver: false,
    );
  }

  factory BlockBoardState.fromBoard({
    required List<List<int>> board,
    required List<BlockShape?> shapes,
    required int score,
  }) {
    final cloned = _cloneBoard(board);
    return BlockBoardState._(
      board: _freezeBoard(cloned),
      availableShapes: List.unmodifiable(shapes),
      score: score,
      gameOver: false,
    );
  }

  bool get needsNewShapes => availableShapes.every((s) => s == null);
}

class BlockPlaceResult {
  final BlockBoardState state;
  final bool placed;
  final int linesCleared;
  final int scoreGained;

  const BlockPlaceResult({
    required this.state,
    required this.placed,
    required this.linesCleared,
    required this.scoreGained,
  });
}

class BlockBoardLogic {
  final Rng rng;

  BlockBoardLogic({Rng? rng}) : rng = rng ?? RandomRng();

  BlockBoardState newGame() => BlockBoardState.initial(rng);

  bool canPlaceShape(BlockBoardState state, BlockShape shape, int row, int col) {
    for (var r = 0; r < shape.rows; r++) {
      for (var c = 0; c < shape.cols; c++) {
        if (!shape.pattern[r][c]) continue;
        final boardRow = row + r;
        final boardCol = col + c;
        if (boardRow < 0 || boardRow >= blockBoardSize) return false;
        if (boardCol < 0 || boardCol >= blockBoardSize) return false;
        if (state.board[boardRow][boardCol] != 0) return false;
      }
    }
    return true;
  }

  bool canPlaceAnyShape(BlockBoardState state) {
    for (final shape in state.availableShapes) {
      if (shape == null) continue;
      for (var r = 0; r < blockBoardSize; r++) {
        for (var c = 0; c < blockBoardSize; c++) {
          if (canPlaceShape(state, shape, r, c)) return true;
        }
      }
    }
    return false;
  }

  BlockPlaceResult placeShape(
    BlockBoardState state,
    int shapeIndex,
    int row,
    int col,
  ) {
    if (shapeIndex < 0 || shapeIndex >= state.availableShapes.length) {
      return BlockPlaceResult(
        state: state,
        placed: false,
        linesCleared: 0,
        scoreGained: 0,
      );
    }

    final shape = state.availableShapes[shapeIndex];
    if (shape == null) {
      return BlockPlaceResult(
        state: state,
        placed: false,
        linesCleared: 0,
        scoreGained: 0,
      );
    }

    if (!canPlaceShape(state, shape, row, col)) {
      return BlockPlaceResult(
        state: state,
        placed: false,
        linesCleared: 0,
        scoreGained: 0,
      );
    }

    final board = _cloneBoard(state.board);

    // Place the shape
    for (var r = 0; r < shape.rows; r++) {
      for (var c = 0; c < shape.cols; c++) {
        if (shape.pattern[r][c]) {
          board[row + r][col + c] = shape.colorIndex + 1;
        }
      }
    }

    // Check for completed lines
    final (clearedBoard, linesCleared) = _clearLines(board);

    // Calculate score
    final placeScore = shape.cellCount;
    final clearScore = linesCleared * blockBoardSize;
    final totalScore = placeScore + clearScore;

    // Update available shapes
    final newShapes = List<BlockShape?>.from(state.availableShapes);
    newShapes[shapeIndex] = null;

    // Check if we need new shapes
    final needsRefill = newShapes.every((s) => s == null);
    final finalShapes = needsRefill ? _generateShapes(rng) : newShapes;

    // Check game over
    final tempState = BlockBoardState._(
      board: _freezeBoard(clearedBoard),
      availableShapes: List.unmodifiable(finalShapes),
      score: state.score + totalScore,
      gameOver: false,
    );
    final gameOver = !canPlaceAnyShape(tempState);

    return BlockPlaceResult(
      state: BlockBoardState._(
        board: _freezeBoard(clearedBoard),
        availableShapes: List.unmodifiable(finalShapes),
        score: state.score + totalScore,
        gameOver: gameOver,
      ),
      placed: true,
      linesCleared: linesCleared,
      scoreGained: totalScore,
    );
  }
}

List<BlockShape> _generateShapes(Rng rng) {
  final shapes = <BlockShape>[];
  final allShapes = BlockShapes.all;
  for (var i = 0; i < shapesPerRound; i++) {
    shapes.add(allShapes[rng.nextInt(allShapes.length)]);
  }
  return shapes;
}

(List<List<int>>, int) _clearLines(List<List<int>> board) {
  final rowsToClear = <int>[];
  final colsToClear = <int>[];

  // Check rows
  for (var r = 0; r < blockBoardSize; r++) {
    if (board[r].every((cell) => cell != 0)) {
      rowsToClear.add(r);
    }
  }

  // Check columns
  for (var c = 0; c < blockBoardSize; c++) {
    var full = true;
    for (var r = 0; r < blockBoardSize; r++) {
      if (board[r][c] == 0) {
        full = false;
        break;
      }
    }
    if (full) colsToClear.add(c);
  }

  // Clear rows
  for (final r in rowsToClear) {
    for (var c = 0; c < blockBoardSize; c++) {
      board[r][c] = 0;
    }
  }

  // Clear columns
  for (final c in colsToClear) {
    for (var r = 0; r < blockBoardSize; r++) {
      board[r][c] = 0;
    }
  }

  return (board, rowsToClear.length + colsToClear.length);
}

List<List<int>> _cloneBoard(List<List<int>> board) {
  return [for (final row in board) List<int>.from(row)];
}

List<List<int>> _freezeBoard(List<List<int>> board) {
  return List<List<int>>.unmodifiable(
    board.map((row) => List<int>.unmodifiable(row)),
  );
}
