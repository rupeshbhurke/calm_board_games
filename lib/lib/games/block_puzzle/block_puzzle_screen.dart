import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../shared/game_dialogs.dart';
import '../../shared/game_header.dart';
import 'logic/block_board.dart';
import 'logic/block_shapes.dart';

class BlockPuzzleScreen extends StatefulWidget {
  const BlockPuzzleScreen({super.key});

  @override
  State<BlockPuzzleScreen> createState() => _BlockPuzzleScreenState();
}

class _BlockPuzzleScreenState extends State<BlockPuzzleScreen> {
  late final BlockBoardLogic _logic;
  late BlockBoardState _state;
  int? _selectedShapeIndex;
  bool _gameOverShown = false;
  bool _boardPulse = false;

  @override
  void initState() {
    super.initState();
    _logic = BlockBoardLogic();
    _resetGame();
  }

  void _triggerBoardPulse() {
    if (_boardPulse) return;
    setState(() => _boardPulse = true);
    Future.delayed(const Duration(milliseconds: Spacing.ms220), () {
      if (!mounted) return;
      setState(() => _boardPulse = false);
    });
  }

  void _resetGame() {
    setState(() {
      _state = _logic.newGame();
      _selectedShapeIndex = null;
      _gameOverShown = false;
      _boardPulse = false;
    });
  }

  void _selectShape(int index) {
    if (_state.availableShapes[index] == null) return;
    setState(() {
      _selectedShapeIndex = _selectedShapeIndex == index ? null : index;
    });
  }

  void _onBoardTap(int row, int col) {
    if (_selectedShapeIndex == null) return;

    final result = _logic.placeShape(_state, _selectedShapeIndex!, row, col);
    if (!result.placed || !mounted) return;

    setState(() {
      _state = result.state;
      _selectedShapeIndex = null;
    });

    if (result.linesCleared > 0) {
      _triggerBoardPulse();
    }

    if (_state.gameOver && !_gameOverShown) {
      _gameOverShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameDialog(
          context: context,
          title: 'Game Over',
          message: 'No more moves available.\nFinal score: ${_state.score}',
          primaryLabel: 'Play Again',
          onPrimary: _resetGame,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Block Puzzle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            children: [
              GameHeader(
                title: 'Score',
                subtitle: '${_state.score}',
                buttonLabel: 'New Game',
                onButtonPressed: _resetGame,
              ),
              const SizedBox(height: Spacing.s21),
              _SelectedShapePanel(
                selectedShape: _selectedShapeIndex != null
                    ? _state.availableShapes[_selectedShapeIndex!]
                    : null,
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: Center(
                  child: _GameBoard(
                    state: _state,
                    pulse: _boardPulse,
                    onCellTap: _onBoardTap,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.s21),
              _ShapeSelector(
                shapes: _state.availableShapes,
                selectedIndex: _selectedShapeIndex,
                onSelect: _selectShape,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedShapePanel extends StatelessWidget {
  final BlockShape? selectedShape;

  const _SelectedShapePanel({required this.selectedShape});

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedShape != null;
    final title = hasSelection
        ? 'Tap a cell on the board to place this shape'
        : 'Select a shape to start your move';
    final subtitle = hasSelection
        ? 'Fill an entire row or column to clear it and earn bonus points.'
        : 'Each placement scores the number of tiles you cover.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.s13),
      decoration: BoxDecoration(
        color: CalmPalette.surface,
        borderRadius: BorderRadius.circular(Spacing.r16),
        border: Border.all(color: CalmPalette.stroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.s8),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: CalmPalette.subtext),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.s13),
          if (hasSelection)
            DecoratedBox(
              decoration: BoxDecoration(
                color: CalmPalette.bg,
                borderRadius: BorderRadius.circular(Spacing.r16),
                border: Border.all(color: CalmPalette.stroke),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.s8),
                child: _ShapePreview(shape: selectedShape!),
              ),
            )
          else
            Icon(
              Icons.touch_app,
              color: CalmPalette.subtext,
              size: 28,
            ),
        ],
      ),
    );
  }
}

class _GameBoard extends StatelessWidget {
  final BlockBoardState state;
  final bool pulse;
  final void Function(int row, int col) onCellTap;

  const _GameBoard({
    required this.state,
    required this.pulse,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: Spacing.ms220),
        padding: const EdgeInsets.all(Spacing.s8),
        decoration: BoxDecoration(
          color: CalmPalette.surface,
          borderRadius: BorderRadius.circular(Spacing.r24),
          boxShadow: pulse
              ? [
                  BoxShadow(
                    color: CalmPalette.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: blockBoardSize,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: blockBoardSize * blockBoardSize,
          itemBuilder: (context, index) {
            final row = index ~/ blockBoardSize;
            final col = index % blockBoardSize;
            final value = state.board[row][col];
            return GestureDetector(
              onTap: () => onCellTap(row, col),
              child: _BoardCell(colorIndex: value),
            );
          },
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  final int colorIndex;

  const _BoardCell({required this.colorIndex});

  static const _colors = [
    CalmPalette.bg,
    Color(0xFF5B8DEE),
    Color(0xFF59C3C3),
    Color(0xFFF6B756),
    Color(0xFFEA7070),
    Color(0xFF9C6ADE),
    Color(0xFF5AC8FA),
    Color(0xFF72E0A8),
    Color(0xFFF78FB3),
    Color(0xFFFFD166),
    Color(0xFF7BC2FF),
  ];

  @override
  Widget build(BuildContext context) {
    final isFilled = colorIndex != 0;
    final fillColor = _colors[colorIndex % _colors.length];
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(isFilled ? 6 : 4),
        border: Border.all(
          color: isFilled
              ? Colors.white.withValues(alpha: 0.12)
              : CalmPalette.stroke,
          width: isFilled ? 0.6 : 0.8,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
    );
  }
}

class _ShapeSelector extends StatelessWidget {
  final List<BlockShape?> shapes;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _ShapeSelector({
    required this.shapes,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.s8),
        child: Row(
          children: List.generate(shapes.length, (index) {
            final shape = shapes[index];
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.s8 / 2,
              ),
              child: GestureDetector(
                onTap: shape != null ? () => onSelect(index) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: Spacing.ms180),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? CalmPalette.primary : const Color(0xFF1F2331),
                    borderRadius: BorderRadius.circular(Spacing.r24),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: CalmPalette.primary
                                  .withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: shape != null
                      ? Center(child: _ShapePreview(shape: shape))
                      : null,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ShapePreview extends StatelessWidget {
  final BlockShape shape;

  const _ShapePreview({required this.shape});

  static const _colors = [
    CalmPalette.primary,
    CalmPalette.secondary,
    CalmPalette.accent,
    Color(0xFFB8B8D1),
    Color(0xFFF4C7AB),
    Color(0xFFD4A5A5),
    Color(0xFFA5C4D4),
    Color(0xFFC4D4A5),
    Color(0xFFD4C4A5),
    Color(0xFFA5D4C4),
  ];

  @override
  Widget build(BuildContext context) {
    final cellSize = 16.0;
    final color = _colors[shape.colorIndex % _colors.length];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Spacing.r12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s8 / 2),
        child: SizedBox(
          width: shape.cols * cellSize,
          height: shape.rows * cellSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(shape.rows, (r) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(shape.cols, (c) {
                  final isFilled = shape.pattern[r][c];
                  return AnimatedScale(
                    duration: const Duration(milliseconds: Spacing.ms180),
                    scale: isFilled ? 1 : 0.9,
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        color: isFilled ? color : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                        border: isFilled
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 0.6,
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  }
}
