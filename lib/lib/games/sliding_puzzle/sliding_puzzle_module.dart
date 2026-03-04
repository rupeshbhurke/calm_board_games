import 'package:flutter/widgets.dart';

import '../registry/game_module.dart';
import 'ui/sliding_puzzle_screen.dart';

class SlidingPuzzleModule implements GameModule {
  const SlidingPuzzleModule();

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'sliding_puzzle',
        title: 'Sliding Puzzle',
        tagline: 'Slide tiles into place.',
        category: GameCategory.puzzle,
      );

  @override
  Widget buildGameScreen() => const SlidingPuzzleScreen();
}
