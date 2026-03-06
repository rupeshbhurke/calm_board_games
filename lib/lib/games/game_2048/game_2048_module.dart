import 'package:flutter/material.dart';

import '../registry/game_module.dart';
import 'game_2048_screen.dart';

class Game2048Module implements GameModule {
  const Game2048Module();

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'game_2048',
        title: '2048',
        tagline: 'Slide tiles to reach 2048.',
        category: GameCategory.puzzle,
        icon: Icons.numbers,
      );

  @override
  Widget buildGameScreen() => const Game2048Screen();
}
