import 'package:flutter/widgets.dart';

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
      );

  @override
  Widget buildGameScreen() => const JigsawScreen();
}
