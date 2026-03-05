import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

import 'package:calm_board_games/lib/engine/rng.dart';
import 'package:calm_board_games/lib/games/memory_match/logic/memory_match.dart';

class _FakeRng implements Rng {
  final Queue<int> _ints;

  _FakeRng({Iterable<int> ints = const []}) : _ints = Queue<int>.of(ints);

  @override
  int nextInt(int max) {
    if (_ints.isEmpty) return 0;
    return _ints.removeFirst() % max;
  }

  @override
  double nextDouble() => 0.5;
}

void main() {
  group('MemoryMatchLogic', () {
    test('new game creates correct number of cards', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      final state = logic.newGame(gridSize: 4);

      expect(state.cards.length, 16);
      expect(state.moves, 0);
      expect(state.isComplete, isFalse);
      expect(state.firstFlippedIndex, isNull);
      expect(state.secondFlippedIndex, isNull);
    });

    test('all cards start face down', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      final state = logic.newGame(gridSize: 4);

      expect(state.cards.every((c) => c.isFaceDown), isTrue);
    });

    test('each pair ID appears exactly twice', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      final state = logic.newGame(gridSize: 4);

      final pairCounts = <int, int>{};
      for (final card in state.cards) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }

      expect(pairCounts.values.every((count) => count == 2), isTrue);
    });

    test('flipping first card reveals it', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      var state = logic.newGame(gridSize: 4);

      final result = logic.flipCard(state, 0);

      expect(result.flipped, isTrue);
      expect(result.state.cards[0].isFaceUp, isTrue);
      expect(result.state.firstFlippedIndex, 0);
      expect(result.state.moves, 0);
    });

    test('flipping second card increments moves', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      var state = logic.newGame(gridSize: 4);

      state = logic.flipCard(state, 0).state;
      final result = logic.flipCard(state, 1);

      expect(result.flipped, isTrue);
      expect(result.state.secondFlippedIndex, 1);
      expect(result.state.moves, 1);
      expect(result.state.isProcessing, isTrue);
    });

    test('matching pair becomes matched', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      var state = logic.newGame(gridSize: 4);

      final firstPairId = state.cards[0].pairId;
      final matchIndex = state.cards.indexWhere(
        (c) => c.pairId == firstPairId && c.id != state.cards[0].id,
      );

      state = logic.flipCard(state, 0).state;
      state = logic.flipCard(state, matchIndex).state;
      state = logic.checkMatch(state);

      expect(state.cards[0].isMatched, isTrue);
      expect(state.cards[matchIndex].isMatched, isTrue);
      expect(state.firstFlippedIndex, isNull);
      expect(state.secondFlippedIndex, isNull);
    });

    test('non-matching pair flips back', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      var state = logic.newGame(gridSize: 4);

      final firstPairId = state.cards[0].pairId;
      final nonMatchIndex = state.cards.indexWhere(
        (c) => c.pairId != firstPairId,
      );

      state = logic.flipCard(state, 0).state;
      state = logic.flipCard(state, nonMatchIndex).state;
      state = logic.checkMatch(state);

      expect(state.cards[0].isFaceDown, isTrue);
      expect(state.cards[nonMatchIndex].isFaceDown, isTrue);
    });

    test('cannot flip already matched card', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      var state = logic.newGame(gridSize: 4);

      final firstPairId = state.cards[0].pairId;
      final matchIndex = state.cards.indexWhere(
        (c) => c.pairId == firstPairId && c.id != state.cards[0].id,
      );

      state = logic.flipCard(state, 0).state;
      state = logic.flipCard(state, matchIndex).state;
      state = logic.checkMatch(state);

      final result = logic.flipCard(state, 0);
      expect(result.flipped, isFalse);
    });

    test('cannot flip while processing', () {
      final logic = MemoryMatchLogic(rng: _FakeRng(ints: List.filled(100, 0)));
      var state = logic.newGame(gridSize: 4);

      state = logic.flipCard(state, 0).state;
      state = logic.flipCard(state, 1).state;

      expect(state.isProcessing, isTrue);

      final result = logic.flipCard(state, 2);
      expect(result.flipped, isFalse);
    });
  });
}
