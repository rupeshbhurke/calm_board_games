import 'package:flutter/material.dart';

import '../registry/game_module.dart';
import 'jigsaw_screen.dart';

class JigsawModule implements GameModule {
  const JigsawModule();

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'jigsaw',
        title: 'Jigsaw Puzzle',
        tagline: 'Piece together the picture.',
        category: GameCategory.puzzle,
        icon: Icons.auto_fix_high,
      );

  @override
  Widget buildGameScreen() => const JigsawScreen();
}
