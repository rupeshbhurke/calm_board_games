import 'package:flutter/material.dart';

import '../registry/game_module.dart';
import 'sudoku_screen.dart';

class SudokuModule implements GameModule {
  const SudokuModule();

  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'sudoku',
        title: 'Sudoku',
        tagline: 'Fill the grid with numbers.',
        category: GameCategory.logic,
        icon: Icons.grid_3x3,
      );

  @override
  Widget buildGameScreen() => const SudokuScreen();
}
