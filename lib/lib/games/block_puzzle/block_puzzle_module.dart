import 'package:flutter/material.dart';

import '../registry/game_module.dart';
import 'block_puzzle_screen.dart';

class BlockPuzzleModule implements GameModule {
  const BlockPuzzleModule();

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'block_puzzle',
        title: 'Block Puzzle',
        tagline: 'Place blocks to clear lines.',
        category: GameCategory.puzzle,
        icon: Icons.extension,
      );

  @override
  Widget buildGameScreen() => const BlockPuzzleScreen();
}
