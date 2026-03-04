import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';
import 'logic/game_2048.dart';
import 'logic/rng.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  late final Game2048Logic _logic;
  late Game2048State _state;
  final FocusNode _focusNode = FocusNode(debugLabel: '2048Focus');
  Offset? _dragStart;
  Offset? _dragLatest;
  bool _winDialogShown = false;
  bool _loseDialogShown = false;

  @override
  void initState() {
    super.initState();
    _logic = Game2048Logic(rng: RandomRng());
    _resetGame();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _state = _logic.newGame();
      _winDialogShown = false;
      _loseDialogShown = false;
    });
  }

  void _handleMove(MoveDirection direction) {
    final result = _logic.move(_state, direction);
    if (!mounted) return;
    setState(() {
      _state = result.state;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowDialogs(_state);
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _handleMove(MoveDirection.up);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _handleMove(MoveDirection.down);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _handleMove(MoveDirection.left);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _handleMove(MoveDirection.right);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _maybeShowDialogs(Game2048State state) {
    if (state.won && !_winDialogShown) {
      _winDialogShown = true;
      _showDialog(
        title: 'You made it! 🎉',
        message: 'Tile 2048 reached. Keep sliding or start anew.',
        primaryLabel: 'Keep Playing',
        onPrimary: () => Navigator.of(context).pop(),
        secondaryLabel: 'New Game',
        onSecondary: () {
          Navigator.of(context).pop();
          _resetGame();
        },
      );
    } else if (state.lost && !_loseDialogShown) {
      _loseDialogShown = true;
      _showDialog(
        title: 'Game over',
        message: 'No moves left. Give it another shot?',
        primaryLabel: 'Try Again',
        onPrimary: () {
          Navigator.of(context).pop();
          _resetGame();
        },
      );
    }
  }

  Future<void> _showDialog({
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.r16),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            if (secondaryLabel != null && onSecondary != null)
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
            FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
          ],
        );
      },
    );
  }

  void _handleSwipeGesture() {
    if (_dragStart == null || _dragLatest == null) return;
    final delta = _dragLatest! - _dragStart!;
    if (delta.distance < 20) return;
    if (delta.dx.abs() > delta.dy.abs()) {
      _handleMove(delta.dx > 0 ? MoveDirection.right : MoveDirection.left);
    } else {
      _handleMove(delta.dy > 0 ? MoveDirection.down : MoveDirection.up);
    }
    _dragStart = null;
    _dragLatest = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2048')),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: GestureDetector(
          onPanStart: (details) {
            _dragStart = details.localPosition;
            _dragLatest = details.localPosition;
          },
          onPanUpdate: (details) {
            _dragLatest = details.localPosition;
          },
          onPanEnd: (_) => _handleSwipeGesture(),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.s21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(state: _state, onNewGame: _resetGame),
                  const SizedBox(height: Spacing.s21),
                  Expanded(
                    child: Center(
                      child: _BoardGrid(board: _state.board),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Game2048State state;
  final VoidCallback onNewGame;

  const _Header({required this.state, required this.onNewGame});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('2048', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                _ScoreChip(label: 'Score', value: state.score),
                const SizedBox(width: Spacing.s13),
                FilledButton(onPressed: onNewGame, child: const Text('New Game')),
              ],
            ),
            const SizedBox(height: Spacing.s8),
            Text(
              'Swipe or use arrow keys to slide tiles. Merge to reach 2048.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: CalmPalette.subtext),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.s13,
        vertical: Spacing.s8,
      ),
      decoration: BoxDecoration(
        color: CalmPalette.secondary,
        borderRadius: BorderRadius.circular(Spacing.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _BoardGrid extends StatelessWidget {
  final List<List<int>> board;

  const _BoardGrid({required this.board});

  @override
  Widget build(BuildContext context) {
    const gap = Spacing.s8;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileSize = (constraints.maxWidth - gap * 5) / 4;
          return Container(
            padding: const EdgeInsets.all(gap),
            decoration: BoxDecoration(
              color: CalmPalette.surface,
              borderRadius: BorderRadius.circular(Spacing.r24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: List.generate(4, (r) {
                return Padding(
                  padding: EdgeInsets.only(bottom: r < 3 ? gap : 0),
                  child: Row(
                    children: List.generate(4, (c) {
                      return Padding(
                        padding: EdgeInsets.only(right: c < 3 ? gap : 0),
                        child: _TileWidget(
                          value: board[r][c],
                          size: tileSize,
                          key: ValueKey('tile-$r-$c-${board[r][c]}'),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _TileWidget extends StatelessWidget {
  final int value;
  final double size;

  const _TileWidget({
    required this.value,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = _tileColor(value);
    final textColor = value <= 4 ? CalmPalette.text : Colors.white;
    final text = value == 0 ? '' : '$value';
    return AnimatedContainer(
      duration: const Duration(milliseconds: Spacing.ms180),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Spacing.r16),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: Spacing.ms180),
        child: Text(
          text,
          key: ValueKey(text),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

Color _tileColor(int value) {
  switch (value) {
    case 0:
      return CalmPalette.bg;
    case 2:
      return const Color(0xFFEFE5DA);
    case 4:
      return const Color(0xFFE5D4C0);
    case 8:
      return const Color(0xFFF5B971);
    case 16:
      return const Color(0xFFF79F79);
    case 32:
      return const Color(0xFFE57373);
    case 64:
      return const Color(0xFFEB5757);
    case 128:
      return const Color(0xFFF2994A);
    case 256:
      return const Color(0xFFF2C94C);
    case 512:
      return const Color(0xFF56CCF2);
    case 1024:
      return const Color(0xFF2D9CDB);
    default:
      return const Color(0xFF6C5CE7);
  }
}
