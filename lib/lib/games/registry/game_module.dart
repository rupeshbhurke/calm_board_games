import 'package:flutter/widgets.dart';

enum GameCategory { puzzle, logic, strategy, casual }

class GameMetadata {
  final String id;
  final String title;
  final String tagline;
  final GameCategory category;

  const GameMetadata({
    required this.id,
    required this.title,
    required this.tagline,
    required this.category,
  });
}

abstract class GameModule {
  GameMetadata get metadata;

  /// Entry point for the game UI.
  Widget buildGameScreen();
}
