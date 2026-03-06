import 'package:flutter/material.dart';

enum GameCategory { puzzle, logic, strategy, casual }

class GameMetadata {
  final String id;
  final String title;
  final String tagline;
  final GameCategory category;
  final IconData icon;

  const GameMetadata({
    required this.id,
    required this.title,
    required this.tagline,
    required this.category,
    required this.icon,
  });
}

abstract class GameModule {
  GameMetadata get metadata;

  /// Entry point for the game UI.
  Widget buildGameScreen();
}
