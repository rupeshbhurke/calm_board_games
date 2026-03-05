import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../shared/game_dialogs.dart';
import '../../shared/game_header.dart';
import 'logic/image_slicer.dart';
import 'logic/jigsaw_engine.dart';

class JigsawScreen extends StatefulWidget {
  const JigsawScreen({super.key});

  @override
  State<JigsawScreen> createState() => _JigsawScreenState();
}

class _JigsawScreenState extends State<JigsawScreen> {
  late final JigsawLogic _logic;
  late JigsawState _state;
  JigsawDifficulty _difficulty = JigsawDifficulty.easy;
  bool _solvedShown = false;
  int? _draggingPieceId;

  @override
  void initState() {
    super.initState();
    _logic = JigsawLogic();
    _newGame();
  }

  void _newGame() {
    setState(() {
      _state = _logic.newGame(difficulty: _difficulty, boardSize: 280);
      _solvedShown = false;
      _draggingPieceId = null;
    });
  }

  void _changeDifficulty(JigsawDifficulty diff) {
    setState(() {
      _difficulty = diff;
    });
    _newGame();
  }

  void _onPieceDragStart(int pieceId) {
    setState(() {
      _draggingPieceId = pieceId;
    });
  }

  void _onPieceDragUpdate(int pieceId, double x, double y) {
    final result = _logic.movePiece(_state, pieceId, x, y);
    setState(() {
      _state = result.state;
    });
  }

  void _onPieceDragEnd(int pieceId, double x, double y) {
    final result = _logic.dropPiece(_state, pieceId, x, y);
    setState(() {
      _state = result.state;
      _draggingPieceId = null;
    });

    if (_state.isSolved && !_solvedShown) {
      _solvedShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameDialog(
          context: context,
          title: 'Puzzle Complete! 🧩',
          message: 'You solved it in ${_state.movesCount} moves!',
          primaryLabel: 'Play Again',
          onPrimary: _newGame,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jigsaw Puzzle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            children: [
              GameHeader(
                title: 'Placed: ${_state.placedCount}/${_state.totalPieces}',
                subtitle: 'Moves: ${_state.movesCount}',
                buttonLabel: 'New',
                onButtonPressed: _newGame,
              ),
              const SizedBox(height: Spacing.s13),
              _DifficultySelector(
                selected: _difficulty,
                onChanged: _changeDifficulty,
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: _PuzzleArea(
                  state: _state,
                  draggingPieceId: _draggingPieceId,
                  onDragStart: _onPieceDragStart,
                  onDragUpdate: _onPieceDragUpdate,
                  onDragEnd: _onPieceDragEnd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final JigsawDifficulty selected;
  final ValueChanged<JigsawDifficulty> onChanged;

  const _DifficultySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: JigsawDifficulty.values.map((diff) {
        final isSelected = diff == selected;
        final label = switch (diff) {
          JigsawDifficulty.easy => '3×3',
          JigsawDifficulty.medium => '4×4',
          JigsawDifficulty.hard => '6×6',
          JigsawDifficulty.expert => '8×8',
        };
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => onChanged(diff),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.s13,
                vertical: Spacing.s8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? CalmPalette.primary : CalmPalette.surface,
                borderRadius: BorderRadius.circular(Spacing.r12),
                border: Border.all(color: CalmPalette.stroke),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? CalmPalette.text : CalmPalette.subtext,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PuzzleArea extends StatelessWidget {
  final JigsawState state;
  final int? draggingPieceId;
  final ValueChanged<int> onDragStart;
  final void Function(int, double, double) onDragUpdate;
  final void Function(int, double, double) onDragEnd;

  const _PuzzleArea({
    required this.state,
    required this.draggingPieceId,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final areaWidth = constraints.maxWidth;

        return Stack(
          children: [
            // Board outline
            Positioned(
              left: (areaWidth - state.boardSize) / 2,
              top: 0,
              child: Container(
                width: state.boardSize,
                height: state.boardSize,
                decoration: BoxDecoration(
                  color: CalmPalette.surface,
                  borderRadius: BorderRadius.circular(Spacing.r16),
                  border: Border.all(color: CalmPalette.stroke, width: 2),
                ),
                child: _BoardGrid(gridSize: state.difficulty.gridSize),
              ),
            ),
            // Pieces
            ...state.pieces.map((piece) {
              final offsetX = (areaWidth - state.boardSize) / 2;
              return _DraggablePiece(
                key: ValueKey(piece.id),
                piece: piece,
                pieceSize: state.pieceSize,
                offsetX: offsetX,
                isDragging: draggingPieceId == piece.id,
                onDragStart: () => onDragStart(piece.id),
                onDragUpdate: (x, y) => onDragUpdate(piece.id, x - offsetX, y),
                onDragEnd: (x, y) => onDragEnd(piece.id, x - offsetX, y),
              );
            }),
          ],
        );
      },
    );
  }
}

class _BoardGrid extends StatelessWidget {
  final int gridSize;

  const _BoardGrid({required this.gridSize});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: CalmPalette.stroke.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        );
      },
    );
  }
}

class _DraggablePiece extends StatefulWidget {
  final JigsawPiece piece;
  final double pieceSize;
  final double offsetX;
  final bool isDragging;
  final VoidCallback onDragStart;
  final void Function(double, double) onDragUpdate;
  final void Function(double, double) onDragEnd;

  const _DraggablePiece({
    super.key,
    required this.piece,
    required this.pieceSize,
    required this.offsetX,
    required this.isDragging,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  State<_DraggablePiece> createState() => _DraggablePieceState();
}

class _DraggablePieceState extends State<_DraggablePiece> {
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    final piece = widget.piece;
    final colorData = PieceColorData(
      row: piece.correctRow,
      col: piece.correctCol,
      gridSize: (piece.correctRow + piece.correctCol + 4), // Approximation
    );

    final displayX = _dragOffset?.dx ?? (piece.currentX + widget.offsetX);
    final displayY = _dragOffset?.dy ?? piece.currentY;

    return Positioned(
      left: displayX,
      top: displayY,
      child: GestureDetector(
        onPanStart: piece.isPlaced
            ? null
            : (details) {
                widget.onDragStart();
                setState(() {
                  _dragOffset = Offset(displayX, displayY);
                });
              },
        onPanUpdate: piece.isPlaced
            ? null
            : (details) {
                setState(() {
                  _dragOffset = _dragOffset! + details.delta;
                });
                widget.onDragUpdate(_dragOffset!.dx, _dragOffset!.dy);
              },
        onPanEnd: piece.isPlaced
            ? null
            : (details) {
                widget.onDragEnd(_dragOffset!.dx, _dragOffset!.dy);
                setState(() {
                  _dragOffset = null;
                });
              },
        child: AnimatedContainer(
          duration: Duration(
            milliseconds: widget.isDragging ? 0 : Spacing.ms180,
          ),
          width: widget.pieceSize - 2,
          height: widget.pieceSize - 2,
          decoration: BoxDecoration(
            color: Color(colorData.colorValue),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: piece.isPlaced
                  ? CalmPalette.secondary
                  : widget.isDragging
                      ? CalmPalette.primary
                      : CalmPalette.stroke,
              width: piece.isPlaced ? 2 : 1,
            ),
            boxShadow: widget.isDragging
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '${piece.id + 1}',
              style: TextStyle(
                color: CalmPalette.text,
                fontWeight: FontWeight.bold,
                fontSize: widget.pieceSize > 40 ? 14 : 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
