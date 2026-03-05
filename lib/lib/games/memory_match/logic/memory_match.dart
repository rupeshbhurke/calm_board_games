import '../../../engine/rng.dart';

const int defaultGridSize = 4;

enum CardState { faceDown, faceUp, matched }

class MemoryCard {
  final int id;
  final int pairId;
  final CardState state;

  const MemoryCard({
    required this.id,
    required this.pairId,
    required this.state,
  });

  MemoryCard copyWith({CardState? state}) {
    return MemoryCard(
      id: id,
      pairId: pairId,
      state: state ?? this.state,
    );
  }

  bool get isFaceDown => state == CardState.faceDown;
  bool get isFaceUp => state == CardState.faceUp;
  bool get isMatched => state == CardState.matched;
}

class MemoryMatchState {
  final List<MemoryCard> cards;
  final int moves;
  final int? firstFlippedIndex;
  final int? secondFlippedIndex;
  final bool isProcessing;
  final int gridSize;

  const MemoryMatchState._({
    required this.cards,
    required this.moves,
    required this.firstFlippedIndex,
    required this.secondFlippedIndex,
    required this.isProcessing,
    required this.gridSize,
  });

  factory MemoryMatchState.initial(Rng rng, {int gridSize = defaultGridSize}) {
    final totalCards = gridSize * gridSize;
    final pairCount = totalCards ~/ 2;

    final pairIds = <int>[];
    for (var i = 0; i < pairCount; i++) {
      pairIds.add(i);
      pairIds.add(i);
    }

    _shuffle(pairIds, rng);

    final cards = List<MemoryCard>.generate(
      totalCards,
      (index) => MemoryCard(
        id: index,
        pairId: pairIds[index],
        state: CardState.faceDown,
      ),
    );

    return MemoryMatchState._(
      cards: List.unmodifiable(cards),
      moves: 0,
      firstFlippedIndex: null,
      secondFlippedIndex: null,
      isProcessing: false,
      gridSize: gridSize,
    );
  }

  bool get isComplete => cards.every((c) => c.isMatched);

  int get matchedPairs => cards.where((c) => c.isMatched).length ~/ 2;

  int get totalPairs => cards.length ~/ 2;

  MemoryMatchState _copyWith({
    List<MemoryCard>? cards,
    int? moves,
    int? Function()? firstFlippedIndex,
    int? Function()? secondFlippedIndex,
    bool? isProcessing,
  }) {
    return MemoryMatchState._(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      firstFlippedIndex:
          firstFlippedIndex != null ? firstFlippedIndex() : this.firstFlippedIndex,
      secondFlippedIndex:
          secondFlippedIndex != null ? secondFlippedIndex() : this.secondFlippedIndex,
      isProcessing: isProcessing ?? this.isProcessing,
      gridSize: gridSize,
    );
  }
}

class MemoryMatchResult {
  final MemoryMatchState state;
  final bool flipped;

  const MemoryMatchResult({required this.state, required this.flipped});
}

class MemoryMatchLogic {
  final Rng rng;

  MemoryMatchLogic({Rng? rng}) : rng = rng ?? RandomRng();

  MemoryMatchState newGame({int gridSize = defaultGridSize}) {
    return MemoryMatchState.initial(rng, gridSize: gridSize);
  }

  MemoryMatchResult flipCard(MemoryMatchState state, int index) {
    if (state.isProcessing) {
      return MemoryMatchResult(state: state, flipped: false);
    }

    final card = state.cards[index];
    if (card.isMatched || card.isFaceUp) {
      return MemoryMatchResult(state: state, flipped: false);
    }

    final cards = List<MemoryCard>.from(state.cards);
    cards[index] = card.copyWith(state: CardState.faceUp);

    if (state.firstFlippedIndex == null) {
      final newState = state._copyWith(
        cards: List.unmodifiable(cards),
        firstFlippedIndex: () => index,
      );
      return MemoryMatchResult(state: newState, flipped: true);
    }

    final newState = state._copyWith(
      cards: List.unmodifiable(cards),
      secondFlippedIndex: () => index,
      moves: state.moves + 1,
      isProcessing: true,
    );
    return MemoryMatchResult(state: newState, flipped: true);
  }

  MemoryMatchState checkMatch(MemoryMatchState state) {
    if (state.firstFlippedIndex == null || state.secondFlippedIndex == null) {
      return state;
    }

    final first = state.cards[state.firstFlippedIndex!];
    final second = state.cards[state.secondFlippedIndex!];

    final cards = List<MemoryCard>.from(state.cards);

    if (first.pairId == second.pairId) {
      cards[state.firstFlippedIndex!] = first.copyWith(state: CardState.matched);
      cards[state.secondFlippedIndex!] = second.copyWith(state: CardState.matched);
    } else {
      cards[state.firstFlippedIndex!] = first.copyWith(state: CardState.faceDown);
      cards[state.secondFlippedIndex!] = second.copyWith(state: CardState.faceDown);
    }

    return state._copyWith(
      cards: List.unmodifiable(cards),
      firstFlippedIndex: () => null,
      secondFlippedIndex: () => null,
      isProcessing: false,
    );
  }
}

void _shuffle<T>(List<T> list, Rng rng) {
  for (var i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }
}
