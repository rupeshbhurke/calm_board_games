import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_module.dart';
import '../sliding_puzzle/sliding_puzzle_module.dart';
import '../game_2048/game_2048_module.dart';
import '../memory_match/memory_match_module.dart';
import '../connect4/connect4_module.dart';
import '../block_puzzle/block_puzzle_module.dart';
import '../sudoku/sudoku_module.dart';
import '../jigsaw/jigsaw_module.dart';

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
      MemoryMatchModule(),
      Connect4Module(),
      BlockPuzzleModule(),
      SudokuModule(),
      JigsawModule(),
    ],
  );
});
