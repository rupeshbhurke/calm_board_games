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

  @override
  void initState() {
    super.initState();
    _logic = BlockBoardLogic();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _state = _logic.newGame();
      _selectedShapeIndex = null;
      _gameOverShown = false;
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
              Expanded(
                child: Center(
                  child: _GameBoard(
                    state: _state,
                    selectedShape: _selectedShapeIndex != null
                        ? _state.availableShapes[_selectedShapeIndex!]
                        : null,
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

class _GameBoard extends StatelessWidget {
  final BlockBoardState state;
  final BlockShape? selectedShape;
  final void Function(int row, int col) onCellTap;

  const _GameBoard({
    required this.state,
    required this.selectedShape,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(Spacing.s8),
        decoration: BoxDecoration(
          color: CalmPalette.surface,
          borderRadius: BorderRadius.circular(Spacing.r24),
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
    return Container(
      decoration: BoxDecoration(
        color: _colors[colorIndex % _colors.length],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colorIndex == 0 ? CalmPalette.stroke : Colors.transparent,
          width: 0.5,
        ),
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
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(shapes.length, (index) {
          final shape = shapes[index];
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: shape != null ? () => onSelect(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: Spacing.ms180),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isSelected ? CalmPalette.primary : CalmPalette.surface,
                borderRadius: BorderRadius.circular(Spacing.r16),
                border: Border.all(
                  color: isSelected ? CalmPalette.text : CalmPalette.stroke,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: shape != null
                  ? Center(child: _ShapePreview(shape: shape))
                  : null,
            ),
          );
        }),
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
    final cellSize = 12.0;
    final color = _colors[shape.colorIndex % _colors.length];

    return SizedBox(
      width: shape.cols * cellSize,
      height: shape.rows * cellSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(shape.rows, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(shape.cols, (c) {
              return Container(
                width: cellSize,
                height: cellSize,
                margin: const EdgeInsets.all(0.5),
                decoration: BoxDecoration(
                  color: shape.pattern[r][c] ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
