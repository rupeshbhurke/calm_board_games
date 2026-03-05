import '../../../engine/rng.dart';

const int slidingPuzzleBoardSize = 4;
const int _tileCount = slidingPuzzleBoardSize * slidingPuzzleBoardSize;
const int _emptyTile = 0;
const int _scrambleMoves = 200;

class SlidingPuzzleState {
  static const int boardSize = slidingPuzzleBoardSize;
  static const int tileCount = _tileCount;

  final List<int> tiles;
  final int moveCount;
  final bool solved;

  const SlidingPuzzleState._({
    required this.tiles,
    required this.moveCount,
    required this.solved,
  });

  factory SlidingPuzzleState.initial(Rng rng) {
    final tiles = _generateScrambledTiles(rng);
    return SlidingPuzzleState._(
      tiles: List<int>.unmodifiable(tiles),
      moveCount: 0,
      solved: _isSolved(tiles),
    );
  }

  factory SlidingPuzzleState.fromTiles(
    List<int> tiles, {
    int moveCount = 0,
  }) {
    if (tiles.length != _tileCount) {
      throw ArgumentError('Expected $_tileCount tiles, got ${tiles.length}.');
    }
    final normalized = List<int>.from(tiles);
    return SlidingPuzzleState._(
      tiles: List<int>.unmodifiable(normalized),
      moveCount: moveCount,
      solved: _isSolved(normalized),
    );
  }

  List<List<int>> get rows => List<List<int>>.generate(
        slidingPuzzleBoardSize,
        (row) {
          final start = row * slidingPuzzleBoardSize;
          return List<int>.unmodifiable(
            tiles.sublist(start, start + slidingPuzzleBoardSize),
          );
        },
      );
}

class SlidingPuzzleMoveResult {
  final SlidingPuzzleState state;
  final bool moved;

  const SlidingPuzzleMoveResult({
    required this.state,
    required this.moved,
  });
}

class SlidingPuzzleLogic {
  final Rng rng;

  SlidingPuzzleLogic({Rng? rng}) : rng = rng ?? RandomRng();

  SlidingPuzzleState newGame() => SlidingPuzzleState.initial(rng);

  SlidingPuzzleMoveResult moveTile(SlidingPuzzleState state, int tileValue) {
    if (tileValue == _emptyTile) {
      return SlidingPuzzleMoveResult(state: state, moved: false);
    }

    final tiles = List<int>.from(state.tiles);
    final int tileIndex = tiles.indexOf(tileValue);
    final int emptyIndex = tiles.indexOf(_emptyTile);

    if (tileIndex == -1 || !_areAdjacent(tileIndex, emptyIndex)) {
      return SlidingPuzzleMoveResult(state: state, moved: false);
    }

    _swap(tiles, tileIndex, emptyIndex);

    final updatedState = SlidingPuzzleState._(
      tiles: List<int>.unmodifiable(tiles),
      moveCount: state.moveCount + 1,
      solved: _isSolved(tiles),
    );

    return SlidingPuzzleMoveResult(state: updatedState, moved: true);
  }
}

List<int> _generateScrambledTiles(Rng rng) {
  final tiles = List<int>.generate(
    _tileCount,
    (index) => (index + 1) % _tileCount,
  );

  var blankIndex = tiles.indexOf(_emptyTile);

  void scrambleOnce() {
    final neighbors = _adjacentIndices(blankIndex);
    final swapIndex = neighbors[rng.nextInt(neighbors.length)];
    _swap(tiles, blankIndex, swapIndex);
    blankIndex = swapIndex;
  }

  for (var i = 0; i < _scrambleMoves; i++) {
    scrambleOnce();
  }

  if (_isSolved(tiles)) {
    // Extremely unlikely, but ensure puzzle starts unsolved.
    scrambleOnce();
  }

  return tiles;
}

bool _isSolved(List<int> tiles) {
  for (var i = 0; i < tiles.length - 1; i++) {
    if (tiles[i] != i + 1) return false;
  }
  return tiles.last == _emptyTile;
}

bool _areAdjacent(int a, int b) {
  final rowA = a ~/ slidingPuzzleBoardSize;
  final colA = a % slidingPuzzleBoardSize;
  final rowB = b ~/ slidingPuzzleBoardSize;
  final colB = b % slidingPuzzleBoardSize;

  final rowDiff = (rowA - rowB).abs();
  final colDiff = (colA - colB).abs();

  return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
}

List<int> _adjacentIndices(int index) {
  final row = index ~/ slidingPuzzleBoardSize;
  final col = index % slidingPuzzleBoardSize;
  final neighbors = <int>[];

  if (col > 0) neighbors.add(index - 1);
  if (col < slidingPuzzleBoardSize - 1) neighbors.add(index + 1);
  if (row > 0) neighbors.add(index - slidingPuzzleBoardSize);
  if (row < slidingPuzzleBoardSize - 1) {
    neighbors.add(index + slidingPuzzleBoardSize);
  }

  return neighbors;
}

void _swap(List<int> tiles, int a, int b) {
  final tmp = tiles[a];
  tiles[a] = tiles[b];
  tiles[b] = tmp;
}
