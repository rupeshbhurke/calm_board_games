import 'package:flutter/material.dart';

import '../registry/game_module.dart';
import 'memory_match_screen.dart';

class MemoryMatchModule implements GameModule {
  const MemoryMatchModule();

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'memory_match',
        title: 'Memory Match',
        tagline: 'Find all matching pairs.',
        category: GameCategory.puzzle,
        icon: Icons.grid_view,
      );

  @override
  Widget buildGameScreen() => const MemoryMatchScreen();
}
