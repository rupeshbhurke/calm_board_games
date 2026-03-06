import 'package:flutter/material.dart';

import '../registry/game_module.dart';
import 'connect4_screen.dart';

class Connect4Module implements GameModule {
  const Connect4Module();

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'connect4',
        title: 'Connect 4',
        tagline: 'Drop discs to connect four.',
        category: GameCategory.strategy,
        icon: Icons.circle,
      );

  @override
  Widget buildGameScreen() => const Connect4Screen();
}
