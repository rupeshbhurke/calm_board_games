import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../shared/game_dialogs.dart';
import '../../shared/game_header.dart';
import 'logic/connect4_ai.dart';
import 'logic/connect4_game.dart';

class Connect4Screen extends StatefulWidget {
  const Connect4Screen({super.key});

  @override
  State<Connect4Screen> createState() => _Connect4ScreenState();
}

class _Connect4ScreenState extends State<Connect4Screen> {
  late final Connect4Logic _logic;
  late final Connect4Ai _ai;
  late Connect4State _state;
  bool _isAiThinking = false;
  bool _gameOverShown = false;
  int? _droppingColumn;
  int? _droppingRow;

  @override
  void initState() {
    super.initState();
    _logic = Connect4Logic();
    _ai = Connect4Ai();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _state = _logic.newGame();
      _isAiThinking = false;
      _gameOverShown = false;
      _droppingColumn = null;
      _droppingRow = null;
    });
  }

  void _onColumnTap(int column) {
    if (_state.isGameOver || _isAiThinking) return;
    if (_state.currentPlayer != Player.red) return;

    final result = _logic.dropDisc(_state, column);
    if (!result.valid || !mounted) return;

    setState(() {
      _state = result.state;
      _droppingColumn = column;
      _droppingRow = result.placedRow;
    });

    Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _droppingColumn = null;
        _droppingRow = null;
      });
      _checkGameOver();
      if (!_state.isGameOver) {
        _aiMove();
      }
    });
  }

  void _aiMove() {
    setState(() => _isAiThinking = true);

    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final column = _ai.chooseColumn(_state);
      if (column == null) return;

      final result = _logic.dropDisc(_state, column);
      if (!result.valid) return;

      setState(() {
        _state = result.state;
        _droppingColumn = column;
        _droppingRow = result.placedRow;
      });

      Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _isAiThinking = false;
          _droppingColumn = null;
          _droppingRow = null;
        });
        _checkGameOver();
      });
    });
  }

  void _checkGameOver() {
    if (_state.isGameOver && !_gameOverShown) {
      _gameOverShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final String title;
        final String message;
        switch (_state.result) {
          case GameResult.redWins:
            title = 'You Win! 🎉';
            message = 'Congratulations! You connected four!';
          case GameResult.yellowWins:
            title = 'AI Wins';
            message = 'The AI connected four. Try again!';
          case GameResult.draw:
            title = 'Draw';
            message = 'The board is full. No winner this time.';
          case GameResult.ongoing:
            return;
        }
        showGameDialog(
          context: context,
          title: title,
          message: message,
          primaryLabel: 'Play Again',
          onPrimary: _resetGame,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _state.isGameOver
        ? 'Game Over'
        : _isAiThinking
            ? "AI's turn..."
            : 'Your turn (Red)';

    return Scaffold(
      appBar: AppBar(title: const Text('Connect 4')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            children: [
              GameHeader(
                title: statusText,
                buttonLabel: 'New Game',
                onButtonPressed: _resetGame,
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: Center(
                  child: _Board(
                    state: _state,
                    onColumnTap: _onColumnTap,
                    droppingColumn: _droppingColumn,
                    droppingRow: _droppingRow,
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

class _Board extends StatelessWidget {
  final Connect4State state;
  final ValueChanged<int> onColumnTap;
  final int? droppingColumn;
  final int? droppingRow;

  const _Board({
    required this.state,
    required this.onColumnTap,
    this.droppingColumn,
    this.droppingRow,
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
        child: Column(
          children: List.generate(connect4Rows, (row) {
            return Expanded(
              child: Row(
                children: List.generate(connect4Cols, (col) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onColumnTap(col),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: _Cell(
                          player: state.board[row][col],
                          isWinning: state.winningCells?.contains((row, col)) ?? false,
                          isDropping: droppingColumn == col && droppingRow == row,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final Player player;
  final bool isWinning;
  final bool isDropping;

  const _Cell({
    required this.player,
    required this.isWinning,
    required this.isDropping,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (player) {
      case Player.none:
        color = CalmPalette.surface;
      case Player.red:
        color = Colors.red.shade400;
      case Player.yellow:
        color = Colors.amber.shade400;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: isDropping ? 200 : Spacing.ms180),
      curve: isDropping ? Curves.bounceOut : Curves.easeInOut,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isWinning
            ? Border.all(color: CalmPalette.text, width: 3)
            : null,
        boxShadow: player != Player.none
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
