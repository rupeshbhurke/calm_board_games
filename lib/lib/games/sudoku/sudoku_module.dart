import 'package:flutter/widgets.dart';

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
      );

  @override
  Widget buildGameScreen() => const SudokuScreen();
}
