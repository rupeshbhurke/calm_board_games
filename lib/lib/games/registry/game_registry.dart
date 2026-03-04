import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_module.dart';
import '../sliding_puzzle/sliding_puzzle_module.dart';
import '../game_2048/game_2048_module.dart';

class GameRegistry {
  final List<GameModule> modules;

  const GameRegistry({required this.modules});

  List<GameModule> byCategory(GameCategory category) =>
      modules.where((m) => m.metadata.category == category).toList();

  GameModule? byId(String id) {
    for (final m in modules) {
      if (m.metadata.id == id) return m;
    }
    return null;
  }
}

final gameRegistryProvider = Provider<GameRegistry>((ref) {
  // Register modules here. Keep it explicit (no reflection).
  return GameRegistry(
    modules: const [
      SlidingPuzzleModule(),
      Game2048Module(),
    ],
  );
});
