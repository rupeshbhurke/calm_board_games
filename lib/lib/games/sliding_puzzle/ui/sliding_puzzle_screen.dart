import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../logic/sliding_puzzle.dart';

class SlidingPuzzleScreen extends StatefulWidget {
  const SlidingPuzzleScreen({super.key});

  @override
  State<SlidingPuzzleScreen> createState() => _SlidingPuzzleScreenState();
}

class _SlidingPuzzleScreenState extends State<SlidingPuzzleScreen> {
  late final SlidingPuzzleLogic _logic;
  late SlidingPuzzleState _state;
  bool _solvedDialogShown = false;

  @override
  void initState() {
    super.initState();
    _logic = SlidingPuzzleLogic();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _state = _logic.newGame();
      _solvedDialogShown = false;
    });
  }

  void _handleTileTap(int value) {
    final result = _logic.moveTile(_state, value);
    if (!result.moved || !mounted) return;

    setState(() {
      _state = result.state;
    });

    if (_state.solved && !_solvedDialogShown) {
      _solvedDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSolvedDialog();
      });
    }
  }

  Future<void> _showSolvedDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.r16),
          ),
          title: const Text('Puzzle Solved! ✨'),
          content: Text(
            'Great job! You finished in ${_state.moveCount} moves.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sliding Puzzle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                moveCount: _state.moveCount,
                solved: _state.solved,
                onNewGame: _resetGame,
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: Center(
                  child: _PuzzleBoard(
                    state: _state,
                    onTileTap: _handleTileTap,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.s21),
              Text(
                'Tap a tile adjacent to the empty slot to slide it into place.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int moveCount;
  final bool solved;
  final VoidCallback onNewGame;

  const _Header({
    required this.moveCount,
    required this.solved,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s21),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solved ? 'Solved' : 'In progress',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: Spacing.s8),
                Text(
                  'Moves: $moveCount',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const Spacer(),
            FilledButton(
              onPressed: onNewGame,
              child: const Text('New Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleBoard extends StatelessWidget {
  final SlidingPuzzleState state;
  final ValueChanged<int> onTileTap;

  const _PuzzleBoard({
    required this.state,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(Spacing.s8),
            decoration: BoxDecoration(
              color: CalmPalette.surface,
              borderRadius: BorderRadius.circular(Spacing.r24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: List.generate(
                SlidingPuzzleState.boardSize,
                (row) => Expanded(
                  child: Row(
                    children: List.generate(
                      SlidingPuzzleState.boardSize,
                      (col) {
                        final index = row * SlidingPuzzleState.boardSize + col;
                        final value = state.tiles[index];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.s8 / 2),
                            child: _Tile(
                              value: value,
                              onTap: value == 0
                                  ? null
                                  : () => onTileTap(value),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final int value;
  final VoidCallback? onTap;

  const _Tile({required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: Spacing.ms180),
      decoration: BoxDecoration(
        color: isEmpty ? CalmPalette.bg : CalmPalette.secondary,
        borderRadius: BorderRadius.circular(Spacing.r16),
        border: Border.all(
          color: isEmpty ? Colors.transparent : CalmPalette.stroke,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.r16),
          onTap: onTap,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: Spacing.ms180),
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: isEmpty ? CalmPalette.subtext : CalmPalette.text,
                    fontWeight: FontWeight.bold,
                  ),
              child: Text(isEmpty ? '' : value.toString()),
            ),
          ),
        ),
      ),
    );
  }
}
