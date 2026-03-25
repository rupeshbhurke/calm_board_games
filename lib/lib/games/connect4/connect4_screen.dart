import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../shared/game_dialogs.dart';
import '../../shared/game_header.dart';
import 'connect4_audio.dart';
import 'logic/connect4_ai.dart';
import 'logic/connect4_game.dart';

// Game-specific disc colours (not in the global palette).
const Color _kRedDisc = Color(0xFFEF5350);
const Color _kYellowDisc = Color(0xFFFFD54F);

enum _GameMode { vsAi, twoPlayer }

class Connect4Screen extends StatefulWidget {
  const Connect4Screen({super.key});

  @override
  State<Connect4Screen> createState() => _Connect4ScreenState();
}

class _Connect4ScreenState extends State<Connect4Screen>
    with SingleTickerProviderStateMixin {
  // ── Drop animation ───────────────────────────────────────────────────────
  late final AnimationController _dropController;
  late final Animation<double> _dropAnim;

  // ── Game ─────────────────────────────────────────────────────────────────
  late final Connect4Logic _logic;
  late final Connect4Ai _ai;
  late Connect4State _state;
  _GameMode _mode = _GameMode.vsAi;
  bool _isAiThinking = false;
  bool _gameOverShown = false;

  // The disc currently mid-animation (target cell renders empty until done).
  int? _dropCol;
  int? _dropRow;
  Player? _dropPlayer;

  @override
  void initState() {
    super.initState();
    _logic = Connect4Logic();
    _ai = Connect4Ai();

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _dropAnim =
        CurvedAnimation(parent: _dropController, curve: Curves.bounceOut);
    _dropController.addStatusListener(_onDropEnd);

    _state = _logic.newGame();
  }

  @override
  void dispose() {
    _dropController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool get _animating => _dropCol != null;

  /// Mutates all reset fields — always call inside setState.
  void _resetFields({_GameMode? newMode}) {
    _dropController.reset();
    if (newMode != null) _mode = newMode;
    _state = _logic.newGame();
    _isAiThinking = false;
    _gameOverShown = false;
    _dropCol = null;
    _dropRow = null;
    _dropPlayer = null;
  }

  void _animateDrop(int col, int row, Player player) {
    setState(() {
      _dropCol = col;
      _dropRow = row;
      _dropPlayer = player;
    });
    _dropController.forward(from: 0);
    Connect4Audio.playDrop();
  }

  void _onDropEnd(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() {
      _dropCol = null;
      _dropRow = null;
      _dropPlayer = null;
      _isAiThinking = false;
    });
    _checkGameOver();
    if (!_state.isGameOver &&
        _mode == _GameMode.vsAi &&
        _state.currentPlayer == Player.yellow) {
      _scheduleAiMove();
    }
  }

  void _onColumnTap(int col) {
    if (_state.isGameOver || _animating || _isAiThinking) return;
    if (_mode == _GameMode.vsAi && _state.currentPlayer != Player.red) return;

    final player = _state.currentPlayer;
    final result = _logic.dropDisc(_state, col);
    if (!result.valid || result.placedRow == null) return;

    setState(() => _state = result.state);
    _animateDrop(col, result.placedRow!, player);
  }

  void _scheduleAiMove() {
    setState(() => _isAiThinking = true);
    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      final col = _ai.chooseColumn(_state);
      if (col == null) return;
      final result = _logic.dropDisc(_state, col);
      if (!result.valid || result.placedRow == null) return;
      setState(() => _state = result.state);
      _animateDrop(col, result.placedRow!, Player.yellow);
    });
  }

  void _checkGameOver() {
    if (!_state.isGameOver || _gameOverShown) return;
    _gameOverShown = true;

    final String title;
    final String message;
    switch (_state.result) {
      case GameResult.redWins:
        title = _mode == _GameMode.vsAi ? 'You Win! 🎉' : 'Red Wins! 🎉';
        message = _mode == _GameMode.vsAi
            ? 'You connected four. Nicely done!'
            : 'Red connected four!';
        Connect4Audio.playWin();
      case GameResult.yellowWins:
        title = _mode == _GameMode.vsAi ? 'AI Wins' : 'Yellow Wins! 🎉';
        message = _mode == _GameMode.vsAi
            ? 'The AI connected four. Try again!'
            : 'Yellow connected four!';
        Connect4Audio.playWin();
      case GameResult.draw:
        title = 'Draw';
        message = 'Board full — no winner this time.';
        Connect4Audio.playDraw();
      case GameResult.ongoing:
        return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameDialog(
        context: context,
        title: title,
        message: message,
        primaryLabel: 'Play Again',
        onPrimary: () => setState(_resetFields),
      );
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  String get _statusText {
    if (_state.isGameOver) return 'Game Over';
    if (_isAiThinking) return 'AI is thinking…';
    if (_mode == _GameMode.vsAi) return 'Your turn (Red)';
    return _state.currentPlayer == Player.red ? "Red's turn" : "Yellow's turn";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect 4')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            children: [
              GameHeader(
                title: _statusText,
                buttonLabel: 'New Game',
                onButtonPressed: () => setState(_resetFields),
              ),
              const SizedBox(height: Spacing.s13),
              _ModeToggle(
                mode: _mode,
                onChanged: (m) => setState(() => _resetFields(newMode: m)),
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: Center(
                  child: _Board(
                    state: _state,
                    onColumnTap: _onColumnTap,
                    dropCol: _dropCol,
                    dropRow: _dropRow,
                    dropPlayer: _dropPlayer,
                    dropAnim: _dropAnim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mode toggle ──────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final _GameMode mode;
  final ValueChanged<_GameMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ToggleChip(
          label: 'vs AI',
          selected: mode == _GameMode.vsAi,
          onTap: () => onChanged(_GameMode.vsAi),
        ),
        const SizedBox(width: Spacing.s8),
        _ToggleChip(
          label: '2 Players',
          selected: mode == _GameMode.twoPlayer,
          onTap: () => onChanged(_GameMode.twoPlayer),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: Spacing.ms180),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.s21,
          vertical: Spacing.s8,
        ),
        decoration: BoxDecoration(
          color: selected ? CalmPalette.primary : CalmPalette.surface,
          borderRadius: BorderRadius.circular(Spacing.r16),
          border: Border.all(
            color: selected ? CalmPalette.primary : CalmPalette.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? CalmPalette.text : CalmPalette.subtext,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Board ────────────────────────────────────────────────────────────────────

class _Board extends StatelessWidget {
  final Connect4State state;
  final ValueChanged<int> onColumnTap;
  final int? dropCol;
  final int? dropRow;
  final Player? dropPlayer;
  final Animation<double> dropAnim;

  const _Board({
    required this.state,
    required this.onColumnTap,
    required this.dropCol,
    required this.dropRow,
    required this.dropPlayer,
    required this.dropAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: connect4Cols / connect4Rows,
      child: Container(
        padding: const EdgeInsets.all(Spacing.s8),
        decoration: BoxDecoration(
          color: CalmPalette.primary,
          borderRadius: BorderRadius.circular(Spacing.r24),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellW = constraints.maxWidth / connect4Cols;
            final cellH = constraints.maxHeight / connect4Rows;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Static grid — only rebuilds on game state changes.
                _Grid(
                  state: state,
                  onColumnTap: onColumnTap,
                  dropCol: dropCol,
                  dropRow: dropRow,
                ),

                // Falling disc overlay — rebuilds each animation frame.
                if (dropCol != null && dropRow != null && dropPlayer != null)
                  AnimatedBuilder(
                    animation: dropAnim,
                    builder: (_, _) {
                      // Disc centre animates from just above the grid to the
                      // centre of the target cell.
                      final startCY = -cellH / 2;
                      final endCY = dropRow! * cellH + cellH / 2;
                      final cy =
                          startCY + (endCY - startCY) * dropAnim.value;
                      final discSize =
                          (cellW < cellH ? cellW : cellH) - 8.0;
                      return Positioned(
                        left: dropCol! * cellW + (cellW - discSize) / 2,
                        top: cy - discSize / 2,
                        width: discSize,
                        height: discSize,
                        child: _Disc(player: dropPlayer!),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Static grid ──────────────────────────────────────────────────────────────

class _Grid extends StatelessWidget {
  final Connect4State state;
  final ValueChanged<int> onColumnTap;
  final int? dropCol;
  final int? dropRow;

  const _Grid({
    required this.state,
    required this.onColumnTap,
    required this.dropCol,
    required this.dropRow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(connect4Rows, (row) {
        return Expanded(
          child: Row(
            children: List.generate(connect4Cols, (col) {
              // Hide the target cell while the drop animation plays.
              final isAnimating = dropCol == col && dropRow == row;
              final player =
                  isAnimating ? Player.none : state.board[row][col];
              final isWinning = !isAnimating &&
                  (state.winningCells?.contains((row, col)) ?? false);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onColumnTap(col),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _Cell(player: player, isWinning: isWinning),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ── Cell (static disc slot) ──────────────────────────────────────────────────

class _Cell extends StatelessWidget {
  final Player player;
  final bool isWinning;

  const _Cell({required this.player, required this.isWinning});

  @override
  Widget build(BuildContext context) {
    final color = switch (player) {
      Player.none => CalmPalette.bg,
      Player.red => _kRedDisc,
      Player.yellow => _kYellowDisc,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: Spacing.ms180),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isWinning
            ? Border.all(color: CalmPalette.text, width: 3)
            : null,
        boxShadow: isWinning
            ? [
                BoxShadow(
                  color: CalmPalette.text.withValues(alpha: 0.35),
                  blurRadius: 10,
                ),
              ]
            : player != Player.none
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
      ),
    );
  }
}

// ── Falling disc overlay ─────────────────────────────────────────────────────

class _Disc extends StatelessWidget {
  final Player player;

  const _Disc({required this.player});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: player == Player.red ? _kRedDisc : _kYellowDisc,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
