import '../../../engine/rng.dart';

enum JigsawDifficulty {
  easy(3),
  medium(4),
  hard(6),
  expert(8);

  final int gridSize;
  const JigsawDifficulty(this.gridSize);
}

class JigsawPiece {
  final int id;
  final int correctRow;
  final int correctCol;
  final double currentX;
  final double currentY;
  final bool isPlaced;

  const JigsawPiece({
    required this.id,
    required this.correctRow,
    required this.correctCol,
    required this.currentX,
    required this.currentY,
    this.isPlaced = false,
  });

  JigsawPiece copyWith({
    double? currentX,
    double? currentY,
    bool? isPlaced,
  }) {
    return JigsawPiece(
      id: id,
      correctRow: correctRow,
      correctCol: correctCol,
      currentX: currentX ?? this.currentX,
      currentY: currentY ?? this.currentY,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }
}

class JigsawState {
  final List<JigsawPiece> pieces;
  final JigsawDifficulty difficulty;
  final double boardSize;
  final int movesCount;
  final bool isSolved;

  const JigsawState._({
    required this.pieces,
    required this.difficulty,
    required this.boardSize,
    required this.movesCount,
    required this.isSolved,
  });

  factory JigsawState.initial(
    Rng rng, {
    JigsawDifficulty difficulty = JigsawDifficulty.easy,
    double boardSize = 300,
  }) {
    final gridSize = difficulty.gridSize;
    final pieceSize = boardSize / gridSize;
    final pieces = <JigsawPiece>[];

    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        pieces.add(JigsawPiece(
          id: row * gridSize + col,
          correctRow: row,
          correctCol: col,
          currentX: col * pieceSize,
          currentY: row * pieceSize,
        ));
      }
    }

    // Shuffle pieces to random positions outside the board
    final shuffled = <JigsawPiece>[];
    for (final piece in pieces) {
      final randomX = rng.nextDouble() * boardSize * 0.8;
      final randomY = boardSize + 20 + rng.nextDouble() * 100;
      shuffled.add(piece.copyWith(currentX: randomX, currentY: randomY));
    }

    // Shuffle the list order
    for (var i = shuffled.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    return JigsawState._(
      pieces: List.unmodifiable(shuffled),
      difficulty: difficulty,
      boardSize: boardSize,
      movesCount: 0,
      isSolved: false,
    );
  }

  double get pieceSize => boardSize / difficulty.gridSize;

  int get placedCount => pieces.where((p) => p.isPlaced).length;

  int get totalPieces => pieces.length;
}

class JigsawMoveResult {
  final JigsawState state;
  final bool snapped;

  const JigsawMoveResult({required this.state, required this.snapped});
}

class JigsawLogic {
  final Rng rng;

  JigsawLogic({Rng? rng}) : rng = rng ?? RandomRng();

  JigsawState newGame({
    JigsawDifficulty difficulty = JigsawDifficulty.easy,
    double boardSize = 300,
  }) {
    return JigsawState.initial(rng, difficulty: difficulty, boardSize: boardSize);
  }

  JigsawMoveResult movePiece(JigsawState state, int pieceId, double x, double y) {
    final index = state.pieces.indexWhere((p) => p.id == pieceId);
    if (index == -1) {
      return JigsawMoveResult(state: state, snapped: false);
    }

    final piece = state.pieces[index];
    if (piece.isPlaced) {
      return JigsawMoveResult(state: state, snapped: false);
    }

    final pieces = List<JigsawPiece>.from(state.pieces);
    pieces[index] = piece.copyWith(currentX: x, currentY: y);

    return JigsawMoveResult(
      state: JigsawState._(
        pieces: List.unmodifiable(pieces),
        difficulty: state.difficulty,
        boardSize: state.boardSize,
        movesCount: state.movesCount,
        isSolved: state.isSolved,
      ),
      snapped: false,
    );
  }

  JigsawMoveResult dropPiece(JigsawState state, int pieceId, double x, double y) {
    final index = state.pieces.indexWhere((p) => p.id == pieceId);
    if (index == -1) {
      return JigsawMoveResult(state: state, snapped: false);
    }

    final piece = state.pieces[index];
    if (piece.isPlaced) {
      return JigsawMoveResult(state: state, snapped: false);
    }

    final pieceSize = state.pieceSize;
    final targetX = piece.correctCol * pieceSize;
    final targetY = piece.correctRow * pieceSize;

    final snapThreshold = pieceSize * 0.3;
    final isNearTarget = (x - targetX).abs() < snapThreshold &&
        (y - targetY).abs() < snapThreshold;

    final pieces = List<JigsawPiece>.from(state.pieces);

    if (isNearTarget) {
      pieces[index] = piece.copyWith(
        currentX: targetX,
        currentY: targetY,
        isPlaced: true,
      );
    } else {
      pieces[index] = piece.copyWith(currentX: x, currentY: y);
    }

    final isSolved = pieces.every((p) => p.isPlaced);

    return JigsawMoveResult(
      state: JigsawState._(
        pieces: List.unmodifiable(pieces),
        difficulty: state.difficulty,
        boardSize: state.boardSize,
        movesCount: state.movesCount + 1,
        isSolved: isSolved,
      ),
      snapped: isNearTarget,
    );
  }
}
