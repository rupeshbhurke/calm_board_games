import 'package:flutter/material.dart';

import '../games/registry/game_registry.dart';
import '../games/registry/game_module.dart';
import '../theme/spacing.dart';
import '../ui/cards/game_card.dart';

class HomeScreen extends StatelessWidget {
  final GameRegistry registry;

  const HomeScreen({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    final puzzles = registry.byCategory(GameCategory.puzzle);
    final logic = registry.byCategory(GameCategory.logic);
    final strategy = registry.byCategory(GameCategory.strategy);
    final casual = registry.byCategory(GameCategory.casual);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calm Board Suite'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.s13),
        children: [
          _Section(title: 'Puzzle', modules: puzzles),
          _Section(title: 'Logic', modules: logic),
          _Section(title: 'Strategy', modules: strategy),
          _Section(title: 'Casual', modules: casual),
          const SizedBox(height: Spacing.s34),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<GameModule> modules;

  const _Section({required this.title, required this.modules});

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.s13),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...modules.map((m) => GameCard(module: m)),
      ],
    );
  }
}
