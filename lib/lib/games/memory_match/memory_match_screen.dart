import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../shared/game_dialogs.dart';
import '../../shared/game_header.dart';
import 'logic/memory_match.dart';

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  late final MemoryMatchLogic _logic;
  late MemoryMatchState _state;
  bool _completionShown = false;

  @override
  void initState() {
    super.initState();
    _logic = MemoryMatchLogic();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _state = _logic.newGame();
      _completionShown = false;
    });
  }

  void _onCardTap(int index) {
    final result = _logic.flipCard(_state, index);
    if (!result.flipped || !mounted) return;

    setState(() {
      _state = result.state;
    });

    if (_state.secondFlippedIndex != null) {
      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _state = _logic.checkMatch(_state);
        });
        _checkCompletion();
      });
    }
  }

  void _checkCompletion() {
    if (_state.isComplete && !_completionShown) {
      _completionShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showGameDialog(
          context: context,
          title: 'Congratulations! 🎉',
          message: 'You found all pairs in ${_state.moves} moves!',
          primaryLabel: 'Play Again',
          onPrimary: _resetGame,
          secondaryLabel: 'Close',
          onSecondary: () {},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Match')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.s21),
          child: Column(
            children: [
              GameHeader(
                title: 'Pairs: ${_state.matchedPairs}/${_state.totalPairs}',
                subtitle: 'Moves: ${_state.moves}',
                buttonLabel: 'New Game',
                onButtonPressed: _resetGame,
              ),
              const SizedBox(height: Spacing.s21),
              Expanded(
                child: Center(
                  child: _CardGrid(
                    state: _state,
                    onCardTap: _onCardTap,
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

class _CardGrid extends StatelessWidget {
  final MemoryMatchState state;
  final ValueChanged<int> onCardTap;

  const _CardGrid({required this.state, required this.onCardTap});

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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: state.gridSize,
            mainAxisSpacing: Spacing.s8,
            crossAxisSpacing: Spacing.s8,
          ),
          itemCount: state.cards.length,
          itemBuilder: (context, index) {
            final card = state.cards[index];
            return _FlipCard(
              card: card,
              onTap: () => onCardTap(index),
            );
          },
        ),
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;

  const _FlipCard({required this.card, required this.onTap});

  static const _symbols = [
    '🌸', '🌺', '🌻', '🌷', '🌹', '🍀', '🌿', '🍃',
    '⭐', '🌙', '☀️', '🌈', '❄️', '🔥', '💧', '🌊',
  ];

  @override
  Widget build(BuildContext context) {
    final isRevealed = card.isFaceUp || card.isMatched;
    final symbol = _symbols[card.pairId % _symbols.length];

    return GestureDetector(
      onTap: card.isFaceDown ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: Spacing.ms220),
        decoration: BoxDecoration(
          color: card.isMatched
              ? CalmPalette.secondary
              : isRevealed
                  ? CalmPalette.primary
                  : CalmPalette.accent,
          borderRadius: BorderRadius.circular(Spacing.r16),
          border: Border.all(color: CalmPalette.stroke),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: Spacing.ms180),
            child: isRevealed
                ? Text(
                    symbol,
                    key: ValueKey('symbol_${card.id}'),
                    style: const TextStyle(fontSize: 32),
                  )
                : Icon(
                    Icons.question_mark,
                    key: ValueKey('question_${card.id}'),
                    color: CalmPalette.text,
                    size: 28,
                  ),
          ),
        ),
      ),
    );
  }
}
