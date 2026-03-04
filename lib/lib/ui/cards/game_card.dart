import 'package:flutter/material.dart';

import '../../games/registry/game_module.dart';
import '../../theme/spacing.dart';

class GameCard extends StatelessWidget {
  final GameModule module;

  const GameCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final meta = module.metadata;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.s21),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Spacing.s8),
                  Text(meta.tagline, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: Spacing.s13),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => module.buildGameScreen()),
                );
              },
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}
